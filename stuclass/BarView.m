//
//  BarView.m
//  stuclass
//
//  Created by JunhaoWang on 10/18/15.
//  Copyright (c) 2015 JunhaoWang. All rights reserved.
//

#import "BarView.h"
#import "Define.h"

static const CGFloat kButtonFontSize = 17.0;

static const CGFloat kIndicatorViewHeight = 4.5;

static const CGFloat kBottomLineViewHeight = 3.5;

static const NSTimeInterval kAnimationDuration = 0.3;

@interface BarView ()

@property (strong, nonatomic) UIView *indicatorView;

@end


@implementation BarView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setupBarWithFrame:frame];
    }
    
    return self;
}


- (void)setupBarWithFrame:(CGRect)frame;
{
    CGFloat buttonWidth = frame.size.width / 3;
    
    // bottomLine
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - kBottomLineViewHeight, frame.size.width, kBottomLineViewHeight)];
    bottomLineView.backgroundColor = BOTTOM_LINE_COLOR;
    [self addSubview:bottomLineView];
    
    // indicator
    _indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - kIndicatorViewHeight, buttonWidth, kIndicatorViewHeight)];
    _indicatorView.backgroundColor = MAIN_COLOR;
    [self addSubview:_indicatorView];
    
    // button
    _firstButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, frame.size.height - kIndicatorViewHeight)];
    _firstButton.tag = 0;
    _firstButton.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
    [_firstButton setTitle:@"个人" forState:UIControlStateNormal];
    [_firstButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    [self addSubview:_firstButton];
    
    _secondButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth, 0, buttonWidth, frame.size.height - kIndicatorViewHeight)];
    _secondButton.tag = 1;
    _secondButton.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
    [_secondButton setTitle:@"作业" forState:UIControlStateNormal];
        [_secondButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    [self addSubview:_secondButton];
    
    _thirdButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth * 2, 0, buttonWidth, frame.size.height - kIndicatorViewHeight)];
    _thirdButton.tag = 2;
    _thirdButton.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
    [_thirdButton setTitle:@"吹水" forState:UIControlStateNormal];
        [_thirdButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    [self addSubview:_thirdButton];
}



- (void)gotoIndex:(NSInteger)index
{
    [UIView beginAnimations:@"Animation" context:nil];
    [UIView setAnimationDuration:kAnimationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    CGRect f = _indicatorView.frame;
    f.origin.x = f.size.width * index;
    _indicatorView.frame = f;
    [UIView commitAnimations];
}


@end
