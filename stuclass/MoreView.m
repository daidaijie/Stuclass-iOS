//
//  MoreView.m
//  stuclass
//
//  Created by JunhaoWang on 11/22/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "MoreView.h"
#import "MoreButton.h"

static const CGFloat kGap = 0.5;

static const CGFloat kGapOffset = 12.0;

static const CGFloat kButtonWidth = 134.0;

static const CGFloat kButtonHeight = 42.0;

@implementation MoreView

- (instancetype)initWithItems:(NSArray *)items images:(NSArray *)images
{
    self = [super initWithFrame:CGRectMake(0, 0, kButtonWidth, kButtonHeight * items.count + kGap * (items.count - 1))];
    
    if (self) {
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        
        for (NSInteger i = 0; i < items.count; i++) {
            
            MoreButton *btn = [[MoreButton alloc] initWithFrame:CGRectMake(0, (kGap + kButtonHeight) * i, kButtonWidth, kButtonHeight)];
            [btn setTitle:items[i] forState:UIControlStateNormal];
            [btn setImage:images[i] forState:UIControlStateNormal];
            
            // for 同步课表图标偏大
            if (i == 0) {
                btn.contentEdgeInsets = UIEdgeInsetsMake(0, 11, 0, 0);
                btn.titleEdgeInsets = UIEdgeInsetsMake(0, 9, 0, 0);
            }
            
            
            [self addSubview:btn];
            
            [tempArray addObject:btn];
            
            // lineView
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(kGapOffset, (i + 1) * kButtonHeight + i * kGap, kButtonWidth - kGapOffset * 2, kGap)];
            lineView.backgroundColor = [UIColor whiteColor];
            lineView.alpha = 0.5;
            [self addSubview:lineView];
        }
        
        _itemsArray = [NSArray arrayWithArray:tempArray];
        
    }
    
    return self;
}


@end















