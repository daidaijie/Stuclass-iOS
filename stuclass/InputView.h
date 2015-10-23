//
//  InputView.h
//  stuclass
//
//  Created by JunhaoWang on 10/10/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InputTextField;

@interface InputView : UIView

@property (strong, nonatomic) InputTextField *usernameTextField;
@property (strong, nonatomic) InputTextField *passwordTextField;

@end
