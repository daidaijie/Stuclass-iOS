//
//  EditBoxTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 5/23/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "EditBoxTableViewController.h"
#import "Define.h"
#import "MBProgressHUD.h"
#import "PlaceholderTextView.h"
#import "CoreDataManager.h"
#import "ClassParser.h"
#import "JHDater.h"


@interface EditBoxTableViewController () <UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) UIPickerView *timePickerView;
@property (strong, nonatomic) UIPickerView *weekPickerView;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *weekLabel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *weekSegment;

@property (weak, nonatomic) IBOutlet PlaceholderTextView *textView;

@property (weak, nonatomic) IBOutlet PlaceholderTextView *descriptionTextView;

@property (weak, nonatomic) IBOutlet UISwitch *colorSwitch;

@property (nonatomic) NSUInteger week;
@property (nonatomic) NSUInteger start;
@property (nonatomic) NSUInteger span;

@property (nonatomic) NSUInteger startWeek;
@property (nonatomic) NSUInteger endWeek;

@property (nonatomic) NSString *weekType;

// data

@end

@implementation EditBoxTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTableView];
    [self setupTextView];
    [self setupData];
    [self setupPickerView];
}

- (void)setupTableView
{
    self.tableView.contentInset = UIEdgeInsetsMake(-12, 0, 0, 0);
}

- (void)setupTextView
{
    _textView.placeholder.text = @"一节课或一件事...";
    _descriptionTextView.placeholder.text = @"班号、教师、教室、学分...";
}

- (void)setupData
{
    // Setup
    _textView.text = _classBox.box_name;
    _descriptionTextView.text = _classBox.box_description;
    
    _week = _classBox.box_x + 1;
    _start = _classBox.box_y + 1;
    _span = _classBox.box_length;
    
    _startWeek = [_classBox.box_span[0] integerValue];
    _endWeek = [_classBox.box_span[1] integerValue];;
    
    _weekType = _classBox.box_weekType;
    
    _colorSwitch.on = _classBox.box_isColorful;
    
    // Display
    
    // weekType
    if ([_weekType isEqualToString:@""]) {
        _weekSegment.selectedSegmentIndex = 0;
    } else if ([_weekType isEqualToString:@"单"]) {
        _weekSegment.selectedSegmentIndex = 1;
    } else if ([_weekType isEqualToString:@"双"]) {
        _weekSegment.selectedSegmentIndex = 2;
    }
    
    // weekLabel
    _weekLabel.text = (_startWeek == _endWeek) ? [NSString stringWithFormat:@"%d", _startWeek] : [NSString stringWithFormat:@"%d-%d", _startWeek, _endWeek];
    
    // timeLabel
    NSString *weekStr;
    switch (_week - 1) {
        case 0:
            weekStr = @"星期一";
            break;
        case 1:
            weekStr = @"星期二";
            break;
        case 2:
            weekStr = @"星期三";
            break;
        case 3:
            weekStr = @"星期四";
            break;
        case 4:
            weekStr = @"星期五";
            break;
        case 5:
            weekStr = @"星期六";
            break;
        default:
            weekStr = @"星期日";
            break;
    }
    
    NSMutableString *timeStr = [NSMutableString string];
    for (NSUInteger i = 0; i < _span; i++) {
        NSUInteger time = _start + i;
        
        NSString *timeCh = [NSString stringWithFormat:@"%d", time];
        if (time == 10) {
            timeCh = @"0";
        } else if (time == 11) {
            timeCh = @"A";
        } else if (time == 12) {
            timeCh = @"B";
        } else if (time == 13) {
            timeCh = @"C";
        }
        
        [timeStr appendString:timeCh];
    }
    
    _timeLabel.text = [NSString stringWithFormat:@"%@ %@", weekStr, timeStr];
}

- (void)setupPickerView
{
    _timePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 20, 260)];
    
    _timePickerView.tag = 1;
    
    _timePickerView.delegate = self;
    
    _weekPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 20, 260)];
    
    _weekPickerView.tag = 2;
    
    _weekPickerView.delegate = self;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //    [_textView becomeFirstResponder];
}

#pragma mark - TextView Delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [_textView resignFirstResponder];
        [_descriptionTextView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.tag == 0) {
        _textView.placeholder.hidden = (textView.text.length > 0);
    } else {
        _descriptionTextView.placeholder.hidden = (textView.text.length > 0);
    }
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    
    if (row == 3) {
        [self pickTime];
    } else if (row == 4) {
        [self pickWeek];
    }
}

