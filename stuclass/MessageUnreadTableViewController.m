//
//  MessageUnreadTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 11/23/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "MessageUnreadTableViewController.h"
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
#import "UIImageView-PlayGIF/UIImageView+PlayGIF.h"
#import "MessageTitleButton.h"
#import "MessageDetailViewController.h"

static const CGFloat kHeightForSectionHeader = 8.5;

static NSString *message_text_cell_id = @"MessageTextTableViewCell";
static NSString *message_image_cell_id = @"MessageImageTableViewCell";

@interface MessageUnreadTableViewController () <UIScrollViewDelegate, SDWebImageManagerDelegate, MessageTableViewCellDelegate, MessageImageTableViewCellDelegate, IDMPhotoBrowserDelegate>

@property (strong, nonatomic) UIView *sectionHeaderView;

@property (strong, nonatomic) ScrollManager *manager;

@end


@implementation MessageUnreadTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupBackBarButton];
    
    [self setupTableView];
    
    [self setupNotification];
    
    [_manager restoreURState];
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
    
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0);
    
    self.tableView.backgroundColor = TABLEVIEW_BACKGROUN_COLOR;
    
    self.tableView.fd_debugLogEnabled = NO;
    
    // sectionHeaderView
    _sectionHeaderView = [[UIView alloc] init];
    _sectionHeaderView.backgroundColor = [UIColor clearColor];
    
    // FooterView
    DocumentFooterView *footerView = [[DocumentFooterView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, kHeightForSectionHeader)];
    self.tableView.tableFooterView = footerView;
}



- (void)setupNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusUpdated:) name:@"MessageStatusUpdated" object:nil];
}

- (void)statusUpdated:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    if ([info[@"action"] isEqualToString:@"delete"]) {
        [_unreadData removeObject:notification.object];
        [_manager restoreURState];
    }
    [self.tableView reloadData];
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
    return _unreadData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Message *message = _unreadData[indexPath.section];
    
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
    Message *message = _unreadData[indexPath.section];
    
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
    Message *message = _unreadData[indexPath.section];
    
    // delegate
    cell.delegate = self;
    cell.tag = indexPath.section;
    
    cell.nameLabel.text = message.nickname;
    cell.contentLabel.text = message.content;
    cell.dateLabel.text = [NSString stringWithFormat:@"%@  来自%@", message.date, message.source];
    
    // comment
    [cell setCommentNum:message.comments.count available:YES];
    
    // like
    [cell setLikeNum:message.likes.count status:message.isLike animation:NO];
    
    // avatar
    NSURL *avatarUrl = [NSURL URLWithString:message.avatarURL];
    [cell.avatarImageView sd_setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"default_avatar"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
}

