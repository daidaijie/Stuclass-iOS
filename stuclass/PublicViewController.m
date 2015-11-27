//
//  PublicViewController.m
//  stuclass
//
//  Created by JunhaoWang on 11/23/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "PublicViewController.h"
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
#import <KVNProgress/KVNProgress.h>

static NSString *cell_id = @"DiscussTableViewCell";

static NSString *discuss_url = @"/api/course_info/1"; // discuss - 1

static NSString *discuss_delete_url = @"/api/v1.0/delete/1";

static const CGFloat kHeightForSectionHeader = 8.0;

@interface PublicViewController () <UITableViewDelegate, UITableViewDataSource, DiscussTableViewCellDelegate, UIActionSheetDelegate, DiscussPostTableViewControllerDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) UIButton *emptyView;

@property (strong, nonatomic) NSMutableArray *discussData;

@property (strong, nonatomic) UIView *sectionHeaderView;

@property (assign, nonatomic) BOOL hasLoadedFirstly;

@property (assign, nonatomic) BOOL isLoading;

// delete
@property (assign, nonatomic) NSInteger delete_id;

@property (assign, nonatomic) NSInteger delete_section;

// copy
@property (assign, nonatomic) NSInteger copy_section;

@end


@implementation PublicViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupBackBarButton];
    [self initTableView];
    
    [self getDiscussData];
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
    _emptyView = [[UIButton alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
    
    _emptyView.backgroundColor = TABLEVIEW_BACKGROUN_COLOR;
    
    UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _emptyView.frame.size.width, 50)];
    emptyLabel.center = CGPointMake(_emptyView.frame.size.width / 2, _emptyView.frame.size.height / 2 + 25);
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.textColor = MAIN_COLOR;
    emptyLabel.text = @"目测都在潜水，点我刷新";
    [_emptyView addSubview:emptyLabel];
    
    UIImageView *emptyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    emptyImageView.center = CGPointMake(_emptyView.frame.size.width / 2, _emptyView.frame.size.height / 2 - 40);
    emptyImageView.image = [UIImage imageNamed:@"icon-empty-discuss"];
    [_emptyView addSubview:emptyImageView];
    
    [_emptyView addTarget:self action:@selector(tapToGetDiscuss) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_emptyView];
    
    
    // tableView
    _tableView = [[UITableView alloc] initWithFrame:_emptyView.frame style:UITableViewStylePlain];
    
    _tableView.fd_debugLogEnabled = NO;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.backgroundColor = TABLEVIEW_BACKGROUN_COLOR;
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:_tableView];
    
    // refresh control
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refreshControlDidPull) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    
    // footer
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 8)];
    _tableView.tableFooterView = footerView;
    
    UINib *nib = [UINib nibWithNibName:cell_id bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:cell_id];
    
    [self.view addSubview:_tableView];
    
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
    _tableView.hidden = !(_discussData.count > 0);
    return _discussData.count;
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
    Discuss *discuss = _discussData[indexPath.section];
    
//    cell.publisherLabel.text = [NSString stringWithFormat:@"%@ 说:", [discuss.nickname isEqual:[NSNull null]] ? discuss.publisher : discuss.nickname];
    cell.publisherLabel.text = [NSString stringWithFormat:@"%@ 说:", discuss.nickname];
    
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
    
    NSInteger section = [_tableView indexPathForCell:cell].section;
    
    Discuss *d = _discussData[section];
    NSString *cellUsername = d.publisher;
    
    BOOL isRoot = [username isEqualToString:@"14xfdeng"] || [username isEqualToString:@"14jhwang"];
    
    if ((isRoot || [cellUsername isEqualToString:username]) && !_isLoading) {
        UIActionSheet *actionSheet1 = [[UIActionSheet alloc] initWithTitle:cellUsername delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:@"复制", nil];
        actionSheet1.tag = 1;
        
        _delete_id = d.discuss_id;
        _delete_section = section;
        _copy_section = section;
        
        [actionSheet1 showInView:self.view];
    } else {
        UIActionSheet *actionSheet2 = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"复制", nil];
        actionSheet2.tag = 2;
        
        _copy_section = section;
        
        [actionSheet2 showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1) {
        
        if (buttonIndex == 0) {
            [self deleteDiscussWithID:_delete_id andSection:_delete_section];
            _delete_id = 0;
            _delete_section = 0;
        } else if (buttonIndex == 1) {
            [self copyContentAtSection:_copy_section];
        }
        
    } else if (actionSheet.tag == 2) {
        
        if (buttonIndex == 0) {
            [self copyContentAtSection:_copy_section];
        }
    }
}

- (void)copyContentAtSection:(NSInteger)section
{
    DiscussTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    [UIPasteboard generalPasteboard].string = cell.contentLabel.text;
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
        [self showHUDWithText:global_connection_failed andHideDelay:global_hud_delay];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}


- (void)parseDeleteResponseObject:(NSDictionary *)responseObject discussID:(NSInteger)discuss_id Section:(NSInteger)discuss_section
{
    NSLog(@"删除讨论id - %d", discuss_id);
    
    NSString *errorStr = responseObject[@"ERROR"];
    
    if (errorStr) {
        
        if ([errorStr isEqualToString:@"not authorized: wrong token"]) {
            
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            [self showHUDWithText:global_connection_wrong_token andHideDelay:1.6];
            [self performSelector:@selector(logout) withObject:nil afterDelay:1.6];
            
        } else {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            [self showHUDWithText:@"删除失败，请重试" andHideDelay:1.0];
        }
        
    } else {
        
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        [self showHUDWithText:@"删除成功" andHideDelay:1.0];
        
        [_tableView beginUpdates];
        [_discussData removeObjectAtIndex:discuss_section];
        [_tableView deleteSections:[NSIndexSet indexSetWithIndex:discuss_section] withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];
        
    }
}


#pragma mark - Event

- (IBAction)postItemPress:(id)sender
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    DiscussPostTableViewController *dptvc = [sb instantiateViewControllerWithIdentifier:@"DiscussPostTVC"];
    
//    dptvc.dvc = _dvc;
    dptvc.isPublic = YES;
    
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
    
    // get data
    NSDictionary *getData = @{
                              @"number": @"0",
                              @"semester": @"0",
                              @"start_year": @"0",
                              @"end_year": @"0",
                              @"count": @"400",
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
        [self showHUDWithText:global_connection_failed andHideDelay:global_hud_delay];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        _isLoading = NO;
        [_refreshControl endRefreshing];
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
            
            Discuss *discuss = [[Discuss alloc] init];
            
            discuss.publisher = d[@"publisher"];
            
            discuss.nickname = d[@"publisher_nickname"];
            
            discuss.pub_time = [d[@"time"] longLongValue];
            
            discuss.content = d[@"content"];
            
            discuss.discuss_id = [d[@"id"] integerValue];
            
            [discussData addObject:discuss];
        }
        
        _discussData = discussData;
        
        [_tableView reloadData];
        
    }
    
    _isLoading = NO;
    [_refreshControl endRefreshing];
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
    
    if (!_discussData) {
        _discussData = [NSMutableArray array];
    }
    
    [_discussData insertObject:discuss atIndex:0];
    
    [_tableView reloadData];
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





