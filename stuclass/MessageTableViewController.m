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
#import "MessageImageTableViewCell.h"
#import "MBProgressHUD.h"
#import <AFNetworking/AFNetworking.h>
#import "JHDater.h"
#import <KVNProgress/KVNProgress.h>
#import "MobClick.h"
#import "UIImageView+WebCache.h"
#import "Message.h"
#import "ScrollManager.h"
#import "DocumentFooterView.h"
#import "WXApi.h"
#import "ClassParser.h"
#import "IDMPhotoBrowser.h"

static const CGFloat kHeightForSectionHeader = 8.5;

static NSString *message_text_cell_id = @"MessageTextTableViewCell";
static NSString *message_image_cell_id = @"MessageImageTableViewCell";

@interface MessageTableViewController () <UIScrollViewDelegate, SDWebImageManagerDelegate, MessageTableViewCellDelegate, MessageImageTableViewCellDelegate, IDMPhotoBrowserDelegate>

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
 
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 44, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 44, 0);
    
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
        
        _messageData = [[ClassParser sharedInstance] parseMessageData:postList]; ;
        
        [self.tableView reloadData];
        self.tableView.userInteractionEnabled = YES;
        _startLabel.hidden = _startImageView.hidden = YES;
        
    } else {
        [self showHUDWithText:global_connection_failed andHideDelay:0.8];
        self.tableView.userInteractionEnabled = YES;
    }
    [self didFinishRefresh];
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
    
    Message *message = _messageData[indexPath.section];
    
    if (message.imageURLs == nil || message.imageURLs.count == 0) {
        // text only
        MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:message_text_cell_id];
        [self configureTextCell:cell atIndexPath:indexPath];
        return cell;
    } else {
        // image
        MessageImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:message_image_cell_id];
        [self configureImageCell:cell atIndexPath:indexPath];
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = _messageData[indexPath.section];
    
    if (message.imageURLs == nil || message.imageURLs.count == 0) {
        // text only
        return [tableView fd_heightForCellWithIdentifier:message_text_cell_id cacheByIndexPath:indexPath configuration:^(MessageTableViewCell *cell) {
            [self configureTextCell:cell atIndexPath:indexPath];
        }];
    } else {
        // image
        return [tableView fd_heightForCellWithIdentifier:message_image_cell_id cacheByIndexPath:indexPath configuration:^(MessageImageTableViewCell *cell) {
            [self configureImageCell:cell atIndexPath:indexPath];
        }];
    }
}

// Text
- (void)configureTextCell:(MessageTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Message *message = _messageData[indexPath.section];
    
    // delegate
    cell.delegate = self;
    cell.tag = indexPath.section;
    
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
- (void)configureImageCell:(MessageImageTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Message *message = _messageData[indexPath.section];

    // delegate
    cell.delegate = self;
    cell.tag = indexPath.section;
    
    cell.nameLabel.text = message.nickname;
    cell.contentLabel.text = message.content;
    cell.dateLabel.text = message.date;
    
    // comment & like
    [cell setLike:message.likes.count commentNum:message.comments.count];
    
    // avatar
    NSURL *avatarUrl = [NSURL URLWithString:message.avatarURL];
    [cell.avatarImageView sd_setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"default_avatar"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    
    // image
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
        _isLoadingMore = NO;
        [(DocumentFooterView *)self.tableView.tableFooterView showEnd];
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
        _isLoadingMore = NO;
    }
    [self didFinishRefresh];
}


#pragma mark - MessageTableViewCellDelegate

- (void)messageImgViewBgGestureDidPressWithTag:(NSUInteger)tag Index:(NSUInteger)index
{
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:3];
    
    MessageImageTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:tag]];
    
    for (NSUInteger i = 0; i < cell.messageImgView.pageControl.numberOfPages; i++) {
        IDMPhoto *p;
        switch (i) {
            case 0:
                p = [IDMPhoto photoWithImage:cell.messageImgView.imageView1.image];
                break;
            case 1:
                p = [IDMPhoto photoWithImage:cell.messageImgView.imageView2.image];
                break;
            case 2:
                p = [IDMPhoto photoWithImage:cell.messageImgView.imageView3.image];
                break;
            default:
                break;
        }
        p.caption = cell.contentLabel.text;
        [photos addObject:p];
    }
    
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos];
    browser.tag = tag;
    browser.delegate = self;
    browser.displayCounterLabel = YES;
    browser.forceHideStatusBar = YES;
    [browser setInitialPageIndex:index];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [self presentViewController:browser animated:YES completion:^{
        BOOL isSecondTimeSeeImage = [ud boolForKey:@"SECOND_TIME_SEE_IMAGE"];
        if (!isSecondTimeSeeImage) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:browser.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"上、下划退出图片浏览模式";
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:1.2];
            [ud setBool:YES forKey:@"SECOND_TIME_SEE_IMAGE"];
        }
    }];
}

- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize

{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
}

