//
//  DocumentSearchTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 5/14/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "DocumentSearchTableViewController.h"
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

static const NSUInteger kNumberOfDocuments = 100;

@interface DocumentSearchTableViewController () <UISearchBarDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *documentData;

@property (strong, nonatomic) UIView *sectionHeaderView;

@property (assign, nonatomic) BOOL isSecondTime;

@end

@implementation DocumentSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBackBarButton];
    [self setupTableView];
    [self setupSearchBar];
}

#pragma mark - setup
- (void)setupBackBarButton
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
}


- (void)setupSearchBar
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(40, 0, self.view.bounds.size.width - 62, 44)];
    
    self.searchBar.placeholder = @"搜索";
    self.searchBar.text = @"";
    self.searchBar.showsCancelButton = YES;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    
    UITextField *field = [self.searchBar valueForKey:@"searchField"];
    field.textColor = [UIColor whiteColor];
    
    
    self.searchBar.delegate = self;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.searchBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!_isSecondTime) {
        _isSecondTime = YES;
        [self.searchBar becomeFirstResponder];
    }
}

- (void)setupTableView
{
    self.tableView.backgroundColor = TABLEVIEW_BACKGROUN_COLOR;
    
    self.tableView.fd_debugLogEnabled = NO;
    
    // FooterView
    DocumentFooterView *footerView = [[DocumentFooterView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 8)];
    self.tableView.tableFooterView = footerView;
    
    // sectionHeaderView
    _sectionHeaderView = [[UIView alloc] init];
    _sectionHeaderView.backgroundColor = [UIColor clearColor];
    
    // longPress
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPressGesture.minimumPressDuration = 0.4;
    [self.tableView addGestureRecognizer:longPressGesture];
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
    
    Document *document = _documentData[section];
    
    [self performSegueWithIdentifier:@"ShowDocumentDetail" sender:@{@"content": document.content, @"department": document.department, @"title": document.title, @"date": document.date}];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowDocumentDetail"]) {
        
        NSDictionary *data = sender;
        
        DocumentDetailViewController *ddvc = segue.destinationViewController;
        
        ddvc.content = data[@"content"];
        ddvc.oa_title = data[@"title"];
        ddvc.date = data[@"date"];
        ddvc.title = data[@"department"];
    }
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self oa];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}


- (void)oa
{
    // Request
    [self sendOaRequest];
}

- (void)sendOaRequest
{
    [self.searchBar resignFirstResponder];
    [KVNProgress showWithStatus:@"正在搜索"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // post data
    NSDictionary *postData = @{
                              @"row_start": @"1",
                              @"row_end": [NSString stringWithFormat:@"%d", kNumberOfDocuments],
                              @"keyword": _searchBar.text,
                              @"subcompany_id": @"0",
                              @"token": @"",
                              };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager POST:@"http://wechat.stu.edu.cn/webservice_oa/oa_/GetDoc" parameters:postData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
        NSLog(@"搜索OA - 连接服务器 - 成功");
        [self parseOaResponseObject:responseObject];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSLog(@"搜索OA - 连接服务器 - 失败 - %@", error);
        [KVNProgress showErrorWithStatus:global_connection_failed];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}


- (void)parseOaResponseObject:(id)responseObject
{
    if (responseObject) {
        
        NSArray *data = responseObject;
        
        if (data.count > 0) {
            // 成功
            NSMutableArray *documentData = [[ClassParser sharedInstance] parseDocumentData:responseObject];
            
            _documentData = documentData;
            
            [self.tableView reloadData];
            
            [KVNProgress dismiss];
        } else {
            // 没有
            [KVNProgress showErrorWithStatus:@"找不到相关条目"];
            
            _documentData = nil;
            
            [self.tableView reloadData];
        }
        
    } else {
        [KVNProgress showErrorWithStatus:global_connection_failed];
    }
}


- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [gesture locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
        if (indexPath == nil) return ;
        // 显示ActionSheet
        NSUInteger section = indexPath.section;
        // 检查是否存在该记录
        Document *document = _documentData[section];
        BOOL isExist = [self checkIfDocumentExistsByDocumentName:document.title];
        
        NSString *title = isExist ? @"取消收藏" : @"添加收藏";
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:title otherButtonTitles:nil];
        
        actionSheet.tag = (isExist ? 10000 : 0) + section;
        
        [actionSheet showInView:self.view];
    }
}


- (BOOL)checkIfDocumentExistsByDocumentName:(NSString *)documentName
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSArray *documentArray = [ud objectForKey:@"DOCUMENTS"];
    
    for (NSDictionary *document in documentArray) {
        if ([documentName isEqualToString:document[@"title"]]) {
            // 找到相同
            return YES;
        }
    }
    
    return NO;
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (actionSheet.tag >= 10000 && buttonIndex == 0) {
        // 取消收藏
        
        NSUInteger section = actionSheet.tag - 10000;
        
        Document *d = _documentData[section];
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        
        NSMutableArray *documentArray = [NSMutableArray arrayWithArray:[ud objectForKey:@"DOCUMENTS"]];
        
        NSInteger flag = -1;
        
        for (NSInteger i = 0; i < documentArray.count; i++) {
            
            NSDictionary *document = documentArray[i];
            
            if ([document[@"title"] isEqualToString:d.title]) {
                // 找到
                flag = i;
                break;
            }
        }
        
        if (flag != -1) {
            [documentArray removeObjectAtIndex:flag];
            [ud setObject:documentArray forKey:@"DOCUMENTS"];
            
            [self showHUDWithText:@"取消成功" andHideDelay:global_hud_short_delay];
        }
        
        //        [self displayUD];
        
    } else if (actionSheet.tag < 10000 && buttonIndex == 0) {
        // 添加收藏
        
        NSUInteger section = actionSheet.tag;
        
        Document *d = _documentData[section];
        
        NSMutableDictionary *document = [NSMutableDictionary dictionary];
        
        document[@"department"] = d.department;
        document[@"title"] = d.title;
        document[@"date"] = d.date;
        document[@"content"] = d.content;
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        
        NSMutableArray *documentArray = [NSMutableArray arrayWithArray:[ud objectForKey:@"DOCUMENTS"]];
        
        [documentArray addObject:document];
        
        [ud setObject:documentArray forKey:@"DOCUMENTS"];
        
        //        [self displayUD];
        
        [self showHUDWithText:@"添加成功" andHideDelay:global_hud_short_delay];
    }
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
