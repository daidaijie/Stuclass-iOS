//
//  NicknameTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 11/26/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "NicknameTableViewController.h"
#import "Define.h"
#import <KVNProgress/KVNProgress.h>
#import <AFNetworking/AFNetworking.h>
#import "MBProgressHUD.h"
#import "MobClick.h"

@interface NicknameTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;

@property (assign, nonatomic) NSString *ud_nickname;

@end

@implementation NicknameTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MobClick event:@"Me_Nickname"];
    
    [self setupTableView];
    
    [self setupInfo];
}

#pragma mark - Setup Method

- (void)setupTableView
{
    self.tableView.contentInset = UIEdgeInsetsMake(-12, 0, 0, 0);
}

- (void)setupInfo
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    _ud_nickname = [ud valueForKey:@"NICKNAME"];
    
    _nicknameTextField.text = _ud_nickname;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_nicknameTextField becomeFirstResponder];
}


- (IBAction)saveItemPress:(id)sender
{
    [_nicknameTextField resignFirstResponder];
    [self checkBeforeSaving];
}

- (void)activateTextField
{
    [_nicknameTextField becomeFirstResponder];
}

- (void)checkBeforeSaving
{
    NSString *nickname = _nicknameTextField.text;
    
    if (nickname.length == 0) {
        
        // 不能留空
        [self showHUDWithText:@"昵称不能为空" andHideDelay:global_hud_delay];
        [self performSelector:@selector(activateTextField) withObject:nil afterDelay:global_hud_delay];
        
    } else if ([nickname hasPrefix:@" "] || [nickname hasSuffix:@" "]) {
        
        // 首尾不能有空格
        [self showHUDWithText:@"昵称首尾不能有空格" andHideDelay:global_hud_delay];
        [self performSelector:@selector(activateTextField) withObject:nil afterDelay:global_hud_delay];
        
    } else if (nickname.length > 20) {
        
        // 名字太长了
        [self showHUDWithText:@"昵称只允许20个字符以内" andHideDelay:global_hud_delay];
        [self performSelector:@selector(activateTextField) withObject:nil afterDelay:global_hud_delay];
        
    } else if ([_nicknameTextField.text isEqualToString:_ud_nickname]) {
        
        // 没修改
        [self.navigationController popViewControllerAnimated:YES];
        
    } else {
        [_nicknameTextField resignFirstResponder];
        [self save];
    }
}



- (void)save
{
    // KVN
    [KVNProgress showWithStatus:@"正在保存新昵称"];
    
    // ActivityIndicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // Request
    [self sendNicknameRequest];
}


- (void)sendNicknameRequest
{
    // ud
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *token = [ud valueForKey:@"USER_TOKEN"];
    NSString *user_id = [ud valueForKey:@"USER_ID"];
    NSNumber *user_id_num = [NSNumber numberWithInteger:[user_id integerValue]];
    
    // put data
    NSDictionary *putData = @{
                               @"id": user_id_num,
                               @"uid": user_id_num,
                               @"birthday": @"0",
                               @"gender": @"1",
                               @"profile": @"",
                               @"token": token,
                               @"nickname": _nicknameTextField.text,
                               };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];    
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript", nil];
//    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager PUT:[NSString stringWithFormat:@"%@%@", global_host, nickname_url] parameters:putData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
//        NSLog(@"连接服务器 - 成功 - %@", responseObject);
        NSLog(@"连接服务器 - 成功");
        [self parseNicknameResponseObject:responseObject];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSLog(@"连接服务器 - 失败 - %@", operation.error);
//        NSLog(@"连接服务器 - 失败");
        
        NSUInteger code = operation.response.statusCode;
        
        if (code == 401) {
            // wrong token
            [KVNProgress showErrorWithStatus:global_connection_wrong_token completion:^{
                
                [self logout];
            }];
        } else if (code == 500 || code == 502) {
            // 已被使用
            [KVNProgress showErrorWithStatus:@"该昵称已被他人使用" completion:^{
                [_nicknameTextField becomeFirstResponder];
            }];
        } else {
            [KVNProgress showErrorWithStatus:global_connection_failed completion:^{
                [_nicknameTextField becomeFirstResponder];
            }];
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}


- (void)parseNicknameResponseObject:(id)responseObject
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    [ud setValue:_nicknameTextField.text forKey:@"NICKNAME"];
    
    [_delegate nicknameChangedTo:_nicknameTextField.text];
    
    [KVNProgress showSuccessWithStatus:@"已保存新昵称" completion:^{
        
        [self.navigationController popViewControllerAnimated:YES];
        
        [MobClick event:@"Setting_Nickname"];
    }];
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











