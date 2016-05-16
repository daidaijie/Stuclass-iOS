//
//  MessageTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 11/23/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "MessageTableViewController.h"
#import "Define.h"
#import <UITableView_FDTemplateLayoutCell/UITableView+FDTemplateLayoutCell.h>
#import "MessageTableViewCell.h"
#import "MessageTextTableViewCell.h"
#import "DiscussPostTableViewController.h"
#import "MBProgressHUD.h"
#import <AFNetworking/AFNetworking.h>
#import "Discuss.h"
#import "JHDater.h"
#import "DetailViewController.h"
#import "ClassBox.h"
#import <KVNProgress/KVNProgress.h>
#import "MobClick.h"
#import "HeaderCollectionReusableView.h"
#import "UIImageView+WebCache.h"
#import "TestingModel.h"
#import "ScrollManager.h"


static NSString *message_cell_id = @"MessageCell";
static NSString *message_text_cell_id = @"MessageTextCell";

@interface MessageTableViewController ()

@property (strong, nonatomic) NSArray *testingData;

@property (strong, nonatomic) UIView *sectionHeaderView;

@property (strong, nonatomic) ScrollManager *manager;

@end


@implementation MessageTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupBackBarButton];
    
    [self setupTableView];
    
    [self setupData];
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
    _manager = [ScrollManager sharedManager];
    
    self.tableView.fd_debugLogEnabled = NO;
    
    // sectionHeaderView
    _sectionHeaderView = [[UIView alloc] init];
    _sectionHeaderView.backgroundColor = [UIColor clearColor];
    
    // refreshControl
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl = refreshControl;
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

- (void)refresh
{
    [self performSelector:@selector(didFinishRefresh) withObject:nil afterDelay:1.3];
}

- (void)didFinishRefresh
{
    [self.refreshControl endRefreshing];
}

