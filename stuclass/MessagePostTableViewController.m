//
//  MessagePostTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 5/14/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "MessagePostTableViewController.h"
#import "Define.h"
#import <AFNetworking/AFNetworking.h>
#import "MBProgressHUD.h"
#import <KVNProgress/KVNProgress.h>
#import "SDVersion.h"
#import "PlaceholderTextView.h"
#import <SDVersion/SDVersion.h>
#import "QBImagePickerController.h"

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface MessagePostTableViewController () <UITextViewDelegate, QBImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet PlaceholderTextView *textView;

@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@property (weak, nonatomic) IBOutlet UILabel *imageLabel;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageView;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *deleteButtons;

@property (strong, nonatomic) NSMutableArray *assetArray;

@end

@implementation MessagePostTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTableView];
    [self setupTextView];
    [self setupSegmentControl];
}

#pragma mark - Setup Method

- (void)setupTableView
{
    self.tableView.contentInset = UIEdgeInsetsMake(-12, 0, 0, 0);
}

- (void)setupTextView
{
    _textView.placeholder.text = @"分享身边发生的事...";
}

- (void)setupSegmentControl
{
    DeviceVersion version = [SDVersion deviceVersion];
    
    NSString *vStr = @"iPhone";
    
    switch (version) {
        // iPhone
        case iPhone4:
            vStr = @"iPhone 4";
            break;
        case iPhone4S:
            vStr = @"iPhone 4s";
            break;
        case iPhone5:
            vStr = @"iPhone 5";
            break;
        case iPhone5C:
            vStr = @"iPhone 5c";
            break;
        case iPhone5S:
            vStr = @"iPhone 5s";
            break;
        case iPhone6:
            vStr = @"iPhone 6";
            break;
        case iPhone6Plus:
            vStr = @"iPhone 6+";
            break;
        case iPhone6S:
            vStr = @"iPhone 6s";
            break;
        case iPhone6SPlus:
            vStr = @"iPhone 6s+";
            break;
        // iPod
        case iPodTouch1Gen:
            vStr = @"iPod Touch";
            break;
        case iPodTouch2Gen:
            vStr = @"iPod Touch 2";
            break;
        case iPodTouch3Gen:
            vStr = @"iPod Touch 3";
            break;
        case iPodTouch4Gen:
            vStr = @"iPod Touch 4";
            break;
        case iPodTouch5Gen:
            vStr = @"iPod Touch 5";
            break;
        case iPodTouch6Gen:
            vStr = @"iPod Touch 6";
            break;
        // iPad
        case iPad1:
            vStr = @"iPad 1";
            break;
        case iPad2:
            vStr = @"iPad 2";
            break;
        case iPad3:
            vStr = @"iPad 3";
            break;
        case iPad4:
            vStr = @"iPad 4";
            break;
        case iPadAir:
            vStr = @"iPad Air";
            break;
        case iPadAir2:
            vStr = @"iPad Air 2";
            break;
        case iPadMini:
            vStr = @"iPad Mini";
            break;
        case iPadMini2:
            vStr = @"iPad Mini 2";
            break;
        case iPadMini3:
            vStr = @"iPad Mini 3";
            break;
        case iPadMini4:
            vStr = @"iPad Mini 4";
            break;
        case iPadPro:
            vStr = @"iPad Pro";
            break;
        // Simulator
        case Simulator:
            vStr = @"Simulator";
            break;
        default:
            break;
    }
    
    [self.segmentControl setTitle:vStr forSegmentAtIndex:1];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"";
    } else if (section == 1) {
        return [NSString stringWithFormat:@"分享图片 %d/3", _assetArray.count];
    } else {
        return @"消息来源";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = indexPath.section;
    
    if (section == 0) {
        if (SCREEN_HEIGHT == 480.0) {
            return global_textView_RowHeightFor4;
        } else {
            return global_textView_RowHeightFor5;
        }
    } else if (section == 1) {
        return 90;
    } else {
        return 45;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==1) {
        // 从相册中选择图片
        QBImagePickerController *imagePickerController = [QBImagePickerController new];
        imagePickerController.delegate = self;
        imagePickerController.mediaType = QBImagePickerMediaTypeImage;
        
        imagePickerController.allowsMultipleSelection = YES;
        imagePickerController.showsNumberOfSelectedAssets = YES;
        imagePickerController.maximumNumberOfSelection = 3;
        imagePickerController.assetCollectionSubtypes = @[
                                                          @(PHAssetCollectionSubtypeAlbumMyPhotoStream),
                                                          @(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
                                                          @(PHAssetCollectionSubtypeSmartAlbumSelfPortraits),
                                                          @(PHAssetCollectionSubtypeSmartAlbumPanoramas),
                                                          @(PHAssetCollectionSubtypeSmartAlbumScreenshots),
                                                          @(PHAssetCollectionSubtypeSmartAlbumGeneric),
                                                          ];
        
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

#pragma mark - QBImagePickerDelegate

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets
{
//    NSLog(@"Selected assets:");
//    NSLog(@"%@", assets);
    
//    NSLog(@"------------------------+");
    
    _assetArray = [NSMutableArray arrayWithArray:assets];
    
//    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
//    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
//    option.resizeMode = PHImageRequestOptionsResizeModeExact;
//            
//            CGSize size = CGSizeZero;
//            
//            if (asset.pixelWidth > asset.pixelHeight) {
//                size = CGSizeMake(640, 640 * asset.pixelHeight / asset.pixelWidth);
//            } else {
//                size = CGSizeMake(640, 640 / asset.pixelHeight * asset.pixelWidth);
//
//            }
    
    [self updateImageViewDisplay];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)deletePress:(UIButton *)sender
{
    NSUInteger tag = sender.tag;
    
    NSLog(@"删除第%d个图片", tag + 1);

    [_assetArray removeObjectAtIndex:tag];
    
    [self updateImageViewDisplay];
}


- (void)updateImageViewDisplay
{
    // label
    _imageLabel.hidden = (_assetArray.count > 0);
    
    // count
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    
    // imageView
    for (NSUInteger i = 0; i < 3; i++) {
        
        UIImageView *imageView = _imageView[i];
        UIButton *button = _deleteButtons[i];
        
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        option.resizeMode = PHImageRequestOptionsResizeModeExact;
        
        if (i < _assetArray.count) {
        
            PHAsset *asset = _assetArray[i];
            
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(CGRectGetWidth(imageView.frame) * 2, CGRectGetWidth(imageView.frame) * 2) contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage *result, NSDictionary *info) {
                imageView.image = result;
                button.hidden = NO;
                NSLog(@"------%@", result);
            }];
        } else {
            imageView.image = nil;
            button.hidden = YES;
        }
    }
}



- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    NSLog(@"取消");
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - TextView Delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.text.length > 1) {
        // 禁止换行
        NSString *originStr = textView.text;
        NSString *lastTwoChar = [originStr substringWithRange:NSMakeRange(originStr.length - 2, 2)];
        
        if ([lastTwoChar isEqualToString:@"\n\n"] && [text isEqualToString:@"\n"]) {
            return NO;
        }
    }
    
    return YES;
}


