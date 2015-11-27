//
//  ClassSemesterButton.m
//  stuclass
//
//  Created by JunhaoWang on 11/25/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "ClassSemesterButton.h"
#import "Define.h"

@interface ClassSemesterButton ()

@property (strong, nonatomic) UIView *highlightView;

@end



@implementation ClassSemesterButton


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        
        self.titleLabel.font = [UIFont systemFontOfSize:15.5];
        
        self.backgroundColor = MAIN_COLOR;
        
        self.titleLabel.numberOfLines = 0;
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(6.0, 6.0)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        self.layer.mask = maskLayer;
        
        self.adjustsImageWhenHighlighted = NO;
        
        [self addTarget:self action:@selector(setupNormalColor) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchDragOutside|UIControlEventTouchUpOutside|UIControlEventTouchDragExit];
        [self addTarget:self action:@selector(setupHighlightColor) forControlEvents:UIControlEventTouchDown];
        
        // highlightView
        _highlightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _highlightView.backgroundColor = [UIColor blackColor];
        _highlightView.alpha = 0.1;
        _highlightView.hidden = YES;
        [self addSubview:_highlightView];
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

@end
