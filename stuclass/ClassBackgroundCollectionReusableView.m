//
//  ClassBackgroundCollectionReusableView.m
//  stuclass
//
//  Created by JunhaoWang on 10/12/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "ClassBackgroundCollectionReusableView.h"
#import "Define.h"

#define LINE_WIDTH 0.4
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

@implementation ClassBackgroundCollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
    }
    
    return self;
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGFloat height = self.bounds.size.height;
    CGFloat k = SCREEN_WIDTH / 320.0;
    CGFloat w = 42.5 * k;
    CGFloat l = 2.4;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, MAIN_COLOR.CGColor);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, LINE_WIDTH);
    
    for (int i = 0; i < 7; i++) {
        // --
        CGContextMoveToPoint(context,  w * (i) - l, height - LINE_WIDTH / 2);
        CGContextAddLineToPoint(context, w * (i) + l - LINE_WIDTH / 2, height - LINE_WIDTH / 2);
        CGContextStrokePath(context);
        
        // |
        CGContextMoveToPoint(context,  w * (i) - LINE_WIDTH / 2, 0);
        CGContextAddLineToPoint(context, w * (i) - LINE_WIDTH / 2, l - LINE_WIDTH / 2);
        CGContextStrokePath(context);
        
        // |
        CGContextMoveToPoint(context,  w * (i) - LINE_WIDTH / 2, height - l);
        CGContextAddLineToPoint(context, w * (i) - LINE_WIDTH / 2, height);
        CGContextStrokePath(context);
    }
}





@end
