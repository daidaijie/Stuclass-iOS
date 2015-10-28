//
//  ClassCollectionViewCell.m
//  stuget
//
//  Created by JunhaoWang on 7/19/15.
//  Copyright (c) 2015 JunhaoWang. All rights reserved.
//

#import "ClassCollectionViewCell.h"
#import "UIView+BorderCategory.h"
#import "ClassButton.h"
#import "Define.h"

#define LINE_WIDTH 0.4

static const CGFloat kCellInset = 1.2;

@implementation ClassCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.btn = [[ClassButton alloc] initWithFrame:CGRectMake(kCellInset, kCellInset, frame.size.width-kCellInset*2, frame.size.height-kCellInset*2)];
        [self.btn addTarget:self action:@selector(btnPress) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.btn];
        
        self.exclusiveTouch = YES;
        self.btn.exclusiveTouch = YES;
    }
    
    return self;
}

- (void)setBtnDescription:(NSString *)str
{
    [self.btn setupBtnTitle:str];
}

- (void)setBtnColor:(UIColor *)color
{
    self.btn.backgroundColor = color;
}

// 重写
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    // 更新btn的frame
    self.btn.frame = CGRectMake(kCellInset, kCellInset, self.frame.size.width - kCellInset*2, self.frame.size.height -kCellInset*2);
}


- (void)btnPress
{
    [self.delegate classCollectionViewCellDidPressWithTag:self.tag];
}



@end