// Image
- (void)configureImageCell:(MessageImageTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Message *message = _unreadData[indexPath.section];
    
    // delegate
    cell.delegate = self;
    cell.tag = indexPath.section;
    
    cell.nameLabel.text = message.nickname;
    cell.contentLabel.text = message.content;
    cell.dateLabel.text = [NSString stringWithFormat:@"%@  来自%@", message.date, message.source];
    cell.managerType = 2;
    
    // comment
    [cell setCommentNum:message.comments.count available:YES];
    
    // like
    [cell setLikeNum:message.likes.count status:message.isLike animation:NO];
    
    // avatar
    NSURL *avatarUrl = [NSURL URLWithString:message.avatarURL];
    [cell.avatarImageView sd_setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"default_avatar"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    
    // image
    [cell setContentImagesWithImageURLs:message.imageURLs];
    [cell setPage:[_manager getURpageForKey:[NSString stringWithFormat:@"%i",indexPath.section]]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = indexPath.section;
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    MessageDetailViewController *mdvc = [sb instantiateViewControllerWithIdentifier:@"mdvc"];
    
    mdvc.message = _unreadData[section];
    
    [self sendRequestForReadWithTag:section];
    
    [self.navigationController pushViewController:mdvc animated:YES];
}


#pragma mark - MessageTableViewCellDelegate

- (void)messageImgViewBgGestureDidPressWithTag:(NSUInteger)tag Index:(NSUInteger)index
{
    [MobClick event:@"Message_Browse_Image"];
    
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

#pragma mark - Like Delegate
- (void)messageActionViewLikeDidPressWithTag:(NSUInteger)tag
{
    Message *message = _unreadData[tag];
    MessageTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:tag]];
    
    if (message.isLike) {
        // send not like
        [cell setLikeNum:((message.likes.count > 0) ? (message.likes.count - 1) : 0) status:NO animation:YES];
        
        message.isLike = NO;
        
        // server
        [self sendNotLikeRequestWithTag:tag];
        
    } else {
        // send like
        
        [cell setLikeNum:message.likes.count + 1 status:YES animation:YES];
        
        message.isLike = YES;
        
        // server
        [self sendLikeRequestWithTag:tag];
    }
}

- (void)sendLikeRequestWithTag:(NSUInteger)tag
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    Message *message = _unreadData[tag];
    
    // ud
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *token = [ud valueForKey:@"USER_TOKEN"];
    NSString *user_id = [ud valueForKey:@"USER_ID"];
    
    // post data
    NSDictionary *postData = @{
                               @"post_id": message.message_id,
                               @"uid": user_id,
                               @"token": token,
                               };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_like_timeout;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", global_host, message_like_url] parameters:postData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
        //        NSLog(@"点赞 - 连接服务器 - 成功 - %@", responseObject);
        NSLog(@"点赞 - 连接服务器 - 成功");
        [self addLikeToLocalWithTag:tag likeID:[NSString stringWithFormat:@"%@", responseObject[@"id"]]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        //        NSLog(@"点赞 - 连接服务器 - 失败 - %@", operation.error);
        NSLog(@"点赞 - 连接服务器 - 失败");
        
        NSUInteger code = operation.response.statusCode;
        
        if (code == 401) {
            // wrong token
            [self showHUDWithText:global_connection_wrong_token andHideDelay:global_hud_delay];
            [self performSelector:@selector(logout) withObject:nil afterDelay:global_hud_delay];
        }
        
        [self restoreLikeWithTag:tag isLike:NO];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

- (void)sendNotLikeRequestWithTag:(NSUInteger)tag
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    Message *message = _unreadData[tag];
    
    // ud
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *token = [ud valueForKey:@"USER_TOKEN"];
    NSString *user_id = [ud valueForKey:@"USER_ID"];
    NSString *like_id = @"";
    
    for (NSDictionary *dict in message.likes) {
        NSString *uid = dict[@"uid"];
        if ([uid isEqualToString:user_id]) {
            like_id = dict[@"id"];
            break;
        }
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_like_timeout;
    
    [manager.requestSerializer setValue:like_id forHTTPHeaderField:@"id"];
    [manager.requestSerializer setValue:user_id forHTTPHeaderField:@"uid"];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager DELETE:[NSString stringWithFormat:@"%@%@", global_host, message_like_url] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
        //        NSLog(@"取消点赞 - 连接服务器 - 成功 - %@", responseObject);
        NSLog(@"取消点赞 - 连接服务器 - 成功");
        [self removeLikeToLocalWithTag:tag likeID:like_id];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        //        NSLog(@"取消点赞 - 连接服务器 - 失败 - %@", operation.error);
        NSLog(@"取消点赞 - 连接服务器 - 失败");
        
        NSUInteger code = operation.response.statusCode;
        
        if (code == 401) {
            // wrong token
            [self showHUDWithText:global_connection_wrong_token andHideDelay:global_hud_delay];
            [self performSelector:@selector(logout) withObject:nil afterDelay:global_hud_delay];
        }
        
        [self restoreLikeWithTag:tag isLike:YES];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}


- (void)addLikeToLocalWithTag:(NSUInteger)tag likeID:(NSString *)like_id
{
    [MobClick event:@"Message_Like"];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [ud valueForKey:@"USER_ID"];
    
    Message *message = _unreadData[tag];
    
    message.isLike = YES;
    
    NSMutableArray *likeData = [NSMutableArray arrayWithArray:message.likes];
    
    [likeData addObject:@{@"id": like_id, @"uid": user_id}];
    
    message.likes = likeData;
    
    _unreadData[tag] = message;
    
    MessageTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:tag]];
    
    [cell setLikeNum:message.likes.count status:YES animation:NO];
}

- (void)removeLikeToLocalWithTag:(NSUInteger)tag likeID:(NSString *)like_id
{
    [MobClick event:@"Message_Not_Like"];
    
    Message *message = _unreadData[tag];
    
    message.isLike = NO;
    
    NSMutableArray *likeData = [NSMutableArray arrayWithArray:message.likes];
    
    NSUInteger flag = -1;
    
    for (NSUInteger i = 0; i < likeData.count; i++) {
        NSString *l_id = likeData[i][@"id"];
        if ([l_id isEqualToString:like_id]) {
            flag = i;
            break;
        }
    }
    
    if (flag != -1) {
        [likeData removeObjectAtIndex:flag];
    }
    
    message.likes = likeData;
    
    _unreadData[tag] = message;
    
    MessageTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:tag]];
    
    [cell setLikeNum:message.likes.count status:NO animation:NO];
}