- (void)messageActionViewShareDidPressWithTag:(NSUInteger)tag
{
    Message *message = _messageData[tag];
    
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        
        NSString *title = [NSString stringWithFormat:@"%@", message.content];
        NSString *description = [NSString stringWithFormat:@"%@\n%@\n来自消息圈\n(点击打开App)", message.nickname, message.date];
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"分享" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [controller addAction:[UIAlertAction actionWithTitle:@"微信好友" style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertAction){
            
            //创建发送对象实例
            SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
            sendReq.bText = NO;
            sendReq.scene = 0;
            
            //创建分享内容对象
            WXMediaMessage *urlMessage = [WXMediaMessage message];
            urlMessage.title = title;
            urlMessage.description = description;
            
            MessageTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:tag]];
            UIImage *avatarImg = cell.avatarImageView.image;
            urlMessage.thumbImage = [self reSizeImage:avatarImg toSize:CGSizeMake(150, 150)];
            
            if ([cell isKindOfClass:[MessageImageTableViewCell class]]) {
                // Image
                WXImageObject *imageObj = [WXImageObject object];
                MessageImageTableViewCell *imgCell = (MessageImageTableViewCell *)cell;
                
                UIImage *contentImg;
                
                NSUInteger pageIndex = [_manager getpageForKey:[NSString stringWithFormat:@"%i",tag]];
                switch (pageIndex) {
                    case 0:
                        contentImg = imgCell.messageImgView.imageView1.image;
                        break;
                    case 1:
                        contentImg = imgCell.messageImgView.imageView2.image;
                        break;
                    case 2:
                        contentImg = imgCell.messageImgView.imageView3.image;
                        break;
                    default:
                        break;
                }
                
                imageObj.imageData = UIImageJPEGRepresentation(contentImg, 1.0);
                urlMessage.mediaObject = imageObj;
                
                if (contentImg.size.width > contentImg.size.height)
                    urlMessage.thumbImage = [self reSizeImage:contentImg toSize:CGSizeMake(200, 200 * contentImg.size.height / contentImg.size.width)];
                else
                    urlMessage.thumbImage = [self reSizeImage:contentImg toSize:CGSizeMake(200 / contentImg.size.height * contentImg.size.width, 200)];
            } else {
                // Text
                WXWebpageObject *webObj = [WXWebpageObject object];
                webObj.webpageUrl = jump_app_url;
                urlMessage.mediaObject = webObj;
            }
            
            //完成发送对象实例
            sendReq.message = urlMessage;
            
            //发送分享信息
            [WXApi sendReq:sendReq];
            
        }]];
        
        [controller addAction:[UIAlertAction actionWithTitle:@"微信朋友圈" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *alertAction){
            
            //创建发送对象实例
            SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
            sendReq.bText = NO;
            sendReq.scene = 1;
            
            //创建分享内容对象
            WXMediaMessage *urlMessage = [WXMediaMessage message];
            urlMessage.title = title;
            urlMessage.description = description;
            
            MessageTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:tag]];
            UIImage *avatarImg = cell.avatarImageView.image;
            urlMessage.thumbImage = [self reSizeImage:avatarImg toSize:CGSizeMake(150, 150)];
            
            if ([cell isKindOfClass:[MessageImageTableViewCell class]]) {
                // Image
                WXImageObject *imageObj = [WXImageObject object];
                MessageImageTableViewCell *imgCell = (MessageImageTableViewCell *)cell;
                
                UIImage *contentImg;
                
                NSUInteger pageIndex = [_manager getpageForKey:[NSString stringWithFormat:@"%i",tag]];
                switch (pageIndex) {
                    case 0:
                        contentImg = imgCell.messageImgView.imageView1.image;
                        break;
                    case 1:
                        contentImg = imgCell.messageImgView.imageView2.image;
                        break;
                    case 2:
                        contentImg = imgCell.messageImgView.imageView3.image;
                        break;
                    default:
                        break;
                }
                
                imageObj.imageData = UIImageJPEGRepresentation(contentImg, 1.0);
                urlMessage.mediaObject = imageObj;
                
                if (contentImg.size.width > contentImg.size.height)
                    urlMessage.thumbImage = [self reSizeImage:contentImg toSize:CGSizeMake(200, 200 * contentImg.size.height / contentImg.size.width)];
                else
                    urlMessage.thumbImage = [self reSizeImage:contentImg toSize:CGSizeMake(200 / contentImg.size.height * contentImg.size.width, 200)];
            } else {
                // Text
                WXWebpageObject *webObj = [WXWebpageObject object];
                webObj.webpageUrl = jump_app_url;
                urlMessage.mediaObject = webObj;
            }
            
            //完成发送对象实例
            sendReq.message = urlMessage;
            
            //发送分享信息
            [WXApi sendReq:sendReq];
        }]];
        
        [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *alertAction){
            
        }]];
        
        [self presentViewController:controller animated:YES completion:nil];
        
    } else {
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        pasteBoard.string = message.content;
        [self showHUDWithText:@"文本内容已复制(当前微信不可用)" andHideDelay:1.6];
    }
}

- (void)messageActionViewMoreDidPressWithTag:(NSUInteger)tag
{
    Message *message = _messageData[tag];
    NSString *myUsername = [[NSUserDefaults standardUserDefaults] objectForKey:@"USERNAME"];
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"更多" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [controller addAction:[UIAlertAction actionWithTitle:@"复制" style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertAction){
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        pasteBoard.string = message.content;
    }]];
    
    if ([myUsername isEqualToString:message.username]) {
        [controller addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *alertAction){
            
        }]];
    }
    
    [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *alertAction){
        
    }]];
    
    [self presentViewController:controller animated:YES completion:nil];
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

#pragma mark - IDMPhotoBrowserDelegate

- (void)photoBrowser:(IDMPhotoBrowser *)photoBrowser didShowPhotoAtIndex:(NSUInteger)index
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}


- (void)photoBrowser:(IDMPhotoBrowser *)photoBrowser willDismissAtPageIndex:(NSUInteger)index
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}


@end





