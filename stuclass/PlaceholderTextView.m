//
//  PlaceholderTextView.m
//  stuclass
//
//  Created by JunhaoWang on 10/27/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "PlaceholderTextView.h"

@implementation PlaceholderTextView


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _placeholder = [[UILabel alloc] initWithFrame:CGRectMake(5, 3, 200, 30)];
    _placeholder.textColor = [UIColor colorWithRed:0.804 green:0.804 blue:0.827 alpha:1.0];
    _placeholder.font = [UIFont systemFontOfSize:16.0];
    
    [self addSubview:_placeholder];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
