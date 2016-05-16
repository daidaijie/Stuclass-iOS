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
#import "MBProgressHUD.h"
#import <AFNetworking/AFNetworking.h>
#import "JHDater.h"
#import <KVNProgress/KVNProgress.h>
#import "MobClick.h"
#import "UIImageView+WebCache.h"
#import "Message.h"
#import "ScrollManager.h"


static NSString *message_cell_id = @"MessageCell";
static NSString *message_text_cell_id = @"MessageTextCell";

@interface MessageTableViewController ()

@property (strong, nonatomic) NSMutableArray *messageData;

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
    [self setupData];
}

- (void)didFinishRefresh
{
    [self.refreshControl endRefreshing];
}

- (void)setupData
{
    /*
    Message *m1 = [[Message alloc] initWithNickname:@"深山中的一颗丸子" date:@"5分钟前" content:@"我曾经说过我曾经说过我曾经说过" avatarImage:[UIImage imageNamed:@"a1"] contentImages:@[[UIImage imageNamed:@"b1"], [UIImage imageNamed:@"b2"], [UIImage imageNamed:@"b3"]]];
    Message *m2 = [[Message alloc] initWithNickname:@"网络中心" date:@"10分钟前" content:nil avatarImage:[UIImage imageNamed:@"a2"] contentImages:@[[UIImage imageNamed:@"b2"]]];
    Message *m3 = [[Message alloc] initWithNickname:@"你好我是蠢婧" date:@"1小时前" content:@"我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过" avatarImage:[UIImage imageNamed:@"a3"] contentImages:@[[UIImage imageNamed:@"b3"], [UIImage imageNamed:@"b8"]]];
    Message *m4 = [[Message alloc] initWithNickname:@"天哪玛丽莎" date:@"2小时前" content:@"我曾经说过我曾经说过" avatarImage:[UIImage imageNamed:@"a4"] contentImages:nil];
    Message *m5 = [[Message alloc] initWithNickname:@"哈哈哈哈哈啊哈哈哈" date:@"1天前" content:@"我曾经说过我是个蠢才" avatarImage:[UIImage imageNamed:@"a5"] contentImages:nil];
    Message *m6 = [[Message alloc] initWithNickname:@"扎克伯格的纸巾" date:@"1个月前" content:@"我曾经说过我曾经说过我曾经说过我曾经说过我不是个蠢才" avatarImage:[UIImage imageNamed:@"a6"] contentImages:@[[UIImage imageNamed:@"b6"]]];
    
    
    Message *n1 = [[Message alloc] initWithNickname:@"天哪玛丽莎" date:@"1个月前" content:@"我曾经说过我曾经说过我曾经说过" avatarImage:[UIImage imageNamed:@"a2"] contentImages:nil];
    Message *n2 = [[Message alloc] initWithNickname:@"网络中心" date:@"2个月前" content:nil avatarImage:[UIImage imageNamed:@"a2"] contentImages:@[[UIImage imageNamed:@"b2"]]];
    Message *n3 = [[Message alloc] initWithNickname:@"你好我是蠢婧" date:@"1小时前" content:@"我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过我曾经说过" avatarImage:[UIImage imageNamed:@"a3"] contentImages:nil];
    Message *n4 = [[Message alloc] initWithNickname:@"看我的飞机头呢" date:@"2小时前" content:@"我曾经说过我曾经说过" avatarImage:[UIImage imageNamed:@"a4"] contentImages:@[[UIImage imageNamed:@"b1"], [UIImage imageNamed:@"b2"], [UIImage imageNamed:@"b3"]]];
    Message *n5 = [[Message alloc] initWithNickname:@"哈哈哈哈哈啊哈哈哈" date:@"1天前" content:@"我曾经说过" avatarImage:[UIImage imageNamed:@"a5"] contentImages:nil];
    Message *n6 = [[Message alloc] initWithNickname:@"扎克伯格的纸巾" date:@"1个月前" content:@"我曾经说过我曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过曾经说过我曾经说过我曾经说过" avatarImage:[UIImage imageNamed:@"a6"] contentImages:@[[UIImage imageNamed:@"b6"]]];
    
    
    _messageData = [NSMutableArray arrayWithArray:@[m1,m2,n4,m3,m4,m5,m6,n1,n2,n3,n4,n5,n6]];
     
    */
    
    // get data
    NSDictionary *getData = @{
                               @"sort_type": @"2",
                               @"count": @"20",
                               };
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager GET:[NSString stringWithFormat:@"%@%@", global_host, message_url] parameters:getData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
        NSLog(@"消息圈 - 连接服务器 - 成功");
//        NSLog(@"------- %@", responseObject);
        [self parseResponseObject:responseObject];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSLog(@"消息圈 - 连接服务器 - 失败 - %@", error);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self didFinishRefresh];
    }];
}

