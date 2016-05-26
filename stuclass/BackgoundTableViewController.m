//
//  BackgoundTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 10/13/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "BackgoundTableViewController.h"
#import <KVNProgress/KVNProgress.h>
#import "MobClick.h"
#import "Define.h"
#import "MBProgressHUD.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface BackgoundTableViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (assign, nonatomic) NSInteger bgSection;

@property (assign, nonatomic) NSInteger bgIndex;

@property (strong, nonatomic) UIImagePickerController *imagePickerController;

@end

@implementation BackgoundTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupTableView];
    [self setupDisplayData];
}

- (void)setupImagePicker
{
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;
}


- (void)setupTableView
{
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.tableView.contentInset = UIEdgeInsetsMake(-6, 0, 0, 0);
}

- (void)setupDisplayData
{
    // 读取背景图片
    BOOL isBgImageExisted = NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 获取存储目录
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imageFilePath = [documentsDirectory stringByAppendingString:@"/class_bg_user.jpg"];
    // 检测是否已存在
    isBgImageExisted = [fileManager fileExistsAtPath:imageFilePath];
    
    if (!isBgImageExisted) {
        // 用户在使用自带图片
        _bgSection = [[NSUserDefaults standardUserDefaults] integerForKey:@"bgSection"];
        _bgIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"bgIndex"];
        
    } else {
        // 用户在使用自己的图片
        _bgSection = -1;
        _bgIndex = -1;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 1 || section == 2) {
        
        if (section == _bgSection && row == _bgIndex) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    } else {
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 1 || section == 2) {
        
        // 自带背景
        _bgSection = section;
        _bgIndex = row;
        
        // ud
        [[NSUserDefaults standardUserDefaults] setInteger:_bgSection forKey:@"bgSection"];
        [[NSUserDefaults standardUserDefaults] setInteger:_bgIndex forKey:@"bgIndex"];
        
        // 删除自定义图片
        NSFileManager *fileManager = [NSFileManager defaultManager];
        // 获取存储目录
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *imageFilePath = [documentsDirectory stringByAppendingString:@"/class_bg_user.jpg"];
        
        if ([fileManager fileExistsAtPath:imageFilePath]) {
            NSError *error;
            [fileManager removeItemAtPath:imageFilePath error:&error];
        }
        
        [self postNotification];
        
        [KVNProgress showSuccessWithStatus:@"设置成功" completion:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [tableView reloadData];
        
    } else if (section == 0) {
        if (row == 0) {
            // 从相册中选择
            [MobClick event:@"Setting_Background_Custom"];
            
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
    }
}


- (void)postNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"bgImageChanged" object:nil];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    [self saveImage:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

// 保存图片
- (void)saveImage:(UIImage *)image
{
    NSLog(@"保存背景图片");
    
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    // 获取存储目录
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imageFilePath = [documentsDirectory stringByAppendingString:@"/class_bg_user.jpg"];
    // 检测是否已存在
    success = [fileManager fileExistsAtPath:imageFilePath];
    if (success) {
        [fileManager removeItemAtPath:imageFilePath error:&error];
    }
    
    [UIImageJPEGRepresentation(image, 1.0f) writeToFile:imageFilePath atomically:YES];
    
    [self postNotification];
    
    _bgIndex = -1;
    [self.tableView reloadData];
    
    [_imagePickerController dismissViewControllerAnimated:YES completion:nil];
    
    [KVNProgress showSuccessWithStatus:@"设置成功" completion:^{
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


@end



















