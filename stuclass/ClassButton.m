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
        _highlightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _highlightView.backgroundColor = [UIColor blackColor];
        _highlightView.alpha = 0.3;
        _highlightView.layer.cornerRadius = kCornerRadius;
        _highlightView.hidden = YES;
        [self addSubview:_highlightView];
        
        // label
        _label = [[UILabel alloc] initWithFrame:CGRectMake(kInset, kInset, frame.size.width - kInset * 2, frame.size.height - kInset * 2)];
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont systemFontOfSize:9.5];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.numberOfLines = 0;
        _label.lineBreakMode = NSLineBreakByTruncatingTail;
        
        [self addSubview:_label];
    }
    
    return self;
}

- (void)setupNormalColor
{
    _highlightView.hidden = YES;
}

- (void)setupHighlightColor
{
    _highlightView.hidden = NO;
}

- (void)setupBtnTitle:(NSString *)string
{
    _label.text = string;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _highlightView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _label.frame = CGRectMake(kInset, kInset, frame.size.width - kInset * 2, frame.size.height - kInset * 2);
}

@end
