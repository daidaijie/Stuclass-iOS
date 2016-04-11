//
//  TaskListTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 4/10/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "TaskListTableViewController.h"
#import "TaskListTableViewCell.h"
#import "Define.h"
#import <MGSwipeTableCell/MGSwipeButton.h>
#import "Task.h"
#import "StatusView.h"
#import "TaskAddTableViewController.h"
#import "MobClick.h"

@interface TaskListTableViewController () <MGSwipeTableCellDelegate, TaskAddDelegate>

@property (strong, nonatomic) NSMutableArray *doingData;
@property (strong, nonatomic) NSMutableArray *doneData;

@property (strong, nonatomic) NSArray *levelData;
@property (strong, nonatomic) NSArray *operationData;
@property (strong, nonatomic) UIView *emptyView;

@property (strong, nonatomic) StatusView *doingView;
@property (strong, nonatomic) StatusView *doneView;

@end

@implementation TaskListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBarBackButton];
    [self setupTableView];
    [self setupData];
}

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
    _doingView = [[StatusView alloc] init];
    _doneView = [[StatusView alloc] init];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    
    _emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, -10, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
    
    _emptyView.backgroundColor = [UIColor clearColor];
    
    UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _emptyView.frame.size.width, 50)];
    emptyLabel.center = CGPointMake(_emptyView.frame.size.width / 2, _emptyView.frame.size.height / 2 + 25);
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.textColor = MAIN_COLOR;
    emptyLabel.text = @"还没有要做的事>_<";
    [_emptyView addSubview:emptyLabel];
    
    UIImageView *emptyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 92, 92)];
    emptyImageView.center = CGPointMake(_emptyView.frame.size.width / 2, _emptyView.frame.size.height / 2 - 43);
    emptyImageView.image = [UIImage imageNamed:@"icon-empty-homework"];
    [_emptyView addSubview:emptyImageView];
    
    [self.view addSubview:_emptyView];
}

- (void)setupData
{
    _levelData = @[TASKLIST_LEVEL_0_COLOR, TASKLIST_LEVEL_1_COLOR, TASKLIST_LEVEL_2_COLOR];
    _operationData = @[TASKLIST_DONE, TASKLIST_DELETE, TASKLIST_REDO];
    
    // Get Data
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    BOOL secondTime = [ud boolForKey:@"TASKLIST_SECOND"];
    
    if (!secondTime) {
        // Init
        Task *task1 = [[Task alloc] initWithTitle:@"早上写完英语作业" level:@0];
        Task *task2 = [[Task alloc] initWithTitle:@"中午去下载汕大课程表" level:@1];
        Task *task3 = [[Task alloc] initWithTitle:@"下午吃阿吉米" level:@2];
        
        Task *task4 = [[Task alloc] initWithTitle:@"晚上睡大觉" level:@0];
        Task *task5 = [[Task alloc] initWithTitle:@"周末去桑浦山喝矿泉水" level:@1];
        
        
        _doingData = [NSMutableArray arrayWithArray:@[task1, task2, task3]];
        _doneData = [NSMutableArray arrayWithArray:@[task4, task5]];
        
        [self writeToUD];
        
        [ud setBool:YES forKey:@"TASKLIST_SECOND"];
        
    } else {
        _doingData = [self displayDataFromStorage:[ud objectForKey:@"DOING_DATA"]];
        _doneData = [self displayDataFromStorage:[ud objectForKey:@"DONE_DATA"]];
    }
}




