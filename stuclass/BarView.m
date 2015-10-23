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
    self.indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - kIndicatorViewHeight, buttonWidth, kIndicatorViewHeight)];
    self.indicatorView.backgroundColor = MAIN_COLOR;
    [self addSubview:self.indicatorView];
    
    // button
    self.firstButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, frame.size.height - kIndicatorViewHeight)];
    self.firstButton.tag = 0;
    self.firstButton.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
    [self.firstButton setTitle:@"个人" forState:UIControlStateNormal];
    [self.firstButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    [self addSubview:self.firstButton];
    
    self.secondButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth, 0, buttonWidth, frame.size.height - kIndicatorViewHeight)];
    self.secondButton.tag = 1;
    self.secondButton.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
    [self.secondButton setTitle:@"作业" forState:UIControlStateNormal];
        [self.secondButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    [self addSubview:self.secondButton];
    
    self.thirdButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth * 2, 0, buttonWidth, frame.size.height - kIndicatorViewHeight)];
    self.thirdButton.tag = 2;
    self.thirdButton.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
    [self.thirdButton setTitle:@"吹水" forState:UIControlStateNormal];
        [self.thirdButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    [self addSubview:self.thirdButton];
}



- (void)gotoIndex:(NSInteger)index
{
    [UIView beginAnimations:@"Animation" context:nil];
    [UIView setAnimationDuration:kAnimationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    CGRect f = self.indicatorView.frame;
    f.origin.x = f.size.width * index;
    self.indicatorView.frame = f;
    [UIView commitAnimations];
}


@end
