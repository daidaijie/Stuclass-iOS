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

static NSString *cell_id = @"HomeworkTableViewCell";

static NSString *homework_url = @"http://10.22.27.65/api/course_info/0"; // homework - 0

static const CGFloat kHeightForPostButton = 52;

static const CGFloat kHeightForSectionHeader = 8.0;

@interface HomeworkViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UIButton *emptyView;

@property (strong, nonatomic) NSMutableArray *homeworkData;

@property (strong, nonatomic) UIView *sectionHeaderView;

@property (assign, nonatomic) BOOL hasLoadedFirstly;

@property (assign, nonatomic) BOOL isLoading;

@property (strong, nonatomic) NSString *number;

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
    // tableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 64 - global_BarViewHeight - kHeightForPostButton) style:UITableViewStylePlain];
    
    self.tableView.fd_debugLogEnabled = NO;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.backgroundColor = TABLEVIEW_BACKGROUN_COLOR;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    
    // emptyView
    self.emptyView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height)];
    
    self.emptyView.backgroundColor = TABLEVIEW_BACKGROUN_COLOR;
    
    UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.emptyView.frame.size.width, 50)];
    emptyLabel.center = CGPointMake(self.emptyView.frame.size.width / 2, self.emptyView.frame.size.height / 2 + 25);
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.textColor = MAIN_COLOR;
    emptyLabel.text = @"<暂时没有作业信息，点击刷新 />";
    [self.emptyView addSubview:emptyLabel];
    
    UIImageView *emptyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    emptyImageView.center = CGPointMake(self.emptyView.frame.size.width / 2, self.emptyView.frame.size.height / 2 - 40);
    emptyImageView.image = [UIImage imageNamed:@"icon-empty"];
    [self.emptyView addSubview:emptyImageView];
    
    [self.emptyView addTarget:self action:@selector(tapToGetHomework) forControlEvents:UIControlEventTouchUpInside];
    
    [self.tableView addSubview:self.emptyView];
    
    
    
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
    return self.sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeightForSectionHeader;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    self.emptyView.hidden = (self.homeworkData.count > 0);
    return self.homeworkData.count;
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
    Homework *homework = self.homeworkData[indexPath.section];
    
//    cell.publisherLabel.text = [NSString stringWithFormat:@"%@发布的作业信息:", homework.publisher];
    cell.publisherLabel.text = homework.publisher;
    cell.dateLabel.text = [self getTimeStrWithTimeFrom1970:homework.pub_time];
    cell.contentLabel.text = homework.content;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:cell_id cacheByIndexPath:indexPath configuration:^(id cell) {
            [self configureCell:cell atIndexPath:indexPath];
    }];
}


#pragma mark - Event

- (void)buttonPress
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    HomeworkPostTableViewController *hptvc = [sb instantiateViewControllerWithIdentifier:@"HomeworkPostTVC"];
    
    [self.navigationController pushViewController:hptvc animated:YES];
}

- (void)getHomeworkDataWithClassNumber:(NSString *)number
{
    if (!_hasLoadedFirstly) {
        
        self.number = number;
        
        // Request
        [self sendRequestWithNumber:number];
        
        _hasLoadedFirstly = YES;
    }
}

- (void)sendRequestWithNumber:(NSString *)number
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    _isLoading = YES;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *dict = [ud valueForKey:@"YEAR_AND_SEMESTER"];
    
    NSInteger year = [dict[@"year"] integerValue];
    NSInteger semester = [dict[@"semester"] integerValue];
    
    // get data
    NSDictionary *getData = @{
                               @"number": number,
                               @"semester": [NSString stringWithFormat:@"%d", semester],
                               @"start_year": [NSString stringWithFormat:@"%d", year],
                               @"end_year": [NSString stringWithFormat:@"%d", year + 1],
                               @"count": @"-1",
                               
                               };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager GET:homework_url parameters:getData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
//        NSLog(@"作业 - 连接服务器 - 成功 - %@", responseObject);
        NSLog(@"作业 - 连接服务器 - 成功");
        [self parseResponseObject:responseObject];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSLog(@"---%@", operation.request);
        NSLog(@"连接服务器 - 失败 - %@", error);
        [self showHUDWithText:@"连接服务器失败" andHideDelay:1.2];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        _isLoading = NO;
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
            [self showHUDWithText:@"获取作业信息失败" andHideDelay:1.2];
        }
        
    } else {
        
        NSArray *data = responseObject[@"homework"];
        
        NSMutableArray *homeworkData = [NSMutableArray array];
        
        for (NSDictionary *h in data) {
            
            Homework *homework = [[Homework alloc] init];
            
            homework.publisher = h[@"publisher"];
            
            homework.pub_time = [h[@"pub_time"] longLongValue];
            
            homework.content = h[@"content"];
            
            [homeworkData addObject:homework];
        }
        
        self.homeworkData = homeworkData;
        
        [self.tableView reloadData];
        
    }
    
    _isLoading = NO;
}


- (void)tapToGetHomework
{
    if (!_isLoading) {
        
        NSLog(@"点击获取 - 作业");
        [self sendRequestWithNumber:self.number];
    }
}


#pragma mark - Date Method

- (NSString *)getTimeStrWithTimeFrom1970:(long long)pub_time
{
    NSDate *now = [self getCurrentZoneDate:[NSDate date]];
    
    long long now_second = [now timeIntervalSince1970];
    
    long long inteval = now_second - pub_time;
    
    
    if (inteval < 60) {
        return @"1分钟前";
    } else if (inteval >= 60 && inteval < 3600) {
        return [NSString stringWithFormat:@"%llu分钟前", inteval / 60];
    } else if (inteval >= 3600 && inteval < (3600 * 24)) {
        return [NSString stringWithFormat:@"%llu小时前", inteval / 3600];
    } else if (inteval >= (3600 * 24) && inteval < (3600 * 24 * 30)) {
        return [NSString stringWithFormat:@"%llu天前", inteval / 3600 / 24];
    } else if (inteval >= (3600 * 24 * 30) && inteval < (3600 * 24 * 30 * 365)) {
        return [NSString stringWithFormat:@"%llu分钟前", inteval / 3600 / 24 / 30];
    } else {
        return [NSString stringWithFormat:@"%llu年前", inteval / 3600 / 24 / 30 / 365];
    }
    
    
    return @"";
}


- (NSDate *)getCurrentZoneDate:(NSDate *)date {
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    
    return [date dateByAddingTimeInterval:interval];
}


#pragma mark - HUD

- (void)showHUDWithText:(NSString *)string andHideDelay:(NSTimeInterval)delay {
    
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = string;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:delay];
}


@end