#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return _doingView;
    } else {
        return _doneView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_doingData.count > 0 || _doneData.count > 0) {
        self.emptyView.hidden = self.tableView.scrollEnabled = YES;
        return 2;
    } else {
        self.emptyView.hidden = self.tableView.scrollEnabled = NO;
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    _doingView.statusLabel.text = [NSString stringWithFormat:@"进行中(%d)", _doingData.count];
    _doneView.statusLabel.text = [NSString stringWithFormat:@"已完成(%d)", _doneData.count];
    if (section == 0) {
        return _doingData.count;
    } else {
        return _doneData.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;

    TaskListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskListCell"];
    
    // Data
    
    if (_doingData.count > 0 || _doneData.count > 0) {

        if (section == 0) {
            
            Task *task = _doingData[row];
            
            cell.nameLabel.text = task.title;
            
            cell.levelView.backgroundColor = _levelData[[task.level integerValue]];
            
        } else {
            
            Task *task = _doneData[row];
            
            cell.nameLabel.text = task.title;
            
            cell.levelView.backgroundColor = _levelData[[task.level integerValue]];
        }
    }
    
    // MGSwipe
    cell.delegate = self;
    if (section == 0) {
        // doing
        cell.rightButtons = @[
            [MGSwipeButton buttonWithTitle:@"放弃" backgroundColor:_operationData[1]],
            [MGSwipeButton buttonWithTitle:@"完成" backgroundColor:_operationData[0]],
        ];
    } else {
        // done
        cell.rightButtons = @[
            [MGSwipeButton buttonWithTitle:@"删除" backgroundColor:_operationData[1]],
            [MGSwipeButton buttonWithTitle:@"重做" backgroundColor:_operationData[2]],
        ];
    }
    MGSwipeButton *btn1 = cell.rightButtons[0];
    MGSwipeButton *btn2 = cell.rightButtons[1];
    btn1.buttonWidth = btn2.buttonWidth = 80;
    
    cell.leftButtons = @[
        [MGSwipeButton buttonWithTitle:@"悠哉" backgroundColor:_levelData[0] callback:^BOOL(MGSwipeTableCell *sender) {
            return YES;
        }],
        [MGSwipeButton buttonWithTitle:@"要做" backgroundColor:_levelData[1] callback:^BOOL(MGSwipeTableCell *sender) {
            return YES;
        }],
        [MGSwipeButton buttonWithTitle:@"紧急" backgroundColor:_levelData[2] callback:^BOOL(MGSwipeTableCell *sender) {
            return YES;
        }],
    ];
    MGSwipeButton *btn11 = cell.leftButtons[0];
    MGSwipeButton *btn22 = cell.leftButtons[1];
    MGSwipeButton *btn33 = cell.leftButtons[2];
    btn11.buttonWidth = btn22.buttonWidth = btn33.buttonWidth = 70;
    
    cell.leftSwipeSettings.transition = cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;
    cell.leftSwipeSettings.enableSwipeBounces = cell.rightSwipeSettings.enableSwipeBounces = NO;
    return cell;
}

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion
{
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    
    if (direction == MGSwipeDirectionRightToLeft) {
        // Right
        if (index == 0) {
            // Delete
            if (path.section == 0) {
                [self.tableView beginUpdates];
                [_doingData removeObjectAtIndex:path.row];
                [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
                [MobClick event:@"TaskList_Giveup"];
            } else {
                [self.tableView beginUpdates];
                [_doneData removeObjectAtIndex:path.row];
                [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
                [MobClick event:@"TaskList_Delete"];
            }
        } else {
            if (path.section == 0) {
                // done
                [self.tableView beginUpdates];
                Task *tmp = _doingData[path.row];
                [_doneData insertObject:tmp atIndex:0];
                [_doingData removeObjectAtIndex:path.row];
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
                [MobClick event:@"TaskList_Done"];
            } else {
                // redo
                [self.tableView beginUpdates];
                Task *tmp = _doneData[path.row];
                [_doingData addObject:tmp];
                [_doneData removeObjectAtIndex:path.row];
                [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_doingData.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
                [MobClick event:@"TaskList_Redo"];
            }
        }
    } else {
        // Left
        if (path.section == 0) {
            [self.tableView beginUpdates];
            Task *task = _doingData[path.row];
            task.level = [NSNumber numberWithInteger:index];
            [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        } else {
            [self.tableView beginUpdates];
            Task *task = _doneData[path.row];
            task.level = [NSNumber numberWithInteger:index];
            [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }
        if (index == 0) {
            [MobClick event:@"TaskList_Level_0"];
        } else if (index == 1) {
            [MobClick event:@"TaskList_Level_1"];
        } else {
            [MobClick event:@"TaskList_Level_2"];
        }
    }
    
    [self writeToUD];
    
    return NO;
}


- (NSMutableArray *)displayDataFromStorage:(NSMutableArray *)storageData
{
    NSMutableArray *displayData = [NSMutableArray array];
    for (NSDictionary *dict in storageData) {
        Task *task = [[Task alloc] initWithTitle:dict[@"title"] level:dict[@"level"]];
        [displayData addObject:task];
    }
    return displayData;
}

- (NSMutableArray *)storageDataFromDisplay:(NSMutableArray *)displayData
{
    NSMutableArray *storageData = [NSMutableArray array];
    for (Task *task in displayData) {
        [storageData addObject:@{@"title": task.title, @"level": task.level}];
    }
    return storageData;
}

- (void)writeToUD
{
    NSMutableArray *doingStorage = [self storageDataFromDisplay:_doingData];
    NSMutableArray *doneStorage = [self storageDataFromDisplay:_doneData];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:doingStorage forKey:@"DOING_DATA"];
    [ud setObject:doneStorage forKey:@"DONE_DATA"];
}

- (void)taskDidAddWithTitle:(NSString *)title
{
    Task *task = [[Task alloc] initWithTitle:title level:@1];
    
    [self.tableView beginUpdates];
    [_doingData insertObject:task atIndex:0];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    [self writeToUD];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowTaskAdd"]) {
        TaskAddTableViewController *tatvc = segue.destinationViewController;
        tatvc.delegate = self;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end












