//
//  BackgoundTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 10/13/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "BackgoundTableViewController.h"
#import "GKImagePickerController.h"
#import "GKImagePicker.h"
#import <KVNProgress/KVNProgress.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface BackgoundTableViewController () <GKImagePickerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (assign, nonatomic) NSInteger bgSection;

@property (assign, nonatomic) NSInteger bgIndex;

@property (strong, nonatomic) GKImagePicker *imagePicker;

@end

@implementation BackgoundTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self setupImagePicker];
    [self setupTableView];
    [self setupDisplayData];
}

- (void)setupImagePicker
{
    _imagePicker = [[GKImagePicker alloc] init];
    CGSize cropSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    cropSize.width -= 4;
    cropSize.height -= 4;
    _imagePicker.cropSize = cropSize;
    _imagePicker.delegate = self;
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
    
    if (section == 0 || section == 1) {
        
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
    
    if (section == 0 || section == 1) {
        
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
        
        [KVNProgress showSuccessWithStatus:@"设置成功"];
        
        [tableView reloadData];
        
    } else if (section == 2) {
        if (row == 0) {
            // 从相册中选择
            
            if (!_imagePicker) {
                [self setupImagePicker];
            }
            
            // checking
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                return;
            }
            
            _imagePicker.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:_imagePicker.imagePickerController animated:YES completion:nil];
        }
    }
}


- (void)postNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"bgImageChanged" object:nil];
}


#pragma mark - GKImagePickerDelegate

// 选择取消
- (void)imagePickerDidCancel:(GKImagePicker *)imagePicker
{
    [imagePicker.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

// 选择图片
- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image
{
    NSLog(@"cropSizeImage - width %f - height %f", image.size.width, image.size.height);
    [self saveImage:image];
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
        success = [fileManager removeItemAtPath:imageFilePath error:&error];
    }
    // 缩放图片
//    UIImage *scaleImage;
    
//    if (SCREEN_WIDTH == 414.0) {
//        NSLog(@"Scale - iPhone 6 plus");
//        scaleImage = [self scaleFromImage:image toSize:CGSizeMake(SCREEN_WIDTH, (SCREEN_HEIGHT - 64))];
//    } else {
//        NSLog(@"Scale - iPhone 4 5 5s 6");
//        scaleImage = [self scaleFromImage:image toSize:CGSizeMake(SCREEN_WIDTH, (SCREEN_HEIGHT - 64))];
//    }
    
    [UIImageJPEGRepresentation(image, 1.0f) writeToFile:imageFilePath atomically:YES];
    
    [self postNotification];
    
    _bgIndex = -1;
    [self.tableView reloadData];
    
    [_imagePicker.imagePickerController dismissViewControllerAnimated:YES completion:nil];
    
    [KVNProgress showSuccessWithStatus:@"设置成功"];
}


// 改变图像的尺寸
- (UIImage *)scaleFromImage:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"图片尺寸 - %f x %f", size.width, size.height);
    
    return newImage;
}

@end



















