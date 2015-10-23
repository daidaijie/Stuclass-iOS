//
//  NoteTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 10/23/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "NoteTableViewController.h"
#import "CoreDataManager.h"

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

static const NSInteger kNumberOfSections = 1;

static const NSInteger kNumberOfRowsInNoteSection = 1;

static const CGFloat kRowHeightFor4 = 118;

static const CGFloat kRowHeightFor5 = 206;

static const CGFloat kRowHeightFor6 = 298;

static const CGFloat kRowHeightFor6p = 354;

@interface NoteTableViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation NoteTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTableView];
    [self setupNote];
}


#pragma mark - Setup Method

- (void)setupTableView
{
    self.tableView.contentInset = UIEdgeInsetsMake(-12, 0, 0, 0);
    [self.textView becomeFirstResponder];
}

- (void)setupNote
{
    self.textView.text = self.noteStr;
}


#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kNumberOfRowsInNoteSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (SCREEN_HEIGHT == 480.0) {
        
        // 4
        return kRowHeightFor4;
        
    } else if (SCREEN_HEIGHT == 568.0) {
        
        // 5
        return kRowHeightFor5;
        
    } else if (SCREEN_HEIGHT == 667.0) {
        
        // 6
        return kRowHeightFor6;
        
    } else if (SCREEN_HEIGHT == 736.0) {
        
        // 6+
        return kRowHeightFor6p;
        
    } else {
        
        return kRowHeightFor5;
    }
}


- (IBAction)saveItemPress:(id)sender
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud valueForKey:@"USERNAME"];
    
    // date
    NSDate *date = [self getCurrentZoneDate:[NSDate date]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterFullStyle;
    formatter.dateFormat = @"yyyy年MM月dd日HH时mm分ss秒";
    
    NSString *timeStr = [formatter stringFromDate:date];
    NSLog(@"更新笔记时间 - %@", timeStr);
    
    // content
    [[CoreDataManager sharedInstance] writeNoteToCoreDataWithContent:self.textView.text time:timeStr classID:_classID username:username];
    
    [_delegate noteTableViewControllerDidSaveNote:self.textView.text time:timeStr];
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (NSDate *)getCurrentZoneDate:(NSDate *)date {
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    
    return [date dateByAddingTimeInterval:interval];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
















