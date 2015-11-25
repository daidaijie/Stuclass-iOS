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

static NSString *nickname_url = @"/nickname";

@interface NicknameTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;

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
    NSString *nickname = [ud valueForKey:@"NICKNAME"];
    
    _nicknameTextField.text = nickname;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_nicknameTextField becomeFirstResponder];
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



- (IBAction)cancelPress:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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