- (void)parseResponseObject:(NSDictionary *)responseObject
{
    NSArray *postList = responseObject[@"post_list"];
    
    if (postList) {
        
        NSMutableArray *messageData = [NSMutableArray array];
        
        for (NSDictionary *dict in postList) {
            
            NSNumber *post_type = dict[@"post_type"];
            
            if ([post_type isEqualToNumber:@0]) {
            
            Message *message = [[Message alloc] init];
            
                // user
                NSDictionary *userDict = dict[@"user"];
                message.nickname = userDict[@"nickname"];
                message.username = userDict[@"account"];
                message.userid = userDict[@"id"];
                message.avatarURL = [userDict[@"image"] isEqual:[NSNull null]] ? nil : userDict[@"image"];
                
                // data
                message.messageid = dict[@"id"];
                message.content = dict[@"content"];
                NSString *dateStr = [[JHDater sharedInstance] dateStrFromMessageTimeString:dict[@"post_time"]];
                message.date = dateStr;
                
                NSString *jsonStr = dict[@"photo_list_json"];
                
                if (jsonStr == nil || [jsonStr isEqual:[NSNull null]]) {
                    message.imageURLs = nil;
                } else {
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
                    NSArray *photoList = jsonDict[@"photo_list"];
                    
                    NSMutableArray *imageURLs = [NSMutableArray array];
                    for (NSDictionary *dict in photoList) {
                        [imageURLs addObject:dict[@"size_small"]];
                    }
                    message.imageURLs = imageURLs;
                }
                
                // comment
                message.comments = dict[@"comments"];
                message.likes = dict[@"thumb_ups"];
                
                [messageData addObject:message];
            }
        }
        
        _messageData = messageData;
        
        [self.tableView reloadData];
        
    } else {
        [self showHUDWithText:global_connection_failed andHideDelay:0.8];
    }
    [self didFinishRefresh];
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
    return _messageData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Message *message = _messageData[indexPath.section];
    
    if (message.imageURLs == nil || message.imageURLs.count == 0) {
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
    Message *message = _messageData[indexPath.section];
    
    if (message.imageURLs == nil || message.imageURLs.count == 0) {
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
    Message *message = _messageData[indexPath.section];
    
    cell.nameLabel.text = message.nickname;
    cell.contentLabel.text = message.content;
    cell.dateLabel.text = message.date;
    
    // comment & like
    [cell setLike:message.likes.count commentNum:message.comments.count];
    
    // avatar
    
    NSURL *avatarUrl = [NSURL URLWithString:message.avatarURL];
    [cell.avatarImageView sd_setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"default_avatar"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
}

// Image
- (void)configureCell:(MessageTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Message *message = _messageData[indexPath.section];

    cell.nameLabel.text = message.nickname;
    cell.contentLabel.text = message.content;
    cell.dateLabel.text = message.date;
    
    // comment & like
    [cell setLike:message.likes.count commentNum:message.comments.count];
    
    // avatar
    NSURL *avatarUrl = [NSURL URLWithString:message.avatarURL];
    [cell.avatarImageView sd_setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"default_avatar"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    
    cell.tag = indexPath.section;
    [cell setContentImagesWithImageURLs:message.imageURLs];
    [cell setPage:[_manager getpageForKey:[NSString stringWithFormat:@"%i",indexPath.section]]];
    
//    NSLog(@"---------- section %d     index %d", indexPath.section, [_manager getpageForKey:[NSString stringWithFormat:@"%i",indexPath.section]]);
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





