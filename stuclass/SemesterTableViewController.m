//
//  SemesterTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 10/12/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "SemesterTableViewController.h"


@interface SemesterTableViewController ()

@property (strong, nonatomic) NSMutableArray *semesterData;

@property (assign, nonatomic) NSInteger selectedYear;
@property (assign, nonatomic) NSInteger selectedSemester;

@end




@implementation SemesterTableViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupData];
    
    [self setupTableView];
}

#pragma mark - Setup Method

- (void)setupSelectedYear:(NSInteger)year semester:(NSInteger)semester
{
    _selectedYear = year;
    _selectedSemester = semester;
}

- (void)setupData
{
    // 获得年份
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSInteger year = [dateComponent year];
    
    _semesterData = [NSMutableArray array];
    
    for (NSInteger i = 0; i < 4; i++) {
        [_semesterData addObject:[NSNumber numberWithInteger:year - i]];
    }
}


- (void)setupTableView
{
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.contentInset = UIEdgeInsetsMake(-10, 0, 0, 0);
}



#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _semesterData.count * 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    static NSString *cell_id = @"SemesterCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    
    NSInteger year = [_semesterData[row / 3] integerValue];
    NSInteger semester = indexPath.row % 3 + 1;
    
    // AccessoryType
    if (_selectedYear == year && _selectedSemester == semester) {

        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Content
    NSString *semesterStr = @"";
    
    switch (row % 3) {
        case 0:
            semesterStr = @"秋季学期";
            break;
        case 1:
            semesterStr = @"春季学期";
            break;
        case 2:
            semesterStr = @"夏季学期";
            break;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d-%d  %@", year, year + 1, semesterStr];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger year = [_semesterData[indexPath.row / 3] integerValue];
    NSInteger semester = indexPath.row % 3 + 1;
    
    _selectedYear = year;
    _selectedSemester = semester;
    
    [tableView reloadData];
    
    [_semesterDelegate semesterTableViewControllerDidSelectYear:year semester:semester];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}





- (IBAction)cancelPress:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end















