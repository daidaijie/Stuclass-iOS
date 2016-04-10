//
//  LibraryTextField.m
//  stuclass
//
//  Created by JunhaoWang on 7/24/15.
//  Copyright (c) 2015 JunhaoWang. All rights reserved.
//

#import "LibraryTextField.h"
#import "Define.h"

#define LINE_WIDTH 1.6

@implementation LibraryTextField


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, MAIN_COLOR.CGColor);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, LINE_WIDTH);
    
    CGContextMoveToPoint(context, 0, self.bounds.size.height - LINE_WIDTH/2);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height - LINE_WIDTH/2);
    CGContextStrokePath(context);
}



@end
