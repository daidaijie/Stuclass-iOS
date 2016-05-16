//
//  SettingTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 10/12/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "SettingTableViewController.h"
#import <KVNProgress/KVNProgress.h>
#import "NicknameTableViewController.h"
#import "MBProgressHUD.h"
#import "MobClick.h"
#import "Define.h"
#import "SDWebImageManager.h"
#import <SIAlertView/SIAlertView.h>
#import "BackgoundTableViewController.h"

@interface SettingTableViewController () <NicknameChangedDelegate>

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearAndSemesterLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cacheSizeLabel;

@end


@implementation SettingTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupBarBackButton];
    [self setupInfo];
    [self setupTableView];
    
    [MobClick event:@"Tabbar_Setting"];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    self.cacheSizeLabel.text = [NSString stringWithFormat:@"%.1f MB", [SDWebImageManager sharedManager].imageCache.getSize / 1024.0 / 1024.0];
}

- (void)setupBarBackButton
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
}


- (void)setupInfo
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *dict = [ud valueForKey:@"YEAR_AND_SEMESTER"];
    
    NSInteger year = [dict[@"year"] integerValue];
    NSInteger semester = [dict[@"semester"] integerValue];
    
    NSString *semesterStr = @"";
    
    switch (semester) {
            
        case 1:
            semesterStr = @"秋季学期";
            break;
        case 2:
            semesterStr = @"春季学期";
            break;
        case 3:
            semesterStr = @"夏季学期";
            break;
            
        default:
            break;
    }
    
    _yearAndSemesterLabel.text = [NSString stringWithFormat:@"%d-%d %@", year, year + 1, semesterStr];
    
    _usernameLabel.text = [ud valueForKey:@"USERNAME"];
    
    _nicknameLabel.text = [ud valueForKey:@"NICKNAME"];
}


- (void)setupTableView
{
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.tableView.contentInset = UIEdgeInsetsMake(-10, 0, 0, 0);
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 1) {
        
        if (row == 1) {
            [self performSegueWithIdentifier:@"ShowNickname" sender:nil];
            
        }
        
    } else if (section == 2) {
        
        if (row == 0) {
            [self performSegueWithIdentifier:@"ShowBackground" sender:nil];
            [MobClick event:@"Setting_Background"];
        } else if (row == 1) {
            [self clearLocalData];
        }
        
    } else if (section == 3) {
        
        if (row == 0) {
            [self performSegueWithIdentifier:@"ShowAboutUs" sender:nil];
            [MobClick event:@"Setting_Aboutus"];
        } else if (row == 1) {
            [self share];
            [MobClick event:@"Setting_Share"];
        } else if (row == 2) {
            [self showUpdateInfo];
        }
        
    } else if (section == 4) {
        
        if (row == 0) {
            [KVNProgress showSuccessWithStatus:@"登出成功" completion:^{
                [self logout];
            }];
            [MobClick event:@"Setting_Logout"];
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
}

#pragma mark - Nickname Delegate

- (void)nicknameChangedTo:(NSString *)nickname
{
    _nicknameLabel.text = nickname;
}


#pragma mark - Share

- (void)share
{
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    pasteBoard.string = [NSString stringWithFormat:@"%@app/", global_host];
    
    [self showHUDWithText:@"下载链接已添加到剪贴板" andHideDelay:1.6];
    
    [self performSelector:@selector(diselectCell) withObject:nil afterDelay:1.6];
}


#pragma mark - Clear

- (void)clearLocalData
{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"警告" andMessage:@"确定清空图片缓存吗?"];
    
    alertView.transitionStyle = SIAlertViewTransitionStyleSlideFromBottom;
    
    [alertView addButtonWithTitle:@"取消" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }];
    
    [alertView addButtonWithTitle:@"确定" type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
        [[SDWebImageManager sharedManager].imageCache clearDisk];
        self.cacheSizeLabel.text = [NSString stringWithFormat:@"%.1f MB", [SDWebImageManager sharedManager].imageCache.getSize / 1024.0 / 1024.0];
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }];
    
    [alertView show];
}


- (void)diselectCell
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}


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

- (void)showUpdateInfo
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"更新内容 v%@", appVersion] andMessage:UPDATE_CONTENT];
    
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    
    [alertView addButtonWithTitle:@"立即体验 🙄:)" type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
        [self performSelector:@selector(diselectCell) withObject:nil afterDelay:0];
    }];
    
    [alertView show];
}


@end







