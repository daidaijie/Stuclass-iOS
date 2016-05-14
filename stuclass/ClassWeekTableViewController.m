//
//  ClassWeekTableViewController.h
//  stuclass
//
//  Created by JunhaoWang on 3/2/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "ClassWeekTableViewController.h"
#import "ClassWeekTableViewCell.h"
#import "Define.h"

static NSInteger kNumberOfWeeks = 16;

@interface ClassWeekTableViewController ()

@end

@implementation ClassWeekTableViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupTableView];
}

#pragma mark - Setup Method

- (void)setupTableView
{
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.contentInset = UIEdgeInsetsMake(-10, 0, 0, 0);
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(_selectedWeek - 1) inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}



#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kNumberOfWeeks;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    static NSString *cell_id = @"ClassWeekCell";
    
    ClassWeekTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    
    // AccessoryType
    if (_selectedWeek == row + 1) {
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    } else {
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.weekLabel.text = [NSString stringWithFormat:@"第 %d 周", row + 1];
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger week = indexPath.row + 1;
    
    _selectedWeek = week;
    
    [tableView reloadData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [_delegate weekDelegateWeekChanged:_selectedWeek];
}




- (IBAction)cancelPress:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
























