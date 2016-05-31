//
//  HomeworkPostTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 10/24/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "HomeworkPostTableViewController.h"
#import "Define.h"
#import <AFNetworking/AFNetworking.h>
#import "MBProgressHUD.h"
#import <KVNProgress/KVNProgress.h>
#import "ClassBox.h"
#import "Homework.h"
#import "DetailViewController.h"
#import "JHDater.h"
#import "PlaceholderTextView.h"
#import "HomeworkTextField.h"

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

static const NSInteger kNumberOfSections = 1;

static const NSInteger kNumberOfRowsInNoteSection = 1;

@interface HomeworkPostTableViewController () <UITextViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet PlaceholderTextView *textView;

@property (weak, nonatomic) IBOutlet HomeworkTextField *textField;

@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@end

@implementation HomeworkPostTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTableView];
    [self setupTextView];
}

#pragma mark - Setup Method

- (void)setupTableView
{
    self.tableView.contentInset = UIEdgeInsetsMake(-12, 0, 0, 0);
}

- (void)setupTextView
{
    _textView.placeholder.text = @"告诉大家有什么作业...";
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.text.length > 1) {
        // 禁止换行
        NSString *originStr = textView.text;
        NSString *lastTwoChar = [originStr substringWithRange:NSMakeRange(originStr.length - 2, 2)];
        
        if ([lastTwoChar isEqualToString:@"\n\n"] && [text isEqualToString:@"\n"]) {
            return NO;
        }
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    _countLabel.text = [NSString stringWithFormat:@"%d", textView.text.length];
    
    _textView.placeholder.hidden = (textView.text.length > 0);
}


#pragma mark - Event

- (IBAction)postItemPress:(id)sender
{
    [_textView resignFirstResponder];
    [_textField resignFirstResponder];
    
    if (_textView.text.length == 0) {
        [self showHUDWithText:@"作业内容不能为空" andHideDelay:global_hud_delay];
        [self performSelector:@selector(activateTextField) withObject:nil afterDelay:global_hud_delay];
    } else if ([_textView.text rangeOfString:@"\n\n\n"].location != NSNotFound) {
        [self showHUDWithText:@"不能连续换三行以上" andHideDelay:global_hud_delay];
        [self performSelector:@selector(activateTextField) withObject:nil afterDelay:global_hud_delay];
    } else if (_textView.text.length > 180) {
        [self showHUDWithText:@"限制180字以内" andHideDelay:global_hud_delay];
        [self performSelector:@selector(activateTextField) withObject:nil afterDelay:global_hud_delay];
    } else if (_textField.text.length > 16) {
        [self showHUDWithText:@"截止时间16字以内" andHideDelay:global_hud_delay];
        [self performSelector:@selector(activateTimeTextField) withObject:nil afterDelay:global_hud_delay];
    } else {
        [KVNProgress showWithStatus:@"正在发布"];
        [self sendRequest:YES];
    }
}

- (void)activateTextField
{
    [_textView becomeFirstResponder];
}

- (void)activateTimeTextField
{
    [_textField becomeFirstResponder];
}


#pragma mark - Networking

- (void)sendRequest:(BOOL)firstTry
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *dict = [ud valueForKey:@"YEAR_AND_SEMESTER"];
    
    NSInteger year = [dict[@"year"] integerValue];
    NSInteger semester = [dict[@"semester"] integerValue];
    
    NSString *username = [ud valueForKey:@"USERNAME"];
    
    NSString *token = [ud valueForKey:@"USER_TOKEN"];
    
    // post data
    
    NSDictionary *postData = @{
                               @"publisher": username,
                               @"pub_time": @"123",
                               @"content": _textView.text,
                               @"hand_in_time": _textField.text,
                               @"number": _dvc.classBox.box_number,
                               @"semester": [NSString stringWithFormat:@"%d", semester],
                               @"start_year": [NSString stringWithFormat:@"%d", year],
                               @"end_year": [NSString stringWithFormat:@"%d", year + 1],
                               @"token": token,
                               };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", global_old_host, homework_post_url] parameters:postData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
        NSLog(@"发布作业 - 连接服务器 - 成功 - %@", responseObject);
        [self parseResponseObject:responseObject firstTry:firstTry];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSLog(@"发布作业 - 连接服务器 - 失败 - %@", error);
        [KVNProgress showErrorWithStatus:global_connection_failed completion:^{
            [_textView becomeFirstResponder];
        }];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
}


