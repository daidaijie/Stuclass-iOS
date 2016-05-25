//
//  ActivityViewController.m
//  stuclass
//
//  Created by JunhaoWang on 4/9/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "ActivityTableViewController.h"
#import "MBProgressHUD.h"
#import "Define.h"
#import "MobClick.h"
#import "HeaderCollectionReusableView.h"
#import "Message.h"
#import "MessageTableViewCell.h"
#import <UITableView_FDTemplateLayoutCell/UITableView+FDTemplateLayoutCell.h>
#import "DocumentFooterView.h"
#import <SIAlertView/SIAlertView.h>
#import <AFNetworking/AFNetworking.h>

@interface NSMutableArray (Shuffling)
- (void) shuffle;
@end

@implementation NSMutableArray (Shuffling)
- (void)shuffle
{
    NSUInteger count = self.count;
    for (NSUInteger i = 0; i < count; ++i) {
        NSUInteger n = (arc4random() % (count - i)) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}
@end

static NSString *message_cell_id = @"MessageTableViewCell";

static const CGFloat kHeightForSectionHeader = 8.5;

@interface ActivityTableViewController () <BannerDelegate>

@property (strong, nonatomic) UIView *sectionHeaderView;

@property (strong, nonatomic) HeaderCollectionReusableView *banner;

@property (strong, nonatomic) NSMutableArray *messageData;

@end

@implementation ActivityTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupBackBarButton];
    [self setupTableView];
    [self setupData];
    
    [self setupBanner];
    
    [self sendRequest];
    
    
    [MobClick event:@"Tabbar_Activity"];
}


- (void)setupBackBarButton
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
    
    // sectionHeaderView
    _sectionHeaderView = [[UIView alloc] init];
    _sectionHeaderView.backgroundColor = [UIColor clearColor];
    
    // FooterView
    DocumentFooterView *footerView = [[DocumentFooterView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, kHeightForSectionHeader)];
    self.tableView.tableFooterView = footerView;
    
    // refreshControl
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl = refreshControl;
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

- (void)setupData
{
    Message *m1 = [[Message alloc] init];
    m1.nickname = @"喜欢喝果粒橙的猫呆汪";
    m1.avatarURL = @"a1";
    m1.comments = @[@"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @""];
    m1.likes = @[@"", @"", @"", @"", @"", @"", @"", @""];
    
    Message *m2 = [[Message alloc] init];
    m2.nickname = @"强记这不是灯孝妇";
    m2.avatarURL = @"a2";
    
    Message *m3 = [[Message alloc] init];
    m3.nickname = @"呆呆的李宇杰";
    m3.avatarURL = @"a3";
    
    NSMutableArray *messageData = [NSMutableArray array];
    [messageData addObject:m1];
    [messageData addObject:m2];
    [messageData addObject:m3];
    
    [messageData shuffle];
    
    ((Message *)messageData[0]).date = @"刚刚（哈哈，现在还不能用呢）";
    ((Message *)messageData[1]).date = @"6分钟前";
    ((Message *)messageData[2]).date = @"6小时前";
    
    ((Message *)messageData[0]).content = @"我们将会在下个学期启动校园动态平台，那真的是很棒的！(认真脸)";
    ((Message *)messageData[1]).content = @"40多个社团组织入驻课程表，全方面覆盖汕大的所有活动，共同打造汕大最棒的活动信息发布平台！";
    ((Message *)messageData[2]).content = @"校园动态将整合所有与汕大有关的推文！不用看海报，不用怕漏了组织！";
    
    _messageData = messageData;
}

- (void)setupBanner
{
    // Banner
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    _banner = [[HeaderCollectionReusableView alloc] initWithFrame:CGRectMake(0, 0, width, width * 9.0 / 16)];
    _banner.delegate = self;
    self.tableView.tableHeaderView = _banner;
    self.tableView.sectionHeaderHeight = _banner.bounds.size.height;
    
    // Setup
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSArray *banners = [ud objectForKey:@"BANNER_DATA"];
    if (banners == nil) {
        // init
        banners = @[@{@"url":@"", @"link":@"", @"description":@""}, @{@"url":@"", @"link":@"", @"description":@""}, @{@"url":@"", @"link":@"", @"description":@""}];
        [ud setObject:banners forKey:@"BANNER_DATA"];
    }
    [_banner setImages:banners];
    
    // Go
    [_banner activeHeader];
}

- (void)bannerDidPressWithIndex:(NSUInteger)index
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSArray *banners = [ud objectForKey:@"BANNER_DATA"];
    
    NSDictionary *dict = banners[index];
    
    NSString *description = dict[@"description"];
    NSString *link = dict[@"link"];
    
    if (description.length > 0) {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"了解更多" andMessage:description];
        
        alertView.transitionStyle = SIAlertViewTransitionStyleFade;
        
        [alertView addButtonWithTitle:@"算了" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
        }];
        
        [alertView addButtonWithTitle:@"瞧一瞧" type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
        }];
        
        [alertView show];
    }
}


#pragma mark - TableView Delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _sectionHeaderView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeightForSectionHeader;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _messageData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:message_cell_id];
    [self configureTextCell:cell atIndexPath:indexPath];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:message_cell_id cacheByIndexPath:indexPath configuration:^(MessageTableViewCell *cell) {
        [self configureTextCell:cell atIndexPath:indexPath];
    }];
}

// Text
- (void)configureTextCell:(MessageTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Message *message = _messageData[indexPath.section];
    
    cell.tag = indexPath.section;
    
    cell.nameLabel.text = message.nickname;
    cell.contentLabel.text = message.content;
    cell.dateLabel.text = message.date;
    cell.userInteractionEnabled = NO;
    
    // comment & like
    [cell setLike:message.likes.count commentNum:message.comments.count];
    
    // avatar
    cell.avatarImageView.image = [UIImage imageNamed:message.avatarURL];
}

- (void)refresh
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self sendRequest];
}

- (void)sendRequest
{
    // get data
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager GET:[NSString stringWithFormat:@"%@%@", global_host, banner_url] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
        NSLog(@"Banner - 连接服务器 - 成功");
        [self parseBannerResponseObject:responseObject];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.refreshControl endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSLog(@"Banner - 连接服务器 - 失败 - %@", error);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.refreshControl endRefreshing];
    }];
}

- (void)parseBannerResponseObject:(NSDictionary *)responseObject
{
    NSDictionary *latest = responseObject[@"latest"];
    NSArray *notifications = latest[@"notifications"];
    
    NSMutableArray *banners = [NSMutableArray array];
    
    for (NSDictionary *dict in notifications) {
//        NSLog(@"%@", dict);
        NSDictionary *banner = @{@"url":dict[@"url"], @"link":dict[@"link"], @"description":dict[@"description"]};
        [banners addObject:banner];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:banners forKey:@"BANNER_DATA"];
    
    [_banner setImages:banners];
    
    // Go
    [_banner activeHeader];
}

// jump
- (IBAction)officialaccountPress:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"weixin://dl/officialaccounts"]];
}

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



