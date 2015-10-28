//
//  DiscussViewController.m
//  stuclass
//
//  Created by JunhaoWang on 10/19/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "DiscussViewController.h"
#import "Define.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "DiscussTableViewCell.h"
#import "DiscussPostTableViewController.h"
#import "MBProgressHUD.h"
#import <AFNetworking/AFNetworking.h>
#import "Discuss.h"
#import "JHDater.h"
#import "DetailViewController.h"
#import "ClassBox.h"

static NSString *cell_id = @"DiscussTableViewCell";

static NSString *discuss_url = @"/api/course_info/1"; // discuss - 1

static NSString *discuss_delete_url = @"/api/v1.0/delete/1";

static const CGFloat kHeightForPostButton = 52;

static const CGFloat kHeightForSectionHeader = 8.0;

@interface DiscussViewController () <UITableViewDelegate, UITableViewDataSource, DiscussTableViewCellDelegate, UIActionSheetDelegate, DiscussPostTableViewControllerDelegate>

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) UIButton *emptyView;

@property (strong, nonatomic) NSMutableArray *discussData;

@property (strong, nonatomic) UIView *sectionHeaderView;

@property (assign, nonatomic) BOOL hasLoadedFirstly;

@property (assign, nonatomic) BOOL isLoading;

// delete
@property (assign, nonatomic) NSInteger delete_id;

@property (assign, nonatomic) NSInteger delete_section;

@end


@implementation DiscussViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupBackBarButton];
    [self initTableView];
    [self initButton];
}


#pragma mark - Setup Method

- (void)setupBackBarButton
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
}

- (void)initTableView
{
    // emptyView
    self.emptyView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 64 - global_BarViewHeight - kHeightForPostButton)];
    
    self.emptyView.backgroundColor = TABLEVIEW_BACKGROUN_COLOR;
    
    UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.emptyView.frame.size.width, 50)];
    emptyLabel.center = CGPointMake(self.emptyView.frame.size.width / 2, self.emptyView.frame.size.height / 2 + 25);
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.textColor = MAIN_COLOR;
    emptyLabel.text = @"目测都在潜水，点我刷新";
    [self.emptyView addSubview:emptyLabel];
    
    UIImageView *emptyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    emptyImageView.center = CGPointMake(self.emptyView.frame.size.width / 2, self.emptyView.frame.size.height / 2 - 40);
    emptyImageView.image = [UIImage imageNamed:@"icon-empty-discuss"];
    [self.emptyView addSubview:emptyImageView];
    
    [self.emptyView addTarget:self action:@selector(tapToGetDiscuss) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.emptyView];
    
    
    // tableView
    self.tableView = [[UITableView alloc] initWithFrame:self.emptyView.frame style:UITableViewStylePlain];
    
    self.tableView.fd_debugLogEnabled = NO;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.backgroundColor = TABLEVIEW_BACKGROUN_COLOR;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:self.tableView];
    
    // refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlDidPull) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    
    // footer
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 8)];
    self.tableView.tableFooterView = footerView;
    
    UINib *nib = [UINib nibWithNibName:cell_id bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:cell_id];
    
    [self.view addSubview:self.tableView];
    
    // sectionHeaderView
    self.sectionHeaderView = [[UIView alloc] init];
    self.sectionHeaderView.backgroundColor = [UIColor clearColor];
}

- (void)initButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    button.frame = CGRectMake(0, self.tableView.frame.size.height, self.view.frame.size.width, kHeightForPostButton);
    
    button.titleLabel.font = [UIFont systemFontOfSize:16.0];
    
    [button setTitle:@"吹一下水" forState:UIControlStateNormal];
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    button.backgroundColor = MAIN_COLOR;
    
    button.alpha = 0.95;
    
    [button addTarget:self action:@selector(buttonPress) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
}


#pragma mark - TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeightForSectionHeader;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    self.tableView.hidden = !(self.discussData.count > 0);
    return self.discussData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DiscussTableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:cell_id forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(DiscussTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Discuss *discuss = self.discussData[indexPath.section];
    
    cell.publisherLabel.text = [NSString stringWithFormat:@"%@ 说:", discuss.publisher];
    cell.dateLabel.text = [[JHDater sharedInstance] getTimeStrWithTimeFrom1970:discuss.pub_time];
    cell.contentLabel.text = discuss.content;
    cell.discuss_id = discuss.discuss_id;
    cell.delegate = self;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:cell_id cacheByIndexPath:indexPath configuration:^(id cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}


#pragma mark - DiscussTableViewCellDelegate

- (void)discussTableViewCellDidLongPressOnCell:(UITableViewCell *)cell
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud valueForKey:@"USERNAME"];
    
    NSInteger section = [self.tableView indexPathForCell:cell].section;
    
    Discuss *d = self.discussData[section];
    NSString *cellUsername = d.publisher;
    
    if (([cellUsername isEqualToString:username] || [username isEqualToString:@"14jhwang"] || [username isEqualToString:@"14xfdeng"]) && !_isLoading) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil];
        
        _delete_id = d.discuss_id;
        _delete_section = section;
        
        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self deleteDiscussWithID:_delete_id andSection:_delete_section];
        _delete_id = 0;
        _delete_section = 0;
    }
}

- (void)deleteDiscussWithID:(NSInteger)discuss_id andSection:(NSInteger)discuss_section
{
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    [self sendDeleteRequest:discuss_id Section:discuss_section];
}


- (void)sendDeleteRequest:(NSInteger)discuss_id Section:(NSInteger)discuss_section
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSString *username = [ud valueForKey:@"USERNAME"];
    
    NSString *token = [ud valueForKey:@"USER_TOKEN"];
    
    // delete data
    NSDictionary *deleteData = @{
                               @"user": username,
                               @"token": token,
                               @"resource_id": [NSString stringWithFormat:@"%d", discuss_id],
                              };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager DELETE:[NSString stringWithFormat:@"%@%@", global_host, discuss_delete_url] parameters:deleteData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
        NSLog(@"删除讨论 - 连接服务器 - 成功 - %@", responseObject);
