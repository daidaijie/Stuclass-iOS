//
//  NoteTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 10/23/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "NoteTableViewController.h"
#import "CoreDataManager.h"
#import "Define.h"
#import "PlaceholderTextView.h"

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

static const NSInteger kNumberOfSections = 1;

static const NSInteger kNumberOfRowsInNoteSection = 1;

@interface NoteTableViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet PlaceholderTextView *textView;

@end

@implementation NoteTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTableView];
    [self setupTextView];
    [self setupNote];
}


#pragma mark - Setup Method

- (void)setupTableView
{
    self.tableView.contentInset = UIEdgeInsetsMake(-12, 0, 0, 0);
}

- (void)setupTextView
{
    _textView.placeholder.text = @"今天，我要认真听课...";
}

- (void)setupNote
{
    _textView.text = _noteStr;
    _textView.placeholder.hidden = (_textView.text.length > 0);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_textView becomeFirstResponder];
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
        return global_textView_RowHeightFor4;
        
    } else if (SCREEN_HEIGHT == 568.0) {
        
        // 5
        return global_textView_RowHeightFor5;
        
    } else if (SCREEN_HEIGHT == 667.0) {
        
        // 6
        return global_textView_RowHeightFor6;
        
    } else if (SCREEN_HEIGHT == 736.0) {
        
        // 6+
        return global_textView_RowHeightFor6p;
        
    } else {
        
        return global_textView_RowHeightFor5;
    }
}


#pragma mark - TextView Delegate

- (void)textViewDidChange:(UITextView *)textView
{
    _textView.placeholder.hidden = (textView.text.length > 0);
}



- (IBAction)saveItemPress:(id)sender
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud valueForKey:@"USERNAME"];
    
    NSString *timeStr = @"";
    
    if (_textView.text.length > 0) {
        
        // date
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterFullStyle;
        formatter.dateFormat = @"yyyy年MM月dd日HH时mm分ss秒";
        
        timeStr = [formatter stringFromDate:date];
        NSLog(@"更新笔记时间 - %@", timeStr);
    } else {
        NSLog(@"去除笔记");
    }
    
    // content
    [[CoreDataManager sharedInstance] writeNoteToCoreDataWithContent:_textView.text time:timeStr classID:_classID username:username];
    
    [_delegate noteTableViewControllerDidSaveNote:_textView.text time:timeStr];
    
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
















