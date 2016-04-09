//
//  LibraryFooterView.m
//  stuclass
//
//  Created by JunhaoWang on 7/24/15.
//  Copyright (c) 2015 JunhaoWang. All rights reserved.
//

#import "LibraryFooterView.h"

@interface LibraryFooterView ()

@property (strong, nonatomic) UIActivityIndicatorView *aiv;
@property (strong, nonatomic) UILabel *loadingLabel;

@end

#define LINE_WIDTH 0.4

@implementation LibraryFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _aiv.center = CGPointMake(frame.size.width/2 - 42, frame.size.height/2);
        _aiv.hidesWhenStopped = YES;
        [self addSubview:_aiv];
        
        _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        _loadingLabel.center = CGPointMake(frame.size.width/2 + 23, frame.size.height/2);
        _loadingLabel.text = @"正在加载...";
        _loadingLabel.hidden = YES;
        _loadingLabel.font = [UIFont systemFontOfSize:17.0];
        [self addSubview:_loadingLabel];
    }
    
    return self;
}


- (void)showLoading
{
    _loadingLabel.hidden = NO;
    [_aiv startAnimating];
}


- (void)hideLoading
{
    _loadingLabel.hidden = YES;
    [_aiv stopAnimating];
}


- (void)showEnd
{
    [_aiv stopAnimating];
    _loadingLabel.hidden = YES;
    self.frame = CGRectMake(0, 0, 320, 1.4f);
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, LINE_WIDTH);
    
    CGContextMoveToPoint(context, 8.0, 0);
    CGContextAddLineToPoint(context, self.bounds.size.width, 0);
    CGContextStrokePath(context);
}



@end
