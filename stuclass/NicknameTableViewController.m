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

static NSString *nickname_url = @"/api/v1.0/modify_user";

@interface NicknameTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;

@property (assign, nonatomic) NSString *ud_nickname;

@end

@implementation NicknameTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    [self checkBeforeSaving];
}


- (void)checkBeforeSaving
{
    NSString *nickname = _nicknameTextField.text;
    
    if (nickname.length == 0) {
        
        // 不能留空
        [self showHUDWithText:@"昵称不能为空" andHideDelay:1.0];
        
    } else if ([nickname hasPrefix:@" "] || [nickname hasSuffix:@" "]) {
        
        // 首尾不能有空格
        [self showHUDWithText:@"昵称首尾不能有空格" andHideDelay:1.0];
        
    } else if (nickname.length < 2){
        
        // 名字太短
        [self showHUDWithText:@"昵称最少2个字符" andHideDelay:1.0];
        
    } else if (nickname.length > 14) {
        
        // 名字太长了
        [self showHUDWithText:@"昵称只允许14个字符以内" andHideDelay:1.0];
        
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
    NSString *username = [ud valueForKey:@"USERNAME"];
    NSString *token = [ud valueForKey:@"USER_TOKEN"];
    
    // post data
    NSDictionary *postData = @{
                               @"username": username,
                               @"token": token,
                               @"nickname": _nicknameTextField.text,
                               };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", global_host, nickname_url] parameters:postData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
        //        NSLog(@"连接服务器 - 成功 - %@", responseObject);
        NSLog(@"连接服务器 - 成功");
        [self parseNicknameResponseObject:responseObject];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSLog(@"连接服务器 - 失败 - %@", error);
        [KVNProgress showErrorWithStatus:global_connection_failed completion:^{
            [_nicknameTextField becomeFirstResponder];
        }];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}


- (void)parseNicknameResponseObject:(id)responseObject
{
    if ([responseObject[@"ERROR"] isEqualToString:@"wrong token"] || [responseObject[@"ERROR"] isEqualToString:@"no such user"]) {
        // wrong token
        [KVNProgress showErrorWithStatus:global_connection_wrong_token completion:^{
            
            [self logoutClearData];
            self.navigationController.navigationBarHidden = YES;
            [self.navigationController popViewControllerAnimated:NO];
        }];
        
    } else if ([responseObject[@"ERROR"] isEqualToString:@"empty name"]) {
        // 名字不能留空
        [KVNProgress showErrorWithStatus:@"昵称不能为空" completion:^{
            [_nicknameTextField becomeFirstResponder];
        }];
        
    } else if ([responseObject[@"ERROR"] isEqualToString:@"not authorized to use this name"]) {
        // 无权用别人的账号名
        [KVNProgress showErrorWithStatus:@"无法使用已注册的账号名" completion:^{
            [_nicknameTextField becomeFirstResponder];
        }];
        
    } else if ([responseObject[@"ERROR"] isEqualToString:@"nickname too long"]) {
        // 名字太长了
        [KVNProgress showErrorWithStatus:@"昵称只允许14个字符以内" completion:^{
            [_nicknameTextField becomeFirstResponder];
        }];
        
    } else if ([responseObject[@"ERROR"] isEqualToString:@"the nickname has been used"]) {
        // 已被使用
        [KVNProgress showErrorWithStatus:@"该昵称已被他人使用" completion:^{
            [_nicknameTextField becomeFirstResponder];
        }];
        
    } else if ([responseObject[@"ERROR"] isEqualToString:@"nickname too short, at least 2"]) {
        
        // 名字太短
        [KVNProgress showErrorWithStatus:@"昵称最少2个字符" completion:^{
            [_nicknameTextField becomeFirstResponder];
        }];
        
    } else {
        // 成功
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        
        [ud setValue:_nicknameTextField.text forKey:@"NICKNAME"];
        
        [_delegate nicknameChangedTo:_nicknameTextField.text];
        
        [KVNProgress showSuccessWithStatus:@"保存新昵称成功" completion:^{
            
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}



// Log Out
- (void)logout
{
    [self logoutClearData];
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)logoutClearData
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    // ud
    [ud setValue:nil forKey:@"USER_TOKEN"];
    [ud setValue:nil forKey:@"YEAR_AND_SEMESTER"];
    [ud setValue:nil forKey:@"NICKNAME"];
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











