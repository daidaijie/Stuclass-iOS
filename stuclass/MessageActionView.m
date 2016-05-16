//
//  MessageActionView.m
//  stuclass
//
//  Created by JunhaoWang on 5/15/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "MessageActionView.h"

@implementation MessageActionView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // self
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat button_width = width / 3.0;
    CGFloat button_height = self.frame.size.height;
    
    // likeButton
    UIButton *likeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, button_width, button_height)];
    [likeButton setTitle:@" 喜欢(10)" forState:UIControlStateNormal];
    likeButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [likeButton setTitleColor:[UIColor colorWithWhite:0.5 alpha:1.0] forState:UIControlStateNormal];
    [likeButton setImage:[UIImage imageNamed:@"icon-like"] forState:UIControlStateNormal];
    likeButton.adjustsImageWhenHighlighted = NO;
    [self addSubview:likeButton];
    
    // commentButton
    UIButton *commentButton = [[UIButton alloc] initWithFrame:CGRectMake(button_width, 0, button_width, button_height)];
    [commentButton setTitle:@" 评论(185)" forState:UIControlStateNormal];
    commentButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [commentButton setTitleColor:[UIColor colorWithWhite:0.5 alpha:1.0] forState:UIControlStateNormal];
    [commentButton setImage:[UIImage imageNamed:@"icon-comment"] forState:UIControlStateNormal];
    commentButton.adjustsImageWhenHighlighted = NO;
    [self addSubview:commentButton];
    
    // shareButton
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(button_width * 2, 0, button_width, button_height)];
    [shareButton setTitle:@" 分享" forState:UIControlStateNormal];
    shareButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [shareButton setTitleColor:[UIColor colorWithWhite:0.5 alpha:1.0] forState:UIControlStateNormal];
    [shareButton setImage:[UIImage imageNamed:@"icon-share"] forState:UIControlStateNormal];
    shareButton.adjustsImageWhenHighlighted = NO;
    [self addSubview:shareButton];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGFloat line_width = 0.3;
    CGFloat button_width = self.frame.size.width / 3;
    CGFloat button_height = self.frame.size.height;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.8022 green:0.8022 blue:0.8022 alpha:1.0].CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, line_width-0.1);
    
    // --
    CGContextMoveToPoint(context, 0, line_width/2);
    CGContextAddLineToPoint(context, self.bounds.size.width, line_width/2);
    CGContextStrokePath(context);
    
    // |
    CGContextSetLineWidth(context, line_width);
    
    CGContextMoveToPoint(context, button_width, 9);
    CGContextAddLineToPoint(context, button_width, button_height-9);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, button_width*2, 9);
    CGContextAddLineToPoint(context, button_width*2, button_height-9);
    CGContextStrokePath(context);
}


@end