- (void)pickTime
{
    // set pickerView data
    
    [_timePickerView selectRow:(_week - 1) inComponent:0 animated:NO];
    [_timePickerView selectRow:(_start - 1) inComponent:1 animated:NO];
    [_timePickerView selectRow:(_span - 1) inComponent:2 animated:NO];
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择时间\n\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert.view addSubview:_timePickerView];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSUInteger week = [_timePickerView selectedRowInComponent:0] + 1;
        NSUInteger start = [_timePickerView selectedRowInComponent:1] + 1;
        NSUInteger span = [_timePickerView selectedRowInComponent:2] + 1;
        
        // check
        if (start + span > 14) {
            [self showHUDWithText:@"时间超出课表范围了" andHideDelay:0.8];
        } else {
            // week
            
            // data setting
            _week = week;
            _start = start;
            _span = span;
            
            NSString *weekStr;
            switch (week - 1) {
                case 0:
                    weekStr = @"星期一";
                    break;
                case 1:
                    weekStr = @"星期二";
                    break;
                case 2:
                    weekStr = @"星期三";
                    break;
                case 3:
                    weekStr = @"星期四";
                    break;
                case 4:
                    weekStr = @"星期五";
                    break;
                case 5:
                    weekStr = @"星期六";
                    break;
                default:
                    weekStr = @"星期日";
                    break;
            }
            
            // time
            NSMutableString *timeStr = [NSMutableString string];
            for (NSUInteger i = 0; i < span; i++) {
                NSUInteger time = start + i;
                
                NSString *timeCh = [NSString stringWithFormat:@"%d", time];
                if (time == 10) {
                    timeCh = @"0";
                } else if (time == 11) {
                    timeCh = @"A";
                } else if (time == 12) {
                    timeCh = @"B";
                } else if (time == 13) {
                    timeCh = @"C";
                }
                
                [timeStr appendString:timeCh];
            }
            
            _timeLabel.text = [NSString stringWithFormat:@"%@ %@", weekStr, timeStr];
            
            NSLog(@"设置时间 - %@", _timeLabel.text);
        }
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    [alert addAction:confirm];
    
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:^{ }];
}

- (void)pickWeek
{
    // set pickerView data
    
    [_weekPickerView selectRow:(_startWeek - 1) inComponent:0 animated:NO];
    [_weekPickerView selectRow:(_endWeek - 1) inComponent:2 animated:NO];
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择周数\n\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert.view addSubview:_weekPickerView];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSUInteger startWeek = [_weekPickerView selectedRowInComponent:0] + 1;
        NSUInteger endWeek = [_weekPickerView selectedRowInComponent:2] + 1;
        
        // check
        if (startWeek > endWeek) {
            [self showHUDWithText:@"周数选择有误" andHideDelay:0.8];
        } else {
            // week
            
            // data setting
            _startWeek = startWeek;
            _endWeek = endWeek;
            
            _weekLabel.text = (startWeek == endWeek) ? [NSString stringWithFormat:@"%d", startWeek] : [NSString stringWithFormat:@"%d-%d", startWeek, endWeek];
        }
        NSLog(@"设置周数 %d-%d", _startWeek, _endWeek);
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    [alert addAction:confirm];
    
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:^{ }];
}


#pragma mark - Picker Delegate

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == 1) {
        if (component == 0) {
            return 7;
        } else if (component == 1) {
            return 13;
        } else {
            return 13;
        }
    } else {
        if (component == 1) {
            return 1;
        } else {
            return 16;
        }
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == 1) {
        if (component == 0) {
            NSString *weekStr;
            switch (row) {
                case 0:
                    weekStr = @"星期一";
                    break;
                case 1:
                    weekStr = @"星期二";
                    break;
                case 2:
                    weekStr = @"星期三";
                    break;
                case 3:
                    weekStr = @"星期四";
                    break;
                case 4:
                    weekStr = @"星期五";
                    break;
                case 5:
                    weekStr = @"星期六";
                    break;
                default:
                    weekStr = @"星期日";
                    break;
            }
            return weekStr;
        } else if (component == 1) {
            NSUInteger start = row + 1;
            NSString *startStr = [NSString stringWithFormat:@"%d", start];
            if (start == 10) {
                startStr = @"0";
            } else if (start == 11) {
                startStr = @"A";
            } else if (start == 12) {
                startStr = @"B";
            } else if (start == 13) {
                startStr = @"C";
            }
            return startStr;
        } else {
            return [NSString stringWithFormat:@"共%d节", row + 1];
        }
    } else {
        if (component == 1) {
            return @"-";
        } else {
            return [NSString stringWithFormat:@"%d", row + 1];
        }
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView.tag == 1) {
        return 3;
    } else {
        return 3;
    }
}

