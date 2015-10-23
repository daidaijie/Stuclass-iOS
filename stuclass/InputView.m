//
//  InputView.m
//  stuclass
//
//  Created by JunhaoWang on 10/10/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "InputView.h"
#import "InputTextField.h"

static const CGFloat kOffset = 20;


@implementation InputView


- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self initView];
}

- (void)initView {
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    // usernameTextField
    self.usernameTextField = [[InputTextField alloc] initWithFrame:CGRectMake(kOffset, 0, width-kOffset*2, self.frame.size.height/2)];
    self.usernameTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.usernameTextField.returnKeyType = UIReturnKeyNext;
    self.usernameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"校园网账号" attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self addSubview:self.usernameTextField];
    
    // passwordTextField
    self.passwordTextField = [[InputTextField alloc] initWithFrame:CGRectMake(kOffset, self.usernameTextField.frame.size.height, self.usernameTextField.frame.size.width, self.usernameTextField.frame.size.height)];
    self.passwordTextField.returnKeyType = UIReturnKeyGo;
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"校园网密码" attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.clearsOnBeginEditing = YES;
    self.passwordTextField.enablesReturnKeyAutomatically = YES;
    [self addSubview:self.passwordTextField];
    
    // lineView
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(kOffset, self.frame.size.height/2, width, 0.3)];
    lineView.backgroundColor = [UIColor blackColor];
    lineView.alpha = 0.15;
    [self addSubview:lineView];
}



@end














