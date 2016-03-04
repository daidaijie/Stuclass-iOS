//
//  HeaderCollectionReusableView.h
//  stuget
//
//  Created by JunhaoWang on 7/6/15.
//  Copyright (c) 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAPageControl.h"

@interface HeaderCollectionReusableView : UICollectionReusableView

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) TAPageControl *pageControl;

@property (strong, nonatomic) UIImageView *banner1;
@property (strong, nonatomic) UIImageView *banner2;
@property (strong, nonatomic) UIImageView *banner3;

@property (strong, nonatomic) NSString *link1;
@property (strong, nonatomic) NSString *link2;
@property (strong, nonatomic) NSString *link3;

- (void)resetHeader;
- (void)activeHeader;

@end