- (IBAction)weekTypeValueChanged:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case 0:
            _weekType = @"";
            break;
        case 1:
            _weekType = @"单";
            break;
        case 2:
            _weekType = @"双";
            break;
            
        default:
            break;
    }
    NSLog(@"设置weekType - %@", _weekType);
}


- (IBAction)confirm:(id)sender
{
    // first check
    if (_textView.text.length == 0) {
        [self showHUDWithText:@"格子名称不能为空" andHideDelay:0.8];
        return;
    }
    
    if (_textView.text.length > 40) {
        [self showHUDWithText:@"格子名称太长了(最多40个字符)" andHideDelay:0.8];
        return;
    }
    
    // second check
    if (![self checkConflict]) {
        // ok and update
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *username = [ud valueForKey:@"USERNAME"];
        NSDictionary *dict = [ud valueForKey:@"YEAR_AND_SEMESTER"];
        NSInteger year = [dict[@"year"] integerValue];
        NSInteger semester = [dict[@"semester"] integerValue];
        
        NSString *classID = [[JHDater sharedInstance] dateStringForDate:[NSDate date] withFormate:@"yyyyMMddHHmmssff"];
        
        [[CoreDataManager sharedInstance] writeBoxToCoreDataWithClassName:_textView.text classID:classID week:_week start:_start span:_span startWeek:_startWeek endWeek:_endWeek weekType:_weekType description:_descriptionTextView.text isColor:_colorSwitch.isOn withYear:year semester:semester username:username];
        
        NSArray *classData = [[CoreDataManager sharedInstance] getClassDataFromCoreDataWithYear:year semester:semester username:username];
        
        NSArray *boxData = [[ClassParser sharedInstance] parseClassData:classData];
        
//        [_delegate addBoxDelegateDidAdd:boxData];
        [self.navigationController popViewControllerAnimated:YES];
        [self showHUDWithText:@"添加成功" andHideDelay:1.0];
    }
}


- (BOOL)checkConflict
{
    BOOL conflict = NO;
    
    for (ClassBox *box in _boxData) {
        //        NSLog(@"- %@", box.box_name);
        //        NSLog(@"x - %d y - %d", box.box_x, box.box_y);
        //        NSLog(@"span - %@", box.box_span);
        //        NSLog(@"type -  %@\n", box.box_weekType);
        
        NSUInteger startWeek = [box.box_span[0] integerValue];
        NSUInteger endWeek = [box.box_span[1] integerValue];
        
        if (_week == box.box_x + 1) {
            // 星期冲突
            NSUInteger box_start = box.box_y + 1;
            NSUInteger box_end = box_start + box.box_length - 1;
            
            NSUInteger start = _start;
            NSUInteger end = _start + _span - 1;
            
            if (!(start > box_end || box_start > end)) {
                // 时间冲突 - 然后检查是否满足周数 满足就冲突了
                if (!(_startWeek > endWeek || startWeek > _endWeek)) {
                    // 在范围之内
                    if (_weekType.length == 0) {
                        conflict = YES;
                        [self showHUDWithText:[NSString stringWithFormat:@"与 %@ 冲突", box.box_name] andHideDelay:0.8];
                        break;
                    } else {
                        if ([_weekType isEqualToString:box.box_weekType]) {
                            conflict = YES;
                            [self showHUDWithText:[NSString stringWithFormat:@"与 %@ 冲突", box.box_name] andHideDelay:0.8];
                            break;
                        }
                    }
                }
            }
        }
    }
    
    return conflict;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - HUD

- (void)showHUDWithText:(NSString *)string andHideDelay:(NSTimeInterval)delay {
    
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    
    if (self.navigationController.view) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = string;
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:delay];
    }
}

@end





