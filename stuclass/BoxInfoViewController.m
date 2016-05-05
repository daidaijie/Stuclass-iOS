//
//  BoxInfoViewController.m
//  stuclass
//
//  Created by JunhaoWang on 5/2/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "BoxInfoViewController.h"
#import "ClassInfoTableViewCell.h"
#import "ClassNoteTableViewCell.h"
#import "NoteTableViewController.h"
#import "Define.h"
#import "CoreDataManager.h"
#import "ClassParser.h"
#import "MobClick.h"
#import <SIAlertView/SIAlertView.h>

static NSString *info_cell_id = @"ClassInfoTableViewCell";

static NSString *note_cell_id = @"ClassNoteTableViewCell";

static const NSInteger kNumberOfSections = 2;

static const NSInteger kNumberOfRowsInNoteSection = 1;

static NSString *kTitleForInfoSection = @"格子信息";

static NSString *kTitleForNoteSection = @"备忘笔记";

static const CGFloat kHeightForPostButton = 52;


@interface BoxInfoViewController () <UITableViewDelegate, UITableViewDataSource, NoteTableViewControllerDelegate>

@property (strong, nonatomic) NSArray *infoTitleArray;

@property (strong, nonatomic) NSArray *imgArray;

@property (strong, nonatomic) NSString *noteStr;

@property (strong, nonatomic) NSString *timeStr;

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation BoxInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupBarBackButton];
    
    [self initDataArray];
    
    [self initTableView];
    
    [self initNoteStr];
}


#pragma mark - Initialize Method

- (void)setupBarBackButton
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
}


- (void)initDataArray
{
    _infoTitleArray = @[@"名称", @"描述", @"周数"];
    _imgArray = @[[UIImage imageNamed:@"icon-name"], [UIImage imageNamed:@"icon-number"], [UIImage imageNamed:@"icon-week"]];
}


- (void)initTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - kHeightForPostButton) style:UITableViewStyleGrouped];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    _tableView.contentInset = UIEdgeInsetsMake(-12, 0, 0, 0);
    _tableView.sectionFooterHeight = 5;
    
    UINib *nib = [UINib nibWithNibName:info_cell_id bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:info_cell_id];
    
    nib = [UINib nibWithNibName:note_cell_id bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:note_cell_id];
    
    
    [self.view addSubview:_tableView];
    
    
    // button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    button.frame = CGRectMake(0, _tableView.frame.size.height, self.view.frame.size.width, kHeightForPostButton);
    
    button.titleLabel.font = [UIFont systemFontOfSize:16.0];
    
    [button setTitle:@"删除格子" forState:UIControlStateNormal];
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    button.backgroundColor = MAIN_COLOR;
    
    button.alpha = 0.95;
    
    [button addTarget:self action:@selector(buttonPress) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
}

- (void)initNoteStr
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud valueForKey:@"USERNAME"];
    
    NSDictionary *dict = [[CoreDataManager sharedInstance] getNoteFromCoreDataWithClassID:_classBox.box_id username:username];
    _noteStr = dict[@"content"];
    _timeStr = dict[@"time"];
    
}

#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _infoTitleArray.count;
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

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        
        return (_timeStr.length > 0 && _timeStr != nil) ? [NSString stringWithFormat:@"更新于%@", _timeStr] : @"";
        
    } else {
        
        return @"";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 44.0;
    } else {
        return 130.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 0) {
        
        ClassInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:info_cell_id forIndexPath:indexPath];
        
        // 标题
        cell.infoLabel.text = _infoTitleArray[row];
        
        // 内容
        NSString *content = @"";
        
        switch (row) {
            case 0:
                content = _classBox.box_name;
                break;
            case 1:
                content = _classBox.box_description.length == 0 ? @"无" : _classBox.box_description;
                break;
            case 2:
                content = ([_classBox.box_span[0] integerValue] == [_classBox.box_span[1] integerValue]) ? [NSString stringWithFormat:@"%d", [_classBox.box_span[0] integerValue]] : [NSString stringWithFormat:@"%d-%d", [_classBox.box_span[0] integerValue], [_classBox.box_span[1] integerValue]];
                break;
            default:
                break;
        }
        
        cell.detailLabel.text = content;
        cell.iconImageView.image = _imgArray[row];
        
        return cell;
        
    } else {
        
        ClassNoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:note_cell_id forIndexPath:indexPath];
        
        cell.noteLabel.text = _noteStr;
        
        return cell;
    }
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        NoteTableViewController *ntvc = [sb instantiateViewControllerWithIdentifier:@"NoteTableVC"];
        
        ntvc.noteStr = _noteStr;
        ntvc.classID = _classBox.box_id;
        ntvc.delegate = self;
        
        [self.navigationController pushViewController:ntvc animated:YES];
    }
}


#pragma mark - NoteTableViewControllerDelegate

- (void)noteTableViewControllerDidSaveNote:(NSString *)noteStr time:(NSString *)timeStr
{
    _noteStr = noteStr;
    _timeStr = timeStr;
    
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    
    [MobClick event:@"Detail_Save_Note"];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
}


// delete
- (void)buttonPress
{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"警告" andMessage:@"确定删除格子吗?"];
    
    [alertView addButtonWithTitle:@"取消" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView){
    }];
    
    [alertView addButtonWithTitle:@"确定" type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView){
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *username = [ud valueForKey:@"USERNAME"];
        NSDictionary *dict = [ud valueForKey:@"YEAR_AND_SEMESTER"];
        NSInteger year = [dict[@"year"] integerValue];
        NSInteger semester = [dict[@"semester"] integerValue];
        
        
        [[CoreDataManager sharedInstance] deleteClassWithClassID:_classBox.box_id withYear:year semester:semester username:username];
        
        NSArray *classData = [[CoreDataManager sharedInstance] getClassDataFromCoreDataWithYear:year semester:semester username:username];
        
        NSArray *boxData = [[ClassParser sharedInstance] parseClassData:classData];
        
        [_delegate boxInfoDelegateDidChanged:boxData];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [alertView show];
}




@end
