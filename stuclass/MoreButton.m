//
//  MoreButton.m
//  stuclass
//
//  Created by JunhaoWang on 11/22/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "MoreButton.h"
#import "Define.h"

@interface MoreButton ()

@property (strong, nonatomic) UIView *highlightView;

@end

@implementation MoreButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.layer.cornerRadius = 0.0;
        
        self.backgroundColor = MAIN_COLOR;
        
        self.titleLabel.font = [UIFont systemFontOfSize:16.0];
        
        
        
        
        
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













