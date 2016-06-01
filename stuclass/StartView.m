//
//  StartView.m
//  stuclass
//
//  Created by JunhaoWang on 7/19/15.
//  Copyright (c) 2015 JunhaoWang. All rights reserved.
//

#import "StartView.h"
#import "Define.h"

#define LINE_WIDTH 0.4

@implementation StartView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.05];
    }
    
    return self;
}



// 画一条斜线
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, MAIN_COLOR.CGColor);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, LINE_WIDTH);
    
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, 0, self.bounds.size.height-LINE_WIDTH/2);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height-LINE_WIDTH/2);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, self.bounds.size.width-LINE_WIDTH/2, 0);
    CGContextAddLineToPoint(context, self.bounds.size.width-LINE_WIDTH/2, self.bounds.size.height);
    CGContextStrokePath(context);
}










@end
