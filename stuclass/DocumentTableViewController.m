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

static const NSUInteger kNumberOfDocuments = 30;


@interface DocumentTableViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) UIView *sectionHeaderView;

@property (nonatomic) BOOL isLoadingMore;

@property (assign, nonatomic) NSInteger pageindex;

@property (assign, nonatomic) NSUInteger count;

@property (strong, nonatomic) UILabel *startLabel;
@property (strong, nonatomic) UIImageView *startImageView;

@end


@implementation DocumentTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupBarBackButton];
    
    [self setupTableView];
    
    [self oa];

    _pageindex = 1;
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
    
    self.tableView.userInteractionEnabled = NO;
    
    // start
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    _startLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
    _startLabel.center = CGPointMake(width / 2, height / 2 - 20);
    _startLabel.textAlignment = NSTextAlignmentCenter;
    _startLabel.textColor = MAIN_COLOR;
    _startLabel.text = @"把我\"拉\"下去刷新";
    
    _startImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 88, 88)];
    _startImageView.center = CGPointMake(width / 2, height / 2 - 80);
    _startImageView.image = [UIImage imageNamed:@"icon-empty-discuss"];
    
    
    [self.tableView addSubview:_startLabel];
    [self.tableView addSubview:_startImageView];
    
    
    // refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlDidPull) forControlEvents:UIControlEventValueChanged];
    
    // FooterView
    DocumentFooterView *footerView = [[DocumentFooterView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 50)];
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
        
    [self performSegueWithIdentifier:@"ShowDocumentDetail" sender:@{@"content": document.content, @"title": document.department}];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowDocumentDetail"]) {
        
        NSDictionary *data = sender;
        
        DocumentDetailViewController *ddvc = segue.destinationViewController;
        
        ddvc.content = data[@"content"];
        
        ddvc.title = data[@"title"];
    }
}


- (void)refreshControlDidPull
{
    [self oa];
    [MobClick event:@"More_OA"];
}

- (void)oa
{
    // Request
    [self sendOaRequest];
}



- (void)sendOaRequest
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    _count = 0;
    
    // get data
    NSDictionary *getData = @{
                              @"row_start": @"1",
                              @"row_end": [NSString stringWithFormat:@"%d", kNumberOfDocuments],
                               };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager GET:[NSString stringWithFormat:@"%@%@", oa_wechat_url, oa_wechat_get_url] parameters:getData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
        NSLog(@"连接服务器 - 成功");
//        NSLog(@"--------%@", responseObject);
        [self parseOaResponseObject:responseObject];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSLog(@"连接服务器 - 失败 - %@", error);
        [self showHUDWithText:global_connection_failed andHideDelay:1.0];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.refreshControl endRefreshing];
        self.tableView.userInteractionEnabled = YES;
    }];
}


- (void)parseOaResponseObject:(id)responseObject
{
    if (responseObject) {
    
        // 成功
        NSMutableArray *documentData = [[ClassParser sharedInstance] parseDocumentData:responseObject];
        
        _documentData = documentData;

        _count += kNumberOfDocuments;
        
        [self.tableView reloadData];
        
        _startLabel.hidden = _startImageView.hidden = YES;
    }
    
    self.tableView.userInteractionEnabled = YES;
    [self.refreshControl endRefreshing];
}


#pragma mark - loading more

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ((scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y < self.tableView.tableFooterView.bounds.size.height) && (_documentData.count > 0) && (!_isLoadingMore)) {
        [self moreOa];
        _isLoadingMore = YES;
    }
}


- (void)moreOa
{
    [(DocumentFooterView *)self.tableView.tableFooterView showLoading];
    
    // ActivityIndicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // Request
    [self sendMoreOaRequest];
}



- (void)sendMoreOaRequest
{
    // get data
    NSDictionary *getData = @{
                              @"row_start": [NSString stringWithFormat:@"%d", _count + 1],
                              @"row_end": [NSString stringWithFormat:@"%d", _count + kNumberOfDocuments],
                               };
    NSLog(@"办公自动化 从%d开始", _count + 1);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager GET:[NSString stringWithFormat:@"%@%@", oa_wechat_url, oa_wechat_get_url] parameters:getData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
        NSLog(@"连接服务器 - 成功");
        [self parseMoreOaResponseObject:responseObject];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSLog(@"连接服务器 - 失败 - %@", error);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        _isLoadingMore = NO;
    }];
}


- (void)parseMoreOaResponseObject:(id)responseObject
{
    if (responseObject) {
        // 成功
        
        NSMutableArray *newDocumentData = [[ClassParser sharedInstance] parseDocumentData:responseObject];
        
        [_documentData addObjectsFromArray:newDocumentData];
        
        _count += kNumberOfDocuments;
        
        [self.tableView reloadData];
        
        [(DocumentFooterView *)self.tableView.tableFooterView hideLoading];
    }
    
    _isLoadingMore = NO;
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
            
            [self showHUDWithText:@"取消成功" andHideDelay:0.8];
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

        [self showHUDWithText:@"添加成功" andHideDelay:0.8];
    }
}


- (void)displayUD
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    NSArray *documentArray = [ud objectForKey:@"DOCUMENTS"];

    for (NSDictionary *dict in documentArray) {
        NSLog(@"<><><><><> %@", dict[@"title"]);
    }
}




- (IBAction)searchPress:(id)sender
{
    [self performSegueWithIdentifier:@"DocumentSearch" sender:nil];
}









- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
















