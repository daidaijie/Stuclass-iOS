//
//  InputTextField.m
//  stuclass
//
//  Created by JunhaoWang on 10/10/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "InputTextField.h"

@implementation InputTextField

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.tintColor = [UIColor colorWithRed:0.639 green:0.204 blue:0.000 alpha:1.000];
        self.font = [UIFont systemFontOfSize:16.0];
        self.alpha = 0.6;
    }
    
    return self;
}

@end
