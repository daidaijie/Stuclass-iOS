//
//  SettingTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 10/12/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "SettingTableViewController.h"
#import <KVNProgress/KVNProgress.h>
#import "MBProgressHUD.h"
#import "MobClick.h"
#import "Define.h"
#import "SDWebImageManager.h"
#import <SIAlertView/SIAlertView.h>
#import "BackgoundTableViewController.h"
#import "WXApi.h"
#import "MYBlurIntroductionView.h"

@interface SettingTableViewController () <MYIntroductionDelegate>

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearAndSemesterLabel;
@property (weak, nonatomic) IBOutlet UILabel *cacheSizeLabel;

@end


@implementation SettingTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupBarBackButton];
    [self setupTableView];
    
    [MobClick event:@"Tabbar_Setting"];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    self.cacheSizeLabel.text = [NSString stringWithFormat:@"%.1f MB", [SDWebImageManager sharedManager].imageCache.getSize / 1024.0 / 1024.0];
    
    [self setupInfo];
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
        
        if (row == 0) {
            [self performSegueWithIdentifier:@"ShowBackground" sender:nil];
            [MobClick event:@"Setting_Background"];
        } else if (row == 1) {
            [self clearLocalData];
            [MobClick event:@"Setting_Cache"];
        }
        
    } else if (section == 2) {
        
        if (row == 0) {
            [self performSegueWithIdentifier:@"ShowAboutUs" sender:nil];
            [MobClick event:@"Setting_Aboutus"];
        } else if (row == 1) {
            [self share];
        } else if (row == 2) {
            [self showUpdateInfo];
        } else if (row == 3) {
            [self showWalkThrough];
        }
        
    } else if (section == 3) {
        
        if (row == 0) {
            [self logoutPress];
        }
    }
}

- (void)logoutPress
{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"警告" andMessage:@"确定退出当前账号吗?"];
    
    alertView.transitionStyle = SIAlertViewTransitionStyleSlideFromBottom;
    
    [alertView addButtonWithTitle:@"取消" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }];
    
    [alertView addButtonWithTitle:@"确定" type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
        [self logout];
        [MobClick event:@"Setting_Logout"];
    }];
    
    [alertView show];
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
    [ud setValue:nil forKey:@"AVATAR_URL"];
    [ud setValue:nil forKey:@"USER_ID"];
}


#pragma mark - Share

- (void)share
{
    [MobClick event:@"Setting_ShareApp"];
    
    NSString *title = [NSString stringWithFormat:@"嗨！我[%@]在使用汕大课程表App！好赞呢！", [[NSUserDefaults standardUserDefaults] valueForKey:@"NICKNAME"]];
    NSString *description = @"汕大课程表 - 汕大人必备的校园平台";
    NSString *url = @"http://hjsmallfly.wicp.net/app";
    
    
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"分享给朋友" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [controller addAction:[UIAlertAction actionWithTitle:@"微信好友" style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertAction){
            
            //创建发送对象实例
            SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
            sendReq.bText = NO;
            sendReq.scene = 0;
            
            //创建分享内容对象
            WXMediaMessage *urlMessage = [WXMediaMessage message];
            urlMessage.title = title;
            urlMessage.description = description;
            [urlMessage setThumbImage:[UIImage imageNamed:@"WXAppIcon"]];
            
            //创建多媒体对象
            WXWebpageObject *webObj = [WXWebpageObject object];
            webObj.webpageUrl = url;
            
            //完成发送对象实例
            urlMessage.mediaObject = webObj;
            sendReq.message = urlMessage;
            
            //发送分享信息
            [WXApi sendReq:sendReq];
            
            [self diselectCell];
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
            [urlMessage setThumbImage:[UIImage imageNamed:@"WXAppIcon"]];
            
            //创建多媒体对象
            WXWebpageObject *webObj = [WXWebpageObject object];
            webObj.webpageUrl = url;
            
            //完成发送对象实例
            urlMessage.mediaObject = webObj;
            sendReq.message = urlMessage;
            
            //发送分享信息
            [WXApi sendReq:sendReq];
            
            [self diselectCell];
        }]];
        
        [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *alertAction){
            [self diselectCell];
        }]];
        
        [self presentViewController:controller animated:YES completion:nil];
        
    } else {
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        pasteBoard.string = @"http://hjsmallfly.wicp.net/app";
        
        [self showHUDWithText:@"下载链接已添加到剪贴板" andHideDelay:global_hud_delay];
        
        [self performSelector:@selector(diselectCell) withObject:nil afterDelay:global_hud_delay];
    }
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


