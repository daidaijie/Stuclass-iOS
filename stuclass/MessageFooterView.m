//
//  MessageFooterView.m
//  stuclass
//
//  Created by JunhaoWang on 5/31/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "MessageFooterView.h"

@implementation MessageFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - 30, 50)];
        _label.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
        _label.textColor = [UIColor lightGrayColor];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _label.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:_label];
    }
    
    return self;
}

@end
