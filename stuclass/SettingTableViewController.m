//
//  SettingTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 10/12/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "SettingTableViewController.h"
#import <KVNProgress/KVNProgress.h>

@interface SettingTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@end


@implementation SettingTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _usernameLabel.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"USERNAME"];
    
    [self setupTableView];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
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
            [self performSegueWithIdentifier:@"BackgroundVC" sender:nil];
        }
    } else if (section == 2) {
        if (row == 0) {
            [self performSegueWithIdentifier:@"ShowAboutUs" sender:nil];
        }
    } else if (section == 3) {
        if (row == 0) {
            [KVNProgress showSuccessWithStatus:@"登出成功"];
            [self performSelector:@selector(logout) withObject:nil afterDelay:0.3];
//            }];
        }
    }
}


- (void)logout
{
    [_delegate settingTableViewControllerLogOut];
    [self dismissViewControllerAnimated:NO completion:nil];
}


- (IBAction)backButtonPress:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end







