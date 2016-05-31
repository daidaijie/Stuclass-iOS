//
//  MeTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 5/24/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "MeTableViewController.h"
#import "Define.h"
#import <KVNProgress/KVNProgress.h>
#import <AFNetworking/AFNetworking.h>
#import "MBProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "MobClick.h"
#import "WXApi.h"
#import <BmobSDK/Bmob.h>
#import "JHDater.h"
#import "NicknameTableViewController.h"

@interface MeTableViewController () <NicknameChangedDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;

@property (strong, nonatomic) UIImagePickerController *imagePickerController;

@end

@implementation MeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MobClick event:@"Main_Me"];
    
    [self setupBarBackButton];
    
    [self setupTableView];
    
    [self setupImagePicker];
    
    [self setupInfo];
    
    [self setupAvatar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - Setup Method

// Bar
- (void)setupBarBackButton
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
}

- (void)setupImagePicker
{
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;
    _imagePickerController.allowsEditing = YES;
}

- (void)setupTableView
{
    // tableView
    self.tableView.contentInset = UIEdgeInsetsMake(-12, 0, 0, 0);
    
    // avatarImageView
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.size.width / 2;
    self.avatarImageView.clipsToBounds = YES;
}

- (void)setupInfo
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    _nicknameLabel.text = [ud valueForKey:@"NICKNAME"];
    _usernameLabel.text = [ud valueForKey:@"USERNAME"];
}

- (void)setupAvatar
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *urlStr = [ud objectForKey:@"AVATAR_URL"];
    NSURL *url = [NSURL URLWithString:urlStr];
    [_avatarImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"default_avatar"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
}

- (IBAction)share:(id)sender
{
    [MobClick event:@"Me_Share"];
    
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        
        NSString *title = [NSString stringWithFormat:@"嗨，这是我的汕大课程表名片！"];
        NSString *description = [NSString stringWithFormat:@"%@\n%@\n(点击打开App)", _nicknameLabel.text, _usernameLabel.text];
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"分享我的名片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [controller addAction:[UIAlertAction actionWithTitle:@"微信好友" style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertAction){
            
            //创建发送对象实例
            SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
            sendReq.bText = NO;
            sendReq.scene = 0;
            
            //创建分享内容对象
            WXMediaMessage *urlMessage = [WXMediaMessage message];
            urlMessage.title = title;
            urlMessage.description = description;
            [urlMessage setThumbImage:_avatarImageView.image];
            
            //创建多媒体对象
            WXWebpageObject *webObj = [WXWebpageObject object];
            webObj.webpageUrl = jump_app_url;
            
            //完成发送对象实例
            urlMessage.mediaObject = webObj;
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
            [urlMessage setThumbImage:_avatarImageView.image];
            
            //创建多媒体对象
            WXWebpageObject *webObj = [WXWebpageObject object];
            webObj.webpageUrl = jump_app_url;
            
            //完成发送对象实例
            urlMessage.mediaObject = webObj;
            sendReq.message = urlMessage;
            
            //发送分享信息
            [WXApi sendReq:sendReq];
        }]];
        
        [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *alertAction){
            
        }]];
        
        [self presentViewController:controller animated:YES completion:nil];
        
    } else {
        
        [self showHUDWithText:@"当前微信不可用" andHideDelay:global_hud_delay];
    }
}


#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    
    if (section == 0) {
        if (row == 0) {
            // avatar
            [self pickAvatar];
        }
    } else if (section == 1) {
        if (row == 1) {
            // nickname
            [self performSegueWithIdentifier:@"ShowNickname" sender:nil];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowNickname"]) {
        NicknameTableViewController *ntvc = segue.destinationViewController;
        ntvc.delegate = self;
    }
}

- (void)nicknameChangedTo:(NSString *)nickname
{
    _nicknameLabel.text = nickname;
}

- (void)pickAvatar
{
    if (!_imagePickerController) {
        [self setupImagePicker];
    }
    
    // checking
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [self showHUDWithText:@"没有打开相册的权限(设置-隐私)" andHideDelay:global_hud_delay];
        return;
    }
    
    _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:_imagePickerController animated:YES completion:nil];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize

{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [MobClick event:@"Me_Upload"];
    
    // KVN
    [KVNProgress showWithStatus:@"正在上传头像"];
    
    // ActivityIndicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // ud
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud objectForKey:@"USERNAME"];
    NSString *timestamp = [[JHDater sharedInstance] dateStringForDate:[NSDate date] withFormate:@"yyyy_MM_dd_HH_mm_ss"];
    
    // editedImage
    UIImage *image = info[@"UIImagePickerControllerEditedImage"];
    
    // size
    CGSize size = CGSizeZero;
    
    if (image.size.width > image.size.height) {
        size = CGSizeMake(320, 320 / image.size.width * image.size.height);
    } else {
        size = CGSizeMake(320 * image.size.width / image.size.height, 320);
    }
    
    image = [self reSizeImage:image toSize:size];
    
    // data
    NSData *data = UIImageJPEGRepresentation(image, 0.7);
    
    NSLog(@"图片大小 - %d KB", data.length / 1024);
    
    // upload
    NSString *fileName = [NSString stringWithFormat:@"avatar_%@_%@.jpg", username, timestamp];
    
    BmobFile *file = [[BmobFile alloc] initWithFileName:fileName withFileData:data];
    
    [file saveInBackground:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            NSLog(@"头像URL - %@",file.url);
            [self save:file.url];
        } else {
            [KVNProgress showErrorWithStatus:global_connection_failed completion:^{
                [_imagePickerController dismissViewControllerAnimated:YES completion:nil];
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            }];
        }
    }];
}


- (void)save:(NSString *)avatarURL
{
    // Request
    [self sendAvatarRequest:avatarURL];
}


- (void)sendAvatarRequest:(NSString *)avatarURL
{
    // ud
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *token = [ud valueForKey:@"USER_TOKEN"];
    NSString *user_id = [ud valueForKey:@"USER_ID"];
    
    NSDictionary *putData = @{
                              @"id": user_id,
                              @"uid": user_id,
                              @"token": token,
                              @"image": avatarURL,
                              };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager PUT:[NSString stringWithFormat:@"%@%@", global_host, avatar_url] parameters:putData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
        //        NSLog(@"连接服务器 - 成功 - %@", responseObject);
        NSLog(@"连接服务器 - 成功");
        [self parseAvatarResponseObject:responseObject avatarURL:(NSString *)avatarURL];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        //        NSLog(@"连接服务器 - 失败 - %@", operation.error);
        NSLog(@"连接服务器 - 失败");
        
        NSUInteger code = operation.response.statusCode;
        
        if (code == 401) {
            // wrong token
            [KVNProgress showErrorWithStatus:global_connection_wrong_token completion:^{
                [_imagePickerController dismissViewControllerAnimated:YES completion:nil];
                [self logout];
            }];
        } else {
            [KVNProgress showErrorWithStatus:global_connection_failed completion:^{
                [_imagePickerController dismissViewControllerAnimated:YES completion:nil];
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            }];
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}


- (void)parseAvatarResponseObject:(id)responseObject avatarURL:(NSString *)avatarURL
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    [ud setValue:avatarURL forKey:@"AVATAR_URL"];
    
    // update
    [self setupAvatar];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"avatarImageChanged" object:nil];
    
    [KVNProgress showSuccessWithStatus:@"已上传新头像" completion:^{
        
        [_imagePickerController dismissViewControllerAnimated:YES completion:nil];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
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
    [ud setValue:nil forKey:@"AVATAR_URL"];
    [ud setValue:nil forKey:@"USER_ID"];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end











