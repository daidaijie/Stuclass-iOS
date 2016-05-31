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
    
    [_textView becomeFirstResponder];
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


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    [_textView becomeFirstResponder];
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
