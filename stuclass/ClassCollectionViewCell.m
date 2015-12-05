//
//  ClassCollectionViewCell.m
//  stuget
//
//  Created by JunhaoWang on 7/19/15.
//  Copyright (c) 2015 JunhaoWang. All rights reserved.
//

#import "ClassCollectionViewCell.h"
#import "ClassButton.h"
#import "Define.h"


static const CGFloat kCellInset = 1.2;

static const CGFloat kInset = kCellInset + 1.0;

@implementation ClassCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        // btn
        _btn = [[ClassButton alloc] initWithFrame:CGRectMake(kCellInset, kCellInset, frame.size.width - kCellInset * 2, frame.size.height - kCellInset * 2)];
        [_btn addTarget:self action:@selector(btnPress) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_btn];
        
        self.exclusiveTouch = YES;
        _btn.exclusiveTouch = YES;
        
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

- (void)setBtnColor:(UIColor *)color
{
    _btn.backgroundColor = color;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _btn.frame = CGRectMake(kCellInset, kCellInset, self.frame.size.width - kCellInset * 2, self.frame.size.height - kCellInset * 2);
    _label.frame = CGRectMake(kInset, kInset, self.frame.size.width - kInset * 2, self.frame.size.height - kInset * 2);
}


- (void)btnPress
{
    [_delegate classCollectionViewCellDidPressWithTag:self.tag];
}



@end






