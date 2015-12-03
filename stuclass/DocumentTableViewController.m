//
//  DocumentTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 11/26/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "DocumentTableViewController.h"
#import <KVNProgress/KVNProgress.h>
#import "MBProgressHUD.h"
#import <AFNetworking/AFNetworking.h>
#import "Define.h"
#import "Document.h"
#import "DocumentTableViewCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "DocumentFooterView.h"
#import "ClassParser.h"
#import "DocumentDetailViewController.h"
#import "MobClick.h"

static NSString *cell_id = @"DocumentTableViewCell";


static const CGFloat kHeightForSectionHeader = 8.0;


@interface DocumentTableViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) UIView *sectionHeaderView;

@property (nonatomic) BOOL isLoading;

@property (assign, nonatomic) NSInteger pageindex;

@end


@implementation DocumentTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupBarBackButton];
    
    [self setupTableView];
}

#pragma mark - Setup Method

- (void)setupBarBackButton
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
}


- (void)setupTableView
{
    self.tableView.backgroundColor = TABLEVIEW_BACKGROUN_COLOR;
    
    self.tableView.fd_debugLogEnabled = NO;
    
    // refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlDidPull) forControlEvents:UIControlEventValueChanged];
    
    // FooterView
    DocumentFooterView *footerView = [[DocumentFooterView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 50)];
    self.tableView.tableFooterView = footerView;
    
    // sectionHeaderView
    _sectionHeaderView = [[UIView alloc] init];
    _sectionHeaderView.backgroundColor = [UIColor clearColor];
}


#pragma mark - TableView Delegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeightForSectionHeader;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _documentData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DocumentTableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:cell_id forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(DocumentTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Document *document = _documentData[indexPath.section];
    
    cell.nameLabel.text = document.title;
    cell.dateLabel.text = document.date;
    cell.departmentLabel.text = document.department;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:cell_id cacheByIndexPath:indexPath configuration:^(id cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    
    if (!_isLoading) {
        
        Document *document = _documentData[section];
        
        [self performSegueWithIdentifier:@"ShowDocumentDetail" sender:@{@"url": document.url, @"title": document.department}];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowDocumentDetail"]) {
        
        NSDictionary *data = sender;
        
        DocumentDetailViewController *ddvc = segue.destinationViewController;
        
        ddvc.url = data[@"url"];
        
        ddvc.title = data[@"title"];
    }
}




#pragma mark - OA

- (void)refreshControlDidPull
{
    [self oa];
    [MobClick event:@"More_OA"];
}

- (void)oa
{
    if (!_isLoading) {
        
        _isLoading = YES;
    
        // ActivityIndicator
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        // Request
        [self sendOaRequest];
    }
}



- (void)sendOaRequest
{
    // ud
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud valueForKey:@"USERNAME"];
    NSString *token = [ud valueForKey:@"USER_TOKEN"];
    
    // post data
    NSDictionary *postData = @{
                               @"username": username,
                               @"token": token,
                               @"pageindex": @"0",
                               };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", global_host, oa_url] parameters:postData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
        //        NSLog(@"连接服务器 - 成功 - %@", responseObject);
        NSLog(@"连接服务器 - 成功");
        [self parseOaResponseObject:responseObject];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSLog(@"连接服务器 - 失败 - %@", error);
        [self showHUDWithText:global_connection_failed andHideDelay:1.0];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        _isLoading = NO;
        [self.refreshControl endRefreshing];
    }];
}


- (void)parseOaResponseObject:(id)responseObject
{
    if ([responseObject[@"ERROR"] isEqualToString:@"wrong token"]) {
        // wrong token
        [self showHUDWithText:global_connection_wrong_token andHideDelay:1.6];
        [self performSelector:@selector(logout) withObject:nil afterDelay:1.6];
        
    } else if ([responseObject[@"ERROR"] isEqualToString:@"invalid input"]) {
        // 未知错误
        [self showHUDWithText:global_connection_failed andHideDelay:1.0];
        
    } else {
        // 成功
        
        NSMutableArray *documentData = [[ClassParser sharedInstance] parseDocumentData:responseObject];
        
        _documentData = documentData;
        
        _pageindex = 0;
        
        [self.tableView reloadData];
    }
    
    _isLoading = NO;
    [self.refreshControl endRefreshing];
}


#pragma mark - loading more

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ((scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y < self.tableView.tableFooterView.bounds.size.height) && (!_isLoading)) {
        [self moreOa];
    }
}


- (void)moreOa
{
    if (!_isLoading) {
        
        _isLoading = YES;
        
        [(DocumentFooterView *)self.tableView.tableFooterView showLoading];
        
        // ActivityIndicator
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        // Request
        [self sendMoreOaRequest];
    }
}



- (void)sendMoreOaRequest
{
    // ud
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud valueForKey:@"USERNAME"];
    NSString *token = [ud valueForKey:@"USER_TOKEN"];
    
    // post data
    NSDictionary *postData = @{
                               @"username": username,
                               @"token": token,
                               @"pageindex": [NSNumber numberWithInteger:_pageindex + 1],
                               };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", global_host, oa_url] parameters:postData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
        NSLog(@"连接服务器 - 成功");
        [self parseMoreOaResponseObject:responseObject];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSLog(@"连接服务器 - 失败 - %@", error);
        [self showHUDWithText:global_connection_failed andHideDelay:1.0];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self restoreState];
    }];
}


- (void)parseMoreOaResponseObject:(id)responseObject
{
    if ([responseObject[@"ERROR"] isEqualToString:@"wrong token"]) {
        
        // wrong token
        [self showHUDWithText:global_connection_wrong_token andHideDelay:1.6];
        [self performSelector:@selector(logout) withObject:nil afterDelay:1.6];
        
    } else if ([responseObject[@"ERROR"] isEqualToString:@"invalid input"]) {
        
        // 未知错误
        [self showHUDWithText:global_connection_failed andHideDelay:1.0];
        [self performSelector:@selector(restoreState) withObject:nil afterDelay:1.0];
        
    } else {
        // 成功
        
        NSMutableArray *newDocumentData = [[ClassParser sharedInstance] parseDocumentData:responseObject];
        
        [_documentData addObjectsFromArray:newDocumentData];
        
        _pageindex += 1;
        
        [self.tableView reloadData];
        
        [(DocumentFooterView *)self.tableView.tableFooterView hideLoading];
        
        _isLoading = NO;
    }
}



- (void)restoreState
{
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height-self.tableView.frame.size.height-self.tableView.tableFooterView.frame.size.height) animated:NO];
    [(DocumentFooterView *)self.tableView.tableFooterView hideLoading];
    _isLoading = NO;
}








// Log Out
- (void)logout
{
    [self logoutClearData];
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)logoutClearData
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    // ud
    [ud setValue:nil forKey:@"USER_TOKEN"];
    [ud setValue:nil forKey:@"YEAR_AND_SEMESTER"];
    [ud setValue:nil forKey:@"NICKNAME"];
}


#pragma mark - HUD

- (void)showHUDWithText:(NSString *)string andHideDelay:(NSTimeInterval)delay {
    
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    
    if (self.navigationController.view) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = string;
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:delay];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
















