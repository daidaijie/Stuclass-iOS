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
@property (weak, nonatomic) IBOutlet UILabel *yearAndSemesterLabel;

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
    
    if (section == 2) {
        if (row == 0) {
            [self performSegueWithIdentifier:@"BackgroundVC" sender:nil];
        }
    } else if (section == 3) {
        if (row == 0) {
            [self performSegueWithIdentifier:@"ShowAboutUs" sender:nil];
        }
    } else if (section == 4) {
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