- (void)restoreLikeWithTag:(NSUInteger)tag isLike:(BOOL)isLike
{
    Message *message = _unreadData[tag];
    
    MessageTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:tag]];
    
    [cell setLikeNum:message.likes.count status:isLike animation:YES];
    
    message.isLike = isLike;
}


#pragma mark - Comment Delegate
- (void)messageActionViewCommentDidPressWithTag:(NSUInteger)tag
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    MessageDetailViewController *mdvc = [sb instantiateViewControllerWithIdentifier:@"mdvc"];
    
    mdvc.message = _unreadData[tag];
    
    [self sendRequestForReadWithTag:tag];
    
    [self.navigationController pushViewController:mdvc animated:YES];
}



#pragma mark - Share Delegate
- (void)messageActionViewShareDidPressWithTag:(NSUInteger)tag
{
    [MobClick event:@"Message_Share"];
    
    Message *message = _unreadData[tag];
    
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        
        NSString *title = [NSString stringWithFormat:@"%@", message.content];
        NSString *description = [NSString stringWithFormat:@"%@\n%@\n来自消息圈\n(点击打开App)", message.nickname, message.date];
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"分享消息" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
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
                
                NSUInteger pageIndex = [_manager getURpageForKey:[NSString stringWithFormat:@"%i",tag]];
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
                
                NSUInteger pageIndex = [_manager getURpageForKey:[NSString stringWithFormat:@"%i",tag]];
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
        [self showHUDWithText:@"文本内容已复制(当前微信不可用)" andHideDelay:global_hud_delay];
    }
}

#pragma mark - More Delegate

- (void)messageActionViewMoreDidPressWithTag:(NSUInteger)tag
{
    [MobClick event:@"Message_More"];
    
    Message *message = _unreadData[tag];
    NSString *myUsername = [[NSUserDefaults standardUserDefaults] objectForKey:@"USERNAME"];
    NSString *messageStr = ([myUsername isEqualToString:@"14jhwang"] || [myUsername isEqualToString:@"14xfdeng"] || [myUsername isEqualToString:@"13yjli3"]) ? message.username : nil;
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"更多" message:messageStr preferredStyle:UIAlertControllerStyleActionSheet];
    
    [controller addAction:[UIAlertAction actionWithTitle:@"复制" style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertAction){
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        pasteBoard.string = message.content;
    }]];
    
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


#pragma mark - Log Out

- (void)logout
{
    [self logoutClearData];
    [self.navigationController.tabBarController.navigationController popViewControllerAnimated:YES];
}

- (void)logoutClearData
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    // ud
    [ud setValue:nil forKey:@"USER_TOKEN"];
    [ud setValue:nil forKey:@"YEAR_AND_SEMESTER"];
    [ud setValue:nil forKey:@"NICKNAME"];
    [ud setValue:nil forKey:@"AVATAR_URL"];
    [ud setValue:nil forKey:@"USER_ID"];
}

#pragma mark - Read Delete

- (void)sendRequestForReadWithTag:(NSUInteger)tag
{
    Message *message = _unreadData[tag];
    
    // ud
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *token = [ud valueForKey:@"USER_TOKEN"];
    NSString *user_id = [ud valueForKey:@"USER_ID"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_like_timeout;
    
    [manager.requestSerializer setValue:message.message_id forHTTPHeaderField:@"pid"];
    [manager.requestSerializer setValue:user_id forHTTPHeaderField:@"uid"];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager DELETE:[NSString stringWithFormat:@"%@%@", global_host, message_unread_url] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
        NSLog(@"已读 - 连接服务器 - 成功");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        //        NSLog(@"取消点赞 - 连接服务器 - 失败 - %@", operation.error);
        NSLog(@"已读 - 连接服务器 - 失败");
        
        NSUInteger code = operation.response.statusCode;
        
        if (code == 401) {
            // wrong token
            [self showHUDWithText:global_connection_wrong_token andHideDelay:global_hud_delay];
            [self performSelector:@selector(logout) withObject:nil afterDelay:global_hud_delay];
        }
    }];
}



@end


