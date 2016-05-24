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

@interface MeTableViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;


@end

@implementation MeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBarBackButton];
    
    [self setupTableView];
    
    [self setupInfo];
    
    [self setupAvatar];
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











