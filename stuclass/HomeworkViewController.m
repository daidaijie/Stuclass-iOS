//
//  HomeworkViewController.m
//  stuclass
//
//  Created by JunhaoWang on 10/19/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "HomeworkViewController.h"
#import "Define.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "HomeworkTableViewCell.h"
#import "HomeworkPostTableViewController.h"
#import "MBProgressHUD.h"
#import <AFNetworking/AFNetworking.h>
#import "Homework.h"
#import "JHDater.h"
#import "DetailViewController.h"
#import "ClassBox.h"
#import <KVNProgress/KVNProgress.h>
#import "MobClick.h"

static NSString *cell_id = @"HomeworkTableViewCell";

static const CGFloat kHeightForPostButton = 52;

static const CGFloat kHeightForSectionHeader = 8.0;

@interface HomeworkViewController () <UITableViewDelegate, UITableViewDataSource, HomeworkTableViewCellDelegate, UIActionSheetDelegate, HomeworkPostTableViewControllerDelegate>

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) UIButton *emptyView;

@property (strong, nonatomic) NSMutableArray *homeworkData;

@property (strong, nonatomic) UIView *sectionHeaderView;

@property (assign, nonatomic) BOOL hasLoadedFirstly;

@property (assign, nonatomic) BOOL isLoading;

// delete
@property (assign, nonatomic) NSInteger delete_id;
@property (assign, nonatomic) NSInteger delete_section;

// copy
@property (assign, nonatomic) NSInteger copy_section;

@end


@implementation HomeworkViewController


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
    _emptyView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 64 - global_BarViewHeight - kHeightForPostButton)];
    
    _emptyView.backgroundColor = [UIColor clearColor];
    
    UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _emptyView.frame.size.width, 50)];
    emptyLabel.center = CGPointMake(_emptyView.frame.size.width / 2, _emptyView.frame.size.height / 2 + 25);
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.textColor = MAIN_COLOR;
    emptyLabel.text = @"暂时没有作业，点我刷新";
    [_emptyView addSubview:emptyLabel];
    
    UIImageView *emptyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 92, 92)];
    emptyImageView.center = CGPointMake(_emptyView.frame.size.width / 2, _emptyView.frame.size.height / 2 - 43);
    emptyImageView.image = [UIImage imageNamed:@"icon-empty-homework"];
    [_emptyView addSubview:emptyImageView];
    
    [_emptyView addTarget:self action:@selector(tapToGetHomework) forControlEvents:UIControlEventTouchUpInside];
    
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

- (void)initButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    button.frame = CGRectMake(0, _tableView.frame.size.height, self.view.frame.size.width, kHeightForPostButton);
    
    button.titleLabel.font = [UIFont systemFontOfSize:16.0];
    
    [button setTitle:@"发布新的作业信息" forState:UIControlStateNormal];
    
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
    return _sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeightForSectionHeader;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    _tableView.hidden = !(_homeworkData.count > 0);
    return _homeworkData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeworkTableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:cell_id forIndexPath:indexPath];

    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(HomeworkTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Homework *homework = _homeworkData[indexPath.section];
    
    cell.publisherLabel.text = [NSString stringWithFormat:@"%@ 发布的作业信息:", homework.nickname];
    
    cell.dateLabel.text = [[JHDater sharedInstance] getTimeStrWithTimeFrom1970:homework.pub_time];
    cell.contentLabel.text = homework.content;
    cell.homework_id = homework.homework_id;
    cell.deadlineLabel.text = [NSString stringWithFormat:@"截止时间: %@", homework.deadline.length > 0 ? homework.deadline : @"无"];
    
    cell.delegate = self;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:cell_id cacheByIndexPath:indexPath configuration:^(id cell) {
            [self configureCell:cell atIndexPath:indexPath];
    }];
}


#pragma mark - HomeworkTableViewCellDelegate

