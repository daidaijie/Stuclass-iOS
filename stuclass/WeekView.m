//
//  WeekView.m
//  stuclass
//
//  Created by JunhaoWang on 7/19/15.
//  Copyright (c) 2015 JunhaoWang. All rights reserved.
//

#import "WeekView.h"
#import "Define.h"

#define LINE_WIDTH 0.4


@implementation WeekView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.opaque = YES;
        
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height/2.0)];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.textColor = MAIN_COLOR;
        _dateLabel.font = [UIFont systemFontOfSize:10.0];
        
        _weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height/2.3, frame.size.width, frame.size.height/2.0)];
        _weekLabel.textAlignment = NSTextAlignmentCenter;
        _weekLabel.textColor = MAIN_COLOR;
        _weekLabel.font = [UIFont systemFontOfSize:13.0];
        
        [self addSubview:_dateLabel];
        [self addSubview:_weekLabel];
    }
    
    return self;
}


@end
