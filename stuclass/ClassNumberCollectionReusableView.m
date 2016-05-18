//
//  ClassNumberCollectionReusableView.m
//  stuclass
//
//  Created by JunhaoWang on 10/12/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "ClassNumberCollectionReusableView.h"
#import "Define.h"

#define LINE_WIDTH 0.4

@implementation ClassNumberCollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
        
        _numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _numLabel.textAlignment = NSTextAlignmentCenter;
        _numLabel.textColor = MAIN_COLOR;
        _numLabel.font = [UIFont systemFontOfSize:13.0 * [UIScreen mainScreen].bounds.size.width / 320.0];
        
        [self addSubview:_numLabel];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, MAIN_COLOR.CGColor);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, LINE_WIDTH);
    
    CGContextMoveToPoint(context, 0, self.bounds.size.height-LINE_WIDTH/2);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height-LINE_WIDTH/2);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, self.bounds.size.width-LINE_WIDTH/2, 0);
    CGContextAddLineToPoint(context, self.bounds.size.width-LINE_WIDTH/2, self.bounds.size.height);
    CGContextStrokePath(context);
}

@end
