//
//  HeaderCollectionReusableView.h
//  stuclass
//
//  Created by JunhaoWang on 7/6/15.
//  Copyright (c) 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAPageControl.h"

@protocol BannerDelegate <NSObject>

- (void)bannerDidPressWithIndex:(NSUInteger)index;

@end

@interface HeaderCollectionReusableView : UICollectionReusableView

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) TAPageControl *pageControl;

@property (strong, nonatomic) NSMutableArray *imageViews;

@property (weak, nonatomic) id<BannerDelegate> delegate;

- (void)resetHeader;
- (void)activeHeader;

- (void)setImages:(NSArray *)banners;

@end
