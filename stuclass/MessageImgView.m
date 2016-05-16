//
//  MessageImgView.m
//  stuclass
//
//  Created by JunhaoWang on 5/15/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "MessageImgView.h"

@interface MessageImgView()
@end

@implementation MessageImgView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = 200;
    
    _numberOfImages = 3;
    
    // scrollView
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    _scrollView.scrollsToTop = NO;
    _scrollView.showsVerticalScrollIndicator = self.scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.bounces = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.directionalLockEnabled = YES;
    
    _scrollView.contentSize = CGSizeMake(width * 3, height);
    
    [self addSubview:_scrollView];
    
    _imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    _imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(width, 0, width, height)];
    _imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(width * 2, 0, width, height)];
    
    _imageView1.contentMode = _imageView2.contentMode = _imageView3.contentMode = UIViewContentModeScaleAspectFill;
    
    _imageView1.clipsToBounds = _imageView2.clipsToBounds = _imageView3.clipsToBounds = YES;
    
    [_scrollView addSubview:_imageView1];
    [_scrollView addSubview:_imageView2];
    [_scrollView addSubview:_imageView3];
    
    _pageControl = [[TAPageControl alloc] initWithFrame:CGRectMake(width - 55, height - 18, 50, 10)];
    _pageControl.userInteractionEnabled = NO;
    _pageControl.numberOfPages = 3;
    _pageControl.currentPage = 0;
    _pageControl.hidesForSinglePage = YES;
    
    _pageControl.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    _pageControl.layer.shouldRasterize = YES;
    _pageControl.layer.shadowOpacity = 0.3;
    _pageControl.layer.shadowOffset = CGSizeMake(-0.15, 0.15);
    _pageControl.layer.shadowColor = [UIColor blackColor].CGColor;
    
    
    [self addSubview:_pageControl];
}

@end














