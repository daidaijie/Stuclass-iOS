//
//  MessageCommentTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 5/31/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "MessageCommentTableViewController.h"
#import "MBProgressHUD.h"
#import "Define.h"
#import <AFNetworking/AFNetworking.h>
#import <KVNProgress/KVNProgress.h>
#import "PlaceholderTextView.h"
#import "MobClick.h"
#import "MessageDetailViewController.h"

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

static const NSInteger kNumberOfSections = 1;

static const NSInteger kNumberOfRowsInNoteSection = 1;

@interface MessageCommentTableViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet PlaceholderTextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@end

@implementation MessageCommentTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTableView];
    [self setupTextView];
    [self setupData];
}

#pragma mark - Setup Method

- (void)setupTableView
{
    self.tableView.contentInset = UIEdgeInsetsMake(-12, 0, 0, 0);
}

- (void)setupTextView
{
    _textView.placeholder.text = @"你发表的消息好赞...";
}

- (void)setupData
{
    if (_atPerson.length > 0) {
        _textView.text = [NSString stringWithFormat:@"@%@: ", _atPerson];
        _textView.placeholder.hidden = YES;
        _countLabel.text = [NSString stringWithFormat:@"%d", _textView.text.length];
    }
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

- (IBAction)sendItemPress:(id)sender
{
    [_textView resignFirstResponder];
    
    if (_textView.text.length == 0) {
        [self showHUDWithText:@"内容不能为空" andHideDelay:global_hud_delay];
        [self performSelector:@selector(activateTextField) withObject:nil afterDelay:global_hud_delay];
    } else if ([_textView.text rangeOfString:@"\n\n\n"].location != NSNotFound) {
        [self showHUDWithText:@"不能连续换三行以上" andHideDelay:global_hud_delay];
        [self performSelector:@selector(activateTextField) withObject:nil afterDelay:global_hud_delay];
    } else if (_textView.text.length > 200) {
        [self showHUDWithText:@"限制200字以内" andHideDelay:global_hud_delay];
        [self performSelector:@selector(activateTextField) withObject:nil afterDelay:global_hud_delay];
    } else {
        [self sendCommentRequest];
        [MobClick event:@"Message_Post_Comment"];
    }
}

- (void)activateTextField
{
    [_textView becomeFirstResponder];
}


- (IBAction)backItemPress:(id)sender
{
    [_textView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)sendCommentRequest
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [KVNProgress showWithStatus:@"正在发表评论"];
    
    // ud
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *token = [ud valueForKey:@"USER_TOKEN"];
    NSString *user_id = [ud valueForKey:@"USER_ID"];
    
    // post data
    NSDictionary *postData = @{
                                 @"uid": user_id,
                                 @"token": token,
                                 @"comment": _textView.text,
                                 @"post_id": _post_id,
                                 };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", global_host, message_comment_url] parameters:postData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
        NSLog(@"评论 - 连接服务器 - 成功 - %@", responseObject);
//        NSLog(@"评论 - 连接服务器 - 成功");
        [KVNProgress showSuccessWithStatus:@"发表评论成功" completion:^{
            [self dismissViewControllerAnimated:YES completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CommentPost" object:nil userInfo:@{@"id": [NSString stringWithFormat:@"%@", responseObject[@"id"]]}];
        }];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSLog(@"评论 - 连接服务器 - 失败 - %@", operation.error);
//        NSLog(@"评论 - 连接服务器 - 失败");
        NSUInteger code = operation.response.statusCode;
        
        if (code == 401) {
            // wrong token
            [KVNProgress showErrorWithStatus:global_connection_wrong_token completion:^{
                [self dismissViewControllerAnimated:YES completion:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CommentLogout" object:nil];
            }];
        } else {
            [KVNProgress showErrorWithStatus:global_connection_failed completion:^{
                [self activateTextField];
            }];
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
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
