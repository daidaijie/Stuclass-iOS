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

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface MessagePostTableViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet PlaceholderTextView *textView;

@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

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
    } else if (_textView.text.length > 180) {
        [self showHUDWithText:@"限制200字以内" andHideDelay:global_hud_delay];
    } else {
//        [KVNProgress showWithStatus:@"吹~吹~吹~"];
//        [self sendRequest:YES];
    }
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