- (void)showWalkThrough
{
    [MobClick event:@"Walk_Through"];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    UIView *headerView = [[NSBundle mainBundle] loadNibNamed:@"IntroHeader" owner:nil options:nil][0];
    
    MYIntroductionPanel *panel1 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, width, height) title:@"在这里，你可以..." description:@"查看课表、考试安排、成绩、馆藏图书、一键连接校园Wi-Fi..." image:[UIImage imageNamed:@"intro-img1"] header:headerView];
    
    MYIntroductionPanel *panel2 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, width, height) title:@"在这里，你还可以..." description:@"制作自己的任务清单，让一天的事务一目了然！" image:[UIImage imageNamed:@"intro-img2"] header:nil];
    
    MYIntroductionPanel *panel3 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, width, height) title:@"在这里，你更可以..." description:@"与汕大所有师生进行互动，分享大学生活的心路历程！" image:[UIImage imageNamed:@"intro-img3"] header:nil];
    
    MYIntroductionPanel *panel4 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, width, height) title:@"最后" description:@"愿您前程似锦！\n\n2016/5/29" image:nil header:nil];
    
    panel1.PanelDescriptionLabel.font = panel2.PanelDescriptionLabel.font = panel3.PanelDescriptionLabel.font = panel4.PanelDescriptionLabel.font = [UIFont systemFontOfSize:17.0];
    
    panel1.PanelImageView.contentMode = panel2.PanelImageView.contentMode = panel3.PanelImageView.contentMode = panel4.PanelImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    MYBlurIntroductionView *introductionView = [[MYBlurIntroductionView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    
    introductionView.delegate = self;
    
    introductionView.RightSkipButton.hidden = YES;
    [introductionView.RightSkipButton setTitle:@"好的" forState:UIControlStateNormal];
    
    introductionView.BackgroundImageView.image = [UIImage imageNamed:@"intro-bg.jpg"];
    [introductionView setBackgroundColor:[UIColor colorWithRed:90.0f/255.0f green:175.0f/255.0f blue:113.0f/255.0f alpha:0.65]];
    
    [introductionView buildIntroductionWithPanels:@[panel1, panel2, panel3, panel4]];
    
//    [self.navigationController.tabBarController.view addSubview:introductionView];
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view = introductionView;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - MYIntroduction Delegate

- (void)introduction:(MYBlurIntroductionView *)introductionView didChangeToPanel:(MYIntroductionPanel *)panel withIndex:(NSInteger)panelIndex{
    
    if (panelIndex == 0) {
        [introductionView setBackgroundColor:[UIColor colorWithRed:90.0f/255.0f green:175.0f/255.0f blue:113.0f/255.0f alpha:0.65]];
        introductionView.RightSkipButton.hidden = YES;
    } else if (panelIndex == 1) {
        [introductionView setBackgroundColor:[UIColor colorWithRed:50.0f/255.0f green:79.0f/255.0f blue:133.0f/255.0f alpha:0.65]];
        introductionView.RightSkipButton.hidden = YES;
    } else if (panelIndex == 2) {
        [introductionView setBackgroundColor:[UIColor colorWithRed:0.745 green:0.298 blue:0.235 alpha:0.65]];
        introductionView.RightSkipButton.hidden = YES;
    } else {
        [introductionView setBackgroundColor:[UIColor clearColor]];
        introductionView.RightSkipButton.hidden = NO;
    }
}

- (void)introduction:(MYBlurIntroductionView *)introductionView didFinishWithType:(MYFinishType)finishType {
    NSLog(@"介绍完了!");
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}


@end