- (void)parseResponseObject:(NSDictionary *)responseObject firstTry:(BOOL)firstTry
{
    NSString *errorStr = responseObject[@"ERROR"];
    NSString *statusStr = responseObject[@"status"];
    
    if (errorStr) {
        
        if ([errorStr isEqualToString:@"wrong token"]) {
            
            [KVNProgress showErrorWithStatus:global_connection_wrong_token];
                
            [self performSelector:@selector(logout) withObject:nil afterDelay:0.3];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
        } else if ([errorStr isEqualToString:@"no such class"]) {
            
            if (firstTry) {
                
                [self sendClassInfoToServer];
                
            } else {
                NSLog(@"发生未知错误");
                [KVNProgress showErrorWithStatus:global_connection_failed completion:^{
                    [_textView becomeFirstResponder];
                }];
            }
            
        } else {
            NSLog(@"发生未知错误");
            [KVNProgress showErrorWithStatus:global_connection_failed completion:^{
                [_textView becomeFirstResponder];
            }];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
        
    } else if (statusStr) {
        
        Homework *homework = [[Homework alloc] init];
        
        homework.content = _textView.text;
        
        homework.pub_time = [[JHDater sharedInstance] getNowSecondFrom1970];
        
        homework.publisher = [[NSUserDefaults standardUserDefaults] valueForKey:@"USERNAME"];
        
        homework.nickname = [[NSUserDefaults standardUserDefaults] valueForKey:@"NICKNAME"];
        
        homework.deadline = _textField.text;
        
        homework.homework_id = [statusStr integerValue];
        
        [_delegate homeworkPostTableViewControllerPostSuccessfullyWithHomework:homework];
        
        [KVNProgress showSuccessWithStatus:@"发布成功" completion:^{
            
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } else {
        NSLog(@"发生未知错误");
        [KVNProgress showErrorWithStatus:global_connection_failed completion:^{
            [_textView becomeFirstResponder];
        }];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}


- (void)sendClassInfoToServer
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *dict = [ud valueForKey:@"YEAR_AND_SEMESTER"];
    
    NSInteger year = [dict[@"year"] integerValue];
    
    NSInteger semester = [dict[@"semester"] integerValue];
    
    // post data
    
    NSDictionary *postData = @{
                               @"number": _dvc.classBox.box_number,
                               @"name": _dvc.classBox.box_name,
                               @"credit": _dvc.classBox.box_credit,
                               @"teacher": _dvc.classBox.box_teacher,
                               @"room": _dvc.classBox.box_room,
                               @"span": [NSString stringWithFormat:@"%d-%d", [_dvc.classBox.box_span[0] integerValue], [_dvc.classBox.box_span[1] integerValue]],
                               @"time": [NSString stringWithFormat:@"x - %d y - %d length - %d", _dvc.classBox.box_x, _dvc.classBox.box_y, _dvc.classBox.box_length],
                               @"semester": [NSString stringWithFormat:@"%d", semester],
                               @"start_year": [NSString stringWithFormat:@"%d", year],
                               @"end_year": [NSString stringWithFormat:@"%d", year + 1],
                               };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", global_old_host, course_url] parameters:postData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
        NSLog(@"作业 - 添加课程 - 连接服务器 - 成功 - %@", responseObject);
        [self parseClassInfoResponseObject:responseObject];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSLog(@"作业 - 添加课程 - 连接服务器 - 失败 - %@", error);
        [KVNProgress showErrorWithStatus:global_connection_failed completion:^{
            [_textView becomeFirstResponder];
        }];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
}


- (void)parseClassInfoResponseObject:(NSDictionary *)responseObject
{
    NSString *errorStr = responseObject[@"ERROR"];
    
    if (errorStr) {
        
        [KVNProgress showErrorWithStatus:global_connection_failed completion:^{
            [_textView becomeFirstResponder];
        }];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } else {
        
        // 添加成功
        [self sendRequest:NO];
    }
}



// Log Out
- (void)logout
{
    [self logoutClearData];
    [self.navigationController.tabBarController.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)logoutClearData
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    // ud
    [ud setValue:nil forKey:@"USER_TOKEN"];
    [ud setValue:nil forKey:@"YEAR_AND_SEMESTER"];
    [ud setValue:nil forKey:@"NICKNAME"];
    [ud setValue:nil forKey:@"AVATAR_URL"];
    [ud setValue:nil forKey:@"USER_ID"];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


















