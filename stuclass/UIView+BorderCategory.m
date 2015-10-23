//
//  UIView+BorderCategory.m
//  stuget
//
//  Created by JunhaoWang on 7/19/15.
//  Copyright (c) 2015 JunhaoWang. All rights reserved.
//

#import "UIView+BorderCategory.h"

@implementation UIView (BorderCategory)



- (void)setBorderWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left
{
    CALayer *layer = self.layer;
    
    if ((top == right == bottom == left) && top > 0) {
        CALayer *border = [CALayer layer];
        border.borderWidth = top;
        [border setBorderColor:self.layer.borderColor];
        [layer addSublayer:border];
        return;
    }
    
    if (top > 0) {
        CALayer *topBorder = [CALayer layer];
        topBorder.borderWidth = top;
        topBorder.frame = CGRectMake(0, 0, layer.frame.size.width, top);
        [topBorder setBorderColor:self.layer.borderColor];
        [layer addSublayer:topBorder];
    }
    
    if (right > 0) {
        CALayer *rightBorder = [CALayer layer];
        rightBorder.borderWidth = right;
        rightBorder.frame = CGRectMake(layer.frame.size.width-right, 0, right, layer.frame.size.height);
        [rightBorder setBorderColor:self.layer.borderColor];
        [layer addSublayer:rightBorder];
    }
    
    if (bottom > 0) {
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.borderWidth = bottom;
        bottomBorder.frame = CGRectMake(0, layer.frame.size.height-bottom, layer.frame.size.width, bottom);
        [bottomBorder setBorderColor:self.layer.borderColor];
        [layer addSublayer:bottomBorder];
    }
    
    if (left > 0) {
        CALayer *leftBorder = [CALayer layer];
        leftBorder.borderWidth = left;
        leftBorder.frame = CGRectMake(0, 0, left, layer.frame.size.height);
        [leftBorder setBorderColor:self.layer.borderColor];
        [layer addSublayer:leftBorder];
    }
}




@end
