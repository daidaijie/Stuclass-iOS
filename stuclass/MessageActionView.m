//
//  MessageActionView.m
//  stuclass
//
//  Created by JunhaoWang on 5/15/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "MessageActionView.h"
#import "CatZanButton.h"

static CGFloat kNormalTextColor = 0.5;
static CGFloat kHighlightTextColor = 0.3;

@interface MessageActionView ()

@property (strong, nonatomic) CatZanButton *likeButton;
@property (strong, nonatomic) UIButton *commentButton;
@property (strong, nonatomic) UIButton *shareButton;

@end

@implementation MessageActionView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // self
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat button_width = width / 3.0;
    CGFloat button_height = self.frame.size.height;
    CGFloat button_font_size = 14.0;
    
    // likeButton
    _likeButton = [[CatZanButton alloc] initWithFrame:CGRectMake(0, 0, button_width, button_height)];
    
    [_likeButton setTitle:@" 喜欢[0]" forState:UIControlStateNormal];
    _likeButton.titleLabel.font = [UIFont systemFontOfSize:button_font_size];
    [_likeButton setTitleColor:[UIColor colorWithWhite:kNormalTextColor alpha:1.0] forState:UIControlStateNormal];
    [_likeButton setTitleColor:[UIColor colorWithWhite:kHighlightTextColor alpha:1.0] forState:UIControlStateHighlighted];
    _likeButton.adjustsImageWhenHighlighted = YES;
    [_likeButton addTarget:self action:@selector(buttonDidPress:) forControlEvents:UIControlEventTouchUpInside];
    _likeButton.tag = 1;
    [self addSubview:_likeButton];
    
    // commentButton
    _commentButton = [[UIButton alloc] initWithFrame:CGRectMake(button_width, 0, button_width, button_height)];
    [_commentButton setTitle:@" 评论[0]" forState:UIControlStateNormal];
    _commentButton.titleLabel.font = [UIFont systemFontOfSize:button_font_size];
    [_commentButton setTitleColor:[UIColor colorWithWhite:kNormalTextColor alpha:1.0] forState:UIControlStateNormal];
    [_commentButton setTitleColor:[UIColor colorWithWhite:kHighlightTextColor alpha:1.0] forState:UIControlStateHighlighted];
    [_commentButton setImage:[UIImage imageNamed:@"icon-comment"] forState:UIControlStateNormal];
    _commentButton.adjustsImageWhenHighlighted = YES;
    [_commentButton addTarget:self action:@selector(buttonDidPress:) forControlEvents:UIControlEventTouchUpInside];
    _commentButton.tag = 2;
    [self addSubview:_commentButton];
    
    // shareButton
    _shareButton = [[UIButton alloc] initWithFrame:CGRectMake(button_width * 2, 0, button_width, button_height)];
    [_shareButton setTitle:@" 分享" forState:UIControlStateNormal];
    _shareButton.titleLabel.font = [UIFont systemFontOfSize:button_font_size];
    [_shareButton setTitleColor:[UIColor colorWithWhite:kNormalTextColor alpha:1.0] forState:UIControlStateNormal];
    [_shareButton setTitleColor:[UIColor colorWithWhite:kHighlightTextColor alpha:1.0] forState:UIControlStateHighlighted];
    [_shareButton setImage:[UIImage imageNamed:@"icon-share"] forState:UIControlStateNormal];
    _shareButton.adjustsImageWhenHighlighted = YES;
    [_shareButton addTarget:self action:@selector(buttonDidPress:) forControlEvents:UIControlEventTouchUpInside];
    _shareButton.tag = 3;
    [self addSubview:_shareButton];
}


- (void)buttonDidPress:(UIButton *)btn
{
    [_delegate messageActionViewDelegateDidPressButtonType:btn.tag];
}

- (void)setLikeNum:(NSUInteger)likeNum status:(BOOL)isLike animation:(BOOL)animate
{
    [_likeButton setTitle:[NSString stringWithFormat:@" 喜欢[%d]", likeNum] forState:UIControlStateNormal];
    [_likeButton setWithStatus:isLike withAnimation:animate];
}

- (void)setCommentNum:(NSUInteger)commentNum available:(BOOL)available
{
    [_commentButton setTitle:[NSString stringWithFormat:@" 评论[%d]", commentNum] forState:UIControlStateNormal];
    _commentButton.userInteractionEnabled = available;
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGFloat line_width = 0.3;
    CGFloat button_width = self.frame.size.width / 3;
    CGFloat button_height = self.frame.size.height;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.804 alpha:1.000].CGColor);
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
