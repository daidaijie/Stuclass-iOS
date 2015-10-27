//
//  HomeworkTextField.m
//  stuclass
//
//  Created by JunhaoWang on 10/28/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "HomeworkTextField.h"

@implementation HomeworkTextField


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 16;
    
    CGFloat line_width = 0.4;
    
    CGFloat offset = 0.0;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.780 green:0.780 blue:0.804 alpha:1.000].CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, line_width);
    
    CGContextMoveToPoint(context, offset, 0);
    CGContextAddLineToPoint(context, width - offset, 0);
    CGContextStrokePath(context);
}


@end