//        NSLog(@"删除讨论 - 连接服务器 - 成功");
        [self parseDeleteResponseObject:responseObject discussID:discuss_id Section:discuss_section];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSLog(@"删除讨论 - 连接服务器 - 失败 - %@", error);
        [self showHUDWithText:@"连接服务器失败" andHideDelay:global_hud_delay];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}


- (void)parseDeleteResponseObject:(NSDictionary *)responseObject discussID:(NSInteger)discuss_id Section:(NSInteger)discuss_section
{
    NSLog(@"删除讨论id - %d", discuss_id);
    
    NSString *errorStr = responseObject[@"ERROR"];
    
    if (errorStr) {
        
        if ([errorStr isEqualToString:@"not authorized: wrong token"]) {
            
            [self logout];
            
        } else {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            [self showHUDWithText:@"删除失败，请重试" andHideDelay:1.0];
        }
        
    } else {
        
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        [self showHUDWithText:@"删除成功" andHideDelay:1.0];
        
        [self.tableView beginUpdates];
        [self.discussData removeObjectAtIndex:discuss_section];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:discuss_section] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
    }
}


#pragma mark - Event

- (void)buttonPress
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    DiscussPostTableViewController *dptvc = [sb instantiateViewControllerWithIdentifier:@"DiscussPostTVC"];
    
    dptvc.dvc = self.dvc;
    
    dptvc.delegate = self;
    
    [self.navigationController pushViewController:dptvc animated:YES];
}

- (void)getDiscussData
{
    if (!_hasLoadedFirstly) {
        
        // Request
        [self sendRequest];
        
        _hasLoadedFirstly = YES;
    }
}

- (void)sendRequest
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    _isLoading = YES;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *dict = [ud valueForKey:@"YEAR_AND_SEMESTER"];
    
    NSInteger year = [dict[@"year"] integerValue];
    NSInteger semester = [dict[@"semester"] integerValue];
    
    // get data
    NSDictionary *getData = @{
                              @"number": self.dvc.classBox.box_number,
                              @"semester": [NSString stringWithFormat:@"%d", semester],
                              @"start_year": [NSString stringWithFormat:@"%d", year],
                              @"end_year": [NSString stringWithFormat:@"%d", year + 1],
                              @"count": @"-1",
                              };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager GET:[NSString stringWithFormat:@"%@%@", global_host, discuss_url] parameters:getData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
//                NSLog(@"讨论 - 连接服务器 - 成功 - %@", responseObject);
        NSLog(@"讨论 - 连接服务器 - 成功");
        [self parseResponseObject:responseObject];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSLog(@"讨论 - 连接服务器 - 失败 - %@", error);
        [self showHUDWithText:@"连接服务器失败" andHideDelay:global_hud_delay];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        _isLoading = NO;
        [self.refreshControl endRefreshing];
    }];
    
}


- (void)parseResponseObject:(NSDictionary *)responseObject
{
    NSString *errorStr = responseObject[@"ERROR"];
    
    if (errorStr) {
        
        if ([errorStr isEqualToString:@"no discussion"] || [errorStr isEqualToString:@"No such class"]) {
            
            NSLog(@"没讨论");
            
        } else {
            NSLog(@"----%@", errorStr);
            [self showHUDWithText:@"获取讨论信息失败" andHideDelay:global_hud_delay];
        }
        
    } else {
        
        NSArray *data = responseObject[@"discussions"];
        
        NSMutableArray *discussData = [NSMutableArray array];
        
        for (NSDictionary *d in data) {
            
            Discuss *dicuss = [[Discuss alloc] init];
            
            dicuss.publisher = d[@"publisher"];
            
            dicuss.pub_time = [d[@"time"] longLongValue];
            
            dicuss.content = d[@"content"];
            
            dicuss.discuss_id = [d[@"id"] integerValue];
            
            [discussData addObject:dicuss];
        }
        
        self.discussData = discussData;
        
        [self.tableView reloadData];
        
    }
    
    _isLoading = NO;
    [self.refreshControl endRefreshing];
}


- (void)tapToGetDiscuss
{
    if (!_isLoading) {
        
        NSLog(@"点击获取 - 讨论");
        [self sendRequest];
    }
}

// Log Out
- (void)logout
{
    [self logutClearData];
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)logutClearData
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    //    NSDictionary *dict = [ud valueForKey:@"YEAR_AND_SEMESTER"];
    
    //    NSInteger year = [dict[@"year"] integerValue];
    //    NSInteger semester = [dict[@"semester"] integerValue];
    
    // CoreData
    //    [[CoreDataManager sharedInstance] deleteClassTableWithYear:year semester:semester];
    
    // ud
    [ud setValue:nil forKey:@"USER_TOKEN"];
    [ud setValue:nil forKey:@"YEAR_AND_SEMESTER"];
}


#pragma mark - Refresh Control

- (void)refreshControlDidPull
{
    if (!_isLoading) {
        NSLog(@"下拉刷新 - 讨论");
        [self sendRequest];
    }
}


#pragma mark - DiscussPostTableViewControllerDelegate

- (void)discussPostTableViewControllerPostSuccessfullyWithDiscuss:(Discuss *)discuss
{
    NSLog(@"讨论 - 增加cell - %@", discuss.content);
    
    if (!self.discussData) {
        self.discussData = [NSMutableArray array];
    }
    
    [self.discussData insertObject:discuss atIndex:0];
    
    [self.tableView reloadData];
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


@end





