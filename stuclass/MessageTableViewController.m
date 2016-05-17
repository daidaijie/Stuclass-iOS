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
#import "DocumentFooterView.h"


static NSString *message_cell_id = @"MessageCell";
static NSString *message_text_cell_id = @"MessageTextCell";

@interface MessageTableViewController () <UIScrollViewDelegate, SDWebImageManagerDelegate>

@property (strong, nonatomic) NSMutableArray *messageData;

@property (strong, nonatomic) UIView *sectionHeaderView;

@property (strong, nonatomic) ScrollManager *manager;

@property (strong, nonatomic) UILabel *startLabel;
@property (strong, nonatomic) UIImageView *startImageView;

@property (assign, nonatomic) BOOL isLoadingMore;

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
 
    self.tableView.backgroundColor = TABLEVIEW_BACKGROUN_COLOR;
    
    self.tableView.fd_debugLogEnabled = NO;
    
    // sectionHeaderView
    _sectionHeaderView = [[UIView alloc] init];
    _sectionHeaderView.backgroundColor = [UIColor clearColor];
    
    // refreshControl
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl = refreshControl;
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.userInteractionEnabled = NO;
    
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    
    // start
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
    
    // footer
    // FooterView
    DocumentFooterView *footerView = [[DocumentFooterView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 50)];
    self.tableView.tableFooterView = footerView;
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
        [self showHUDWithText:global_connection_failed andHideDelay:0.8];
        self.tableView.userInteractionEnabled = YES;
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
        self.tableView.userInteractionEnabled = YES;
        _startLabel.hidden = _startImageView.hidden = YES;
        
    } else {
        [self showHUDWithText:global_connection_failed andHideDelay:0.8];
        self.tableView.userInteractionEnabled = YES;
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

// more
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y < self.tableView.tableFooterView.bounds.size.height && (_messageData.count > 0) && !_isLoadingMore) {
        [self getMoreMessages];
        _isLoadingMore = YES;
        [(DocumentFooterView *)self.tableView.tableFooterView showLoading];
//        NSLog(@"-------");
    }
}

- (void)getMoreMessages
{
    Message *lastMessage = [_messageData lastObject];
    
    // get data
    NSDictionary *getData = @{
                              @"sort_type": @"2",
                              @"count": @"20",
                              @"before_id": lastMessage.messageid,
                              };
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager GET:[NSString stringWithFormat:@"%@%@", global_host, message_url] parameters:getData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
        NSLog(@"消息圈 - 更多 - 连接服务器 - 成功");
        //        NSLog(@"------- %@", responseObject);
        [self parseMoreResponseObject:responseObject];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSLog(@"消息圈 - 更多 - 连接服务器 - 失败 - %@", error);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self showHUDWithText:global_connection_failed andHideDelay:0.8];
        self.tableView.userInteractionEnabled = YES;
        [self didFinishRefresh];
        [self restoreState];
    }];
}




- (void)parseMoreResponseObject:(NSDictionary *)responseObject
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
        
        [_messageData addObjectsFromArray:messageData];
        
        [self.tableView reloadData];
        
        [(DocumentFooterView *)self.tableView.tableFooterView hideLoading];
        
        _isLoadingMore = NO;
        
    } else {
        [self showHUDWithText:global_connection_failed andHideDelay:0.8];
        [self restoreState];
    }
    [self didFinishRefresh];
}

- (void)restoreState
{
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height-self.tableView.frame.size.height - self.tableView.tableFooterView.frame.size.height) animated:NO];
    [(DocumentFooterView *)self.tableView.tableFooterView hideLoading];
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




@end