- (void)homeworkTableViewCellDidLongPressOnCell:(UITableViewCell *)cell
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud valueForKey:@"USERNAME"];
    
    NSInteger section = [_tableView indexPathForCell:cell].section;
    
    Homework *h = _homeworkData[section];
    NSString *cellUsername = h.publisher;
    
    BOOL isRoot = [username isEqualToString:@"14xfdeng"] || [username isEqualToString:@"14jhwang"];
    
    if (([cellUsername isEqualToString:username] || isRoot) && !_isLoading) {
        UIActionSheet *actionSheet1 = [[UIActionSheet alloc] initWithTitle:cellUsername delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:@"复制", nil];
        actionSheet1.tag = 1;
        
        _delete_id = h.homework_id;
        _delete_section = section;
        _copy_section = section;
        
        [actionSheet1 showInView:self.view];
    } else {
        UIActionSheet *actionSheet2 = [[UIActionSheet alloc] initWithTitle:cellUsername delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"复制", nil];
        actionSheet2.tag = 2;
        
        _copy_section = section;
        
        [actionSheet2 showInView:self.view];
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1) {
        
        if (buttonIndex == 0) {
            [self deleteHomeworkWithID:_delete_id andSection:_delete_section];
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

// copy
- (void)copyContentAtSection:(NSInteger)section
{
    HomeworkTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    [UIPasteboard generalPasteboard].string = cell.contentLabel.text;
}


- (void)deleteHomeworkWithID:(NSInteger)homework_id andSection:(NSInteger)homework_section
{
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    [self sendDeleteRequest:homework_id Section:homework_section];
}


- (void)sendDeleteRequest:(NSInteger)homework_id Section:(NSInteger)homework_section
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSString *username = [ud valueForKey:@"USERNAME"];
    
    NSString *token = [ud valueForKey:@"USER_TOKEN"];
    
    // delete data
    NSDictionary *deleteData = @{
                                 @"user": username,
                                 @"token": token,
                                 @"resource_id": [NSString stringWithFormat:@"%d", homework_id],
                                 };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager DELETE:[NSString stringWithFormat:@"%@%@", global_old_host, homework_delete_url] parameters:deleteData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
        NSLog(@"删除作业 - 连接服务器 - 成功 - %@", responseObject);
        [self parseDeleteResponseObject:responseObject homeworkID:homework_id Section:homework_section];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSLog(@"删除作业 - 连接服务器 - 失败 - %@", error);
        [self showHUDWithText:global_connection_failed andHideDelay:global_hud_delay];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}


- (void)parseDeleteResponseObject:(NSDictionary *)responseObject homeworkID:(NSInteger)homework_id Section:(NSInteger)homework_section
{
    NSLog(@"删除作业id - %d", homework_id);
    
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
        [_homeworkData removeObjectAtIndex:homework_section];
        [_tableView deleteSections:[NSIndexSet indexSetWithIndex:homework_section] withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];
        
        [MobClick event:@"Detail_Delete_Homework"];
    }
}



#pragma mark - Event

- (void)buttonPress
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    HomeworkPostTableViewController *hptvc = [sb instantiateViewControllerWithIdentifier:@"HomeworkPostTVC"];
    
    hptvc.dvc = _dvc;
    
    hptvc.delegate = self;
    
    [self.navigationController pushViewController:hptvc animated:YES];
}

- (void)getHomeworkData
{
    if (!_hasLoadedFirstly) {
        
        // Request
        [self sendRequest];
        
        _hasLoadedFirstly = YES;
    }
    
    [MobClick event:@"Detail_Get_Homework"];
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
                               @"number": _dvc.classBox.box_number,
                               @"semester": [NSString stringWithFormat:@"%d", semester],
                               @"start_year": [NSString stringWithFormat:@"%d", year],
                               @"end_year": [NSString stringWithFormat:@"%d", year + 1],
                               @"count": @"-1",
                               
                               };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager GET:[NSString stringWithFormat:@"%@%@", global_old_host, homework_url] parameters:getData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
        NSLog(@"作业 - 连接服务器 - 成功");
        [self parseResponseObject:responseObject];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSLog(@"作业 - 连接服务器 - 失败 - %@", error);
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
        
        if ([errorStr isEqualToString:@"no homework"] || [errorStr isEqualToString:@"No such class"]) {
            
            NSLog(@"没作业");
            
        } else {
            NSLog(@"----%@", errorStr);
            [self showHUDWithText:@"获取作业信息失败" andHideDelay:global_hud_delay];
        }
        
    } else {
        
        NSArray *data = responseObject[@"homework"];
        
        NSMutableArray *homeworkData = [NSMutableArray array];
        
        for (NSDictionary *h in data) {
            
            Homework *homework = [[Homework alloc] init];
            
            homework.publisher = h[@"publisher"];
            
            homework.nickname = h[@"publisher_nickname"];
            
            homework.pub_time = [h[@"pub_time"] longLongValue];
            
            homework.content = h[@"content"];
            
            homework.deadline = h[@"hand_in_time"];
            
            homework.homework_id = [h[@"id"] integerValue];
            
            [homeworkData addObject:homework];
        }
        
        _homeworkData = homeworkData;
        
        [_tableView reloadData];
        
    }
    
    _isLoading = NO;
    [_refreshControl endRefreshing];
}


- (void)tapToGetHomework
{
    if (!_isLoading) {
        
        NSLog(@"点击获取 - 作业");
        [self sendRequest];
    }
}

// Log Out
- (void)logout
{
    [self logoutClearData];
    [self.navigationController.tabBarController.navigationController popToRootViewControllerAnimated:YES];
    
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
        NSLog(@"下拉刷新 - 作业");
        [self sendRequest];
    }
}


#pragma mark - HomeworkPostTableViewControllerDelegate

- (void)homeworkPostTableViewControllerPostSuccessfullyWithHomework:(Homework *)homework
{
    NSLog(@"作业 - 增加cell - %@", homework.content);
    
    if (!_homeworkData) {
        _homeworkData = [NSMutableArray array];
    }
    
    [_homeworkData insertObject:homework atIndex:0];
    
    [_tableView reloadData];
    
    [MobClick event:@"Detail_Post_Homework"];
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











