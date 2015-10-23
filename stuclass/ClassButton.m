//
//  ClassButton.m
//  stuclass
//
//  Created by JunhaoWang on 10/11/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "ClassButton.h"

static const CGFloat kInset = 1.0;
static const CGFloat kCornerRadius = 2.0;
static const CGFloat kAlpha = 0.9;

@interface ClassButton ()

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIView *highlightView;

@end


@implementation ClassButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.layer.cornerRadius = kCornerRadius;
        self.backgroundColor = [UIColor orangeColor];
        self.alpha = kAlpha;
        
        [self addTarget:self action:@selector(setupNormalColor) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchDragOutside|UIControlEventTouchUpOutside|UIControlEventTouchDragExit];
        [self addTarget:self action:@selector(setupHighlightColor) forControlEvents:UIControlEventTouchDown];
        
        // highlightView
        self.highlightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.highlightView.backgroundColor = [UIColor blackColor];
        self.highlightView.alpha = 0.3;
        self.highlightView.layer.cornerRadius = kCornerRadius;
        self.highlightView.hidden = YES;
        [self addSubview:self.highlightView];
        
        // label
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(kInset, kInset, frame.size.width - kInset * 2, frame.size.height - kInset * 2)];
        self.label.textColor = [UIColor whiteColor];
        self.label.font = [UIFont systemFontOfSize:9.5];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.numberOfLines = 0;
        self.label.lineBreakMode = NSLineBreakByTruncatingTail;
        
        [self addSubview:self.label];
    }
    
    return self;
}

- (void)setupNormalColor
{
    self.highlightView.hidden = YES;
}

- (void)setupHighlightColor
{
    self.highlightView.hidden = NO;
}

- (void)setupBtnTitle:(NSString *)string
{
    self.label.text = string;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.highlightView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.label.frame = CGRectMake(kInset, kInset, frame.size.width - kInset * 2, frame.size.height - kInset * 2);
}

@end