- (void)textViewDidChange:(UITextView *)textView
{
    _countLabel.text = [NSString stringWithFormat:@"%d", textView.text.length];
    
    _textView.placeholder.hidden = (textView.text.length > 0);
}

#pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_textView resignFirstResponder];
}

#pragma mark - Post

- (IBAction)postItemPress:(id)sender
{
    [_textView resignFirstResponder];
    
    if (_textView.text.length == 0) {
        [self showHUDWithText:@"内容不能为空" andHideDelay:global_hud_delay];
    } else if ([_textView.text rangeOfString:@"\n\n\n"].location != NSNotFound) {
        [self showHUDWithText:@"不能连续换三行以上" andHideDelay:global_hud_delay];
    } else if (_textView.text.length > 320) {
        [self showHUDWithText:@"限制320字以内" andHideDelay:global_hud_delay];
    } else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [KVNProgress showWithStatus:@"正在发表消息"];
        [self sendPostRequest];
    }
}

- (void)sendPostRequest
{
    // ud
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *token = [ud valueForKey:@"USER_TOKEN"];
    NSString *user_id = [ud valueForKey:@"USER_ID"];
    
    // put data
    NSDictionary *putData = @{
                              @"id": user_id,
                              @"uid": user_id,
                              @"token": token,
                              };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager PUT:[NSString stringWithFormat:@"%@%@", global_host, message_post_url] parameters:putData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
        //        NSLog(@"连接服务器 - 成功 - %@", responseObject);
        NSLog(@"连接服务器 - 成功");
//        [self parseNicknameResponseObject:responseObject];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        //        NSLog(@"连接服务器 - 失败 - %@", operation.error);
        NSLog(@"连接服务器 - 失败");
        
        NSUInteger code = operation.response.statusCode;
        
        if (code == 401) {
            // wrong token
            [KVNProgress showErrorWithStatus:global_connection_wrong_token completion:^{
                
                [self logout];
            }];
        } else if (code == 500) {
            // 已被使用
            [KVNProgress showErrorWithStatus:@"该昵称已被他人使用" completion:^{
                
            }];
        } else {
            [KVNProgress showErrorWithStatus:global_connection_failed completion:^{
                
            }];
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}



#pragma mark - LogOut

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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