- (void)setupData
{
    TestingModel *m1 = [[TestingModel alloc] initWithNickname:@"深山中的一颗丸子" date:@"5分钟前" content:@"我曾经说过我曾经说过我曾经说过" avatarImage:[UIImage imageNamed:@"a1"] contentImages:@[[UIImage imageNamed:@"b1"], [UIImage imageNamed:@"b2"], [UIImage imageNamed:@"b3"]]];
    TestingModel *m2 = [[TestingModel alloc] initWithNickname:@"网络中心" date:@"10分钟前" content:nil avatarImage:[UIImage imageNamed:@"a2"] contentImages:@[[UIImage imageNamed:@"b2"]]];
    TestingModel *m3 = [[TestingModel alloc] initWithNickname:@"你好我是蠢婧" date:@"1小时前" content:@"我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过" avatarImage:[UIImage imageNamed:@"a3"] contentImages:@[[UIImage imageNamed:@"b3"], [UIImage imageNamed:@"b8"]]];
    TestingModel *m4 = [[TestingModel alloc] initWithNickname:@"天哪玛丽莎" date:@"2小时前" content:@"我曾经说过我曾经说过" avatarImage:[UIImage imageNamed:@"a4"] contentImages:nil];
    TestingModel *m5 = [[TestingModel alloc] initWithNickname:@"哈哈哈哈哈啊哈哈哈" date:@"1天前" content:@"我曾经说过我是个蠢才" avatarImage:[UIImage imageNamed:@"a5"] contentImages:nil];
    TestingModel *m6 = [[TestingModel alloc] initWithNickname:@"扎克伯格的纸巾" date:@"1个月前" content:@"我曾经说过我曾经说过我曾经说过我曾经说过我不是个蠢才" avatarImage:[UIImage imageNamed:@"a6"] contentImages:@[[UIImage imageNamed:@"b6"]]];
    
    
    TestingModel *n1 = [[TestingModel alloc] initWithNickname:@"天哪玛丽莎" date:@"1个月前" content:@"我曾经说过我曾经说过我曾经说过" avatarImage:[UIImage imageNamed:@"a2"] contentImages:nil];
    TestingModel *n2 = [[TestingModel alloc] initWithNickname:@"网络中心" date:@"2个月前" content:nil avatarImage:[UIImage imageNamed:@"a2"] contentImages:@[[UIImage imageNamed:@"b2"]]];
    TestingModel *n3 = [[TestingModel alloc] initWithNickname:@"你好我是蠢婧" date:@"1小时前" content:@"我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过" avatarImage:[UIImage imageNamed:@"a3"] contentImages:nil];
    TestingModel *n4 = [[TestingModel alloc] initWithNickname:@"看我的飞机头呢" date:@"2小时前" content:@"我曾经说过我曾经说过" avatarImage:[UIImage imageNamed:@"a4"] contentImages:@[[UIImage imageNamed:@"b1"], [UIImage imageNamed:@"b2"], [UIImage imageNamed:@"b3"]]];
    TestingModel *n5 = [[TestingModel alloc] initWithNickname:@"哈哈哈哈哈啊哈哈哈" date:@"1天前" content:@"我曾经说过" avatarImage:[UIImage imageNamed:@"a5"] contentImages:nil];
    TestingModel *n6 = [[TestingModel alloc] initWithNickname:@"扎克伯格的纸巾" date:@"1个月前" content:@"我曾经说过我曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过" avatarImage:[UIImage imageNamed:@"a6"] contentImages:@[[UIImage imageNamed:@"b6"]]];
    
    
    _testingData = @[m1,m2,n4,m3,m4,m5,m6,n1,n2,n3,n4,n5,n6];
}


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
    return 8.5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _testingData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TestingModel *model = _testingData[indexPath.section];
    
    if (model.contentImages == nil || model.contentImages.count == 0) {
        // text only
        MessageTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:message_text_cell_id];
        [self configureTextCell:cell atIndexPath:indexPath];
        return cell;
    } else {
        // image
        MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:message_cell_id];
        [self configureCell:cell atIndexPath:indexPath];
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TestingModel *model = _testingData[indexPath.section];
    
    if (model.contentImages == nil || model.contentImages.count == 0) {
        // text only
        return [tableView fd_heightForCellWithIdentifier:message_text_cell_id cacheByIndexPath:indexPath configuration:^(MessageTextTableViewCell *cell) {
            [self configureTextCell:cell atIndexPath:indexPath];
        }];
    } else {
        // image
        return [tableView fd_heightForCellWithIdentifier:message_cell_id cacheByIndexPath:indexPath configuration:^(MessageTableViewCell *cell) {
            [self configureCell:cell atIndexPath:indexPath];
        }];
    }
}

// Text
- (void)configureTextCell:(MessageTextTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    TestingModel *model = _testingData[indexPath.section];
    
    cell.nameLabel.text = model.nickname;
    cell.contentLabel.text = model.content;
    cell.dateLabel.text = model.date;
    cell.avatarImageView.image = model.avatarImage;
}

// Image
- (void)configureCell:(MessageTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    TestingModel *model = _testingData[indexPath.section];

    cell.nameLabel.text = model.nickname;
    cell.contentLabel.text = model.content;
    cell.dateLabel.text = model.date;
    cell.avatarImageView.image = model.avatarImage;
    
    cell.tag = indexPath.section;
    [cell setContentImages:model.contentImages];
    [cell setPage:[_manager getpageForKey:[NSString stringWithFormat:@"%i",indexPath.section]]];
//    NSLog(@"---------- section %d     index %d", indexPath.section, [_manager getpageForKey:[NSString stringWithFormat:@"%i",indexPath.section]]);
}




//- (void)didChangeCurrentIndex:(NSNotification *)notification
//{
//    NSDictionary *userInfo = notification.userInfo;
//    
//    UITableViewCell *cell = userInfo[@"cell"];
//    NSUInteger index = [userInfo[@"index"] integerValue];
//    
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//    
////    TestingModel *model = _testingData[indexPath.section];
//    
//    ((TestingModel *)_testingData[indexPath.section]).currentIndex = index;
//    
//    NSLog(@"section = %d   index = %d", indexPath.section, index);
//    
////    [self.tableView reloadData];
//}


@end





