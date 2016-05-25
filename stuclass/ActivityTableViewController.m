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

@interface NSMutableArray (Shuffling)
- (void) shuffle;
@end

@implementation NSMutableArray (Shuffling)
- (void)shuffle
{
    int count = [self count];
    for (int i = 0; i < count; ++i) {
        int n = (arc4random() % (count - i)) + i;
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
    m1.content = @"我们将会在下个学期启动校园动态平台，那真的是很棒的！";
    m1.comments = @[@"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @""];
    m1.likes = @[@"", @"", @"", @"", @"", @"", @"", @""];
    
    Message *m2 = [[Message alloc] init];
    m2.nickname = @"强记这不是灯孝妇";
    m2.avatarURL = @"a2";
    m2.content = @"我们已和四十多个社团、组织联系，共同打造汕大最棒的活动信息发布平台！";
    
    Message *m3 = [[Message alloc] init];
    m3.nickname = @"隐藏深山中的鲤鱼姐";
    m3.avatarURL = @"a3";
    m3.content = @"校园动态是一个整合所有与汕大有关的推文的平台！";
    
    NSMutableArray *messageData = [NSMutableArray array];
    [messageData addObject:m1];
    [messageData addObject:m2];
    [messageData addObject:m3];
    
    [messageData shuffle];
    
    ((Message *)messageData[0]).date = @"刚刚（哈哈，现在还点不了呢）";
    ((Message *)messageData[1]).date = @"6分钟前";
    ((Message *)messageData[2]).date = @"6小时前";
    
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
    [_banner setNumberOfImages:3];
    
    for (NSInteger i = 0; i < 3; i++) {
        UIImageView *imageView = _banner.imageViews[i];
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"banner%d.jpg", i + 1]];
    }
    
    // Go
    [_banner activeHeader];
}

- (void)bannerDidPressWithIndex:(NSUInteger)index
{
    NSString *link = @"";
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"了解更多" andMessage:link];
    
    alertView.transitionStyle = SIAlertViewTransitionStyleFade;
    
    [alertView addButtonWithTitle:@"算了" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
    }];
    
    [alertView addButtonWithTitle:@"访问" type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
    }];
    
    [alertView show];
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
    
}

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



