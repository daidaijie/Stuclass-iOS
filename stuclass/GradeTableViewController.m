//
//  GradeTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 11/22/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "GradeTableViewController.h"
#import "Grade.h"

@interface GradeTableViewController ()

@end

@implementation GradeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTableView];
}


- (void)setupTableView
{
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.tableView.contentInset = UIEdgeInsetsMake(-6, 0, 0, 0);
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_gradeDict[@"semesters"] count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 1 : [_gradeDict[@"semesters"][section - 1][@"grades"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"平均绩点";
    } else {
        NSString *year = _gradeDict[@"semesters"][section - 1][@"year"];
        NSString *semester = _gradeDict[@"semesters"][section - 1][@"semester"];

        return [NSString stringWithFormat:@"%@ %@", year, semester];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GradeCell" forIndexPath:indexPath];
    
    if (section == 0 && row == 0) {
        
        cell.textLabel.text = @"GPA";
        cell.detailTextLabel.text = _gradeDict[@"gpa"];
        
        return cell;
        
    } else {
        
        Grade *grade = _gradeDict[@"semesters"][section - 1][@"grades"][row];
        
        cell.textLabel.text = grade.name;
        cell.detailTextLabel.text = grade.grade;
        
        return cell;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end












