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

@interface SettingTableViewController () <NicknameChangedDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearAndSemesterLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;

@end


@implementation SettingTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupBarBackButton];
    [self setupInfo];
    [self setupTableView];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
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
            [self performSegueWithIdentifier:@"BackgroundVC" sender:nil];
        }
        
    } else if (section == 3) {
        
        if (row == 0) {
            [self performSegueWithIdentifier:@"ShowAboutUs" sender:nil];
        } else if (row == 1) {
            [self share];
        }
        
    } else if (section == 4) {
        
        if (row == 0) {
            [KVNProgress showSuccessWithStatus:@"登出成功"];
            [self performSelector:@selector(logout) withObject:nil afterDelay:0.3];
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
    [_delegate settingTableViewControllerLogOut];
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Nickname Delegate

- (void)nicknameChangedTo:(NSString *)nickname
{
    _nicknameLabel.text = nickname;
}

- (IBAction)backButtonPress:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Share

- (void)share
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"分享给朋友" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"微信好友", @"微信朋友圈", @"QQ好友", @"QQ说说", nil];
    [actionSheet showInView:self.view];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}


@end







