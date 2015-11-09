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
    _usernameTextField = [[InputTextField alloc] initWithFrame:CGRectMake(kOffset, 0, width - kOffset * 2, self.frame.size.height / 2)];
    _usernameTextField.keyboardType = UIKeyboardTypeEmailAddress;
    _usernameTextField.returnKeyType = UIReturnKeyNext;
    _usernameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"校园网账号" attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self addSubview:_usernameTextField];
    
    // passwordTextField
    _passwordTextField = [[InputTextField alloc] initWithFrame:CGRectMake(kOffset, _usernameTextField.frame.size.height, _usernameTextField.frame.size.width, _usernameTextField.frame.size.height)];
    _passwordTextField.returnKeyType = UIReturnKeyGo;
    _passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"校园网密码" attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.clearsOnBeginEditing = YES;
    _passwordTextField.enablesReturnKeyAutomatically = YES;
    [self addSubview:_passwordTextField];
    
    // lineView
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(kOffset, self.frame.size.height / 2, width, 0.3)];
    lineView.backgroundColor = [UIColor blackColor];
    lineView.alpha = 0.15;
    [self addSubview:lineView];
}



@end














