//
//  PersonViewController.m
//  stuclass
//
//  Created by JunhaoWang on 10/19/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "PersonViewController.h"
#import "ClassInfoTableViewCell.h"
#import "ClassNoteTableViewCell.h"
#import "ClassBox.h"

static const CGFloat kBarViewHeight = 43.0;

static NSString *info_cell_id = @"ClassInfoTableViewCell";

static NSString *note_cell_id = @"ClassNoteTableViewCell";

static const NSInteger kNumberOfSections = 2;

static const NSInteger kNumberOfRowsInNoteSection = 1;

static NSString *kTitleForInfoSection = @"课程信息";

static NSString *kTitleForNoteSection = @"备忘笔记";


@interface PersonViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSArray *infoTitleArray;

@end


@implementation PersonViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initInfoTitleArray];
    
    [self initTableView];
}


#pragma mark - Initialize Method


- (void)initInfoTitleArray
{
    self.infoTitleArray = @[@"课程", @"班号", @"教师", @"课室", @"学分", @"周数"];
}


- (void)initTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 64 - kBarViewHeight) style:UITableViewStyleGrouped];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.contentInset = UIEdgeInsetsMake(-12, 0, 0, 0);
    self.tableView.sectionFooterHeight = 5;
    
    UINib *nib = [UINib nibWithNibName:info_cell_id bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:info_cell_id];
    
    nib = [UINib nibWithNibName:note_cell_id bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:note_cell_id];
    
    
    [self.view addSubview:self.tableView];
}



#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.infoTitleArray.count;
    } else {
        return kNumberOfRowsInNoteSection;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return kTitleForInfoSection;
    } else {
        return kTitleForNoteSection;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 44.0;
    } else {
        return 140.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 0) {
        
        ClassInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:info_cell_id forIndexPath:indexPath];
        
        // 标题
        cell.infoLabel.text = self.infoTitleArray[row];
        
        // 内容
        NSString *content = @"";
        
        switch (row) {
            case 0:
                content = self.classBox.box_name;
                break;
            case 1:
                content = self.classBox.box_number;
                break;
            case 2:
                content = self.classBox.box_teacher;
                break;
            case 3:
                content = self.classBox.box_room;
                break;
            case 4:
                content = self.classBox.box_credit;
                break;
            case 5:
                content = self.classBox.box_span;
                break;
                
            default:
                break;
        }
        
        cell.detailLabel.text = content;
        
        return cell;
        
    } else {
        
        ClassNoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:note_cell_id forIndexPath:indexPath];
        
        return cell;
    }
    
}

@end











