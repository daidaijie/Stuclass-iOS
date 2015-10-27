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
    
    self.placeholder = [[UILabel alloc] initWithFrame:CGRectMake(5, 3, 200, 30)];
    self.placeholder.textColor = [UIColor colorWithRed:0.780 green:0.780 blue:0.804 alpha:1.000];
    self.placeholder.font = [UIFont systemFontOfSize:16.0];
    
    [self addSubview:self.placeholder];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
