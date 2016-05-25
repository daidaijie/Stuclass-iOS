//
//  HeaderCollectionReusableView.m
//  stuclass
//
//  Created by JunhaoWang on 7/6/15.
//  Copyright (c) 2015 JunhaoWang. All rights reserved.
//

#import "HeaderCollectionReusableView.h"
#import "Define.h"
#import "UIImageView+WebCache.h"

static const NSTimeInterval kDuration = 5.0;


@interface HeaderCollectionReusableView () <UIScrollViewDelegate>
@property (strong, nonatomic) NSTimer *timer;
@end


@implementation HeaderCollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        
        CGFloat k = 9.0 / 16;
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, width * k)];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.delegate = self;
        self.scrollView.bounces = NO;
        self.scrollView.scrollsToTop = NO;
        self.scrollView.directionalLockEnabled = YES;
        [self addSubview:self.scrollView];
        
        self.pageControl = [[TAPageControl alloc] initWithFrame:CGRectMake(0, 0, 50, 10)];
        self.pageControl.center = CGPointMake(self.scrollView.bounds.size.width / 2, self.scrollView.bounds.size.height - 12.0f);
        self.pageControl.userInteractionEnabled = NO;
        [self addSubview:self.pageControl];
        
        // Gesture
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openLink)];
        [self addGestureRecognizer:tap];
        
        // line
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, width * k, width, 0.5)];
        bottomLine.backgroundColor = [UIColor colorWithWhite:0.843 alpha:1.000];
        [self addSubview:bottomLine];
    }
    
    return self;
}

- (void)setImages:(NSArray *)banners
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat k = 9.0 / 16;
    
    // pageControl
    NSUInteger number = banners.count;
    self.pageControl.numberOfPages = number;
    self.pageControl.currentPage = 0;
    
    // scrollView
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * number, self.scrollView.frame.size.height);
    
    // imageViews
    _imageViews = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < number; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(width * i, 0, width, width * k)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        
        // setImage
        NSDictionary *dict = banners[i];
        NSString *urlStr = dict[@"url"];
        UIImage *placeholder = [UIImage imageNamed:[NSString stringWithFormat:@"banner%d.jpg", (i % 3) + 1]];
        if ([urlStr isEqualToString:@""] || !urlStr) {
            imageView.image = placeholder;
        } else {
            [imageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:placeholder completed:nil];
        }
        
        // add
        [_imageViews addObject:imageView];
        [self.scrollView addSubview:imageView];
    }
}


- (void)nextBanner
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    if (_imageViews.count == _pageControl.currentPage + 1) {
        self.pageControl.currentPage = 0;
    } else {
        self.pageControl.currentPage++;
    }
    [self.scrollView setContentOffset:CGPointMake(width * self.pageControl.currentPage, 0) animated:YES];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index = fabs(scrollView.contentOffset.x) / scrollView.frame.size.width;
//    NSLog(@"Get Banner - %d", index);
    self.pageControl.currentPage = index;
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kDuration target:self selector:@selector(nextBanner) userInfo:nil repeats:YES];
}


- (void)resetHeader
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    [self.scrollView setContentOffset:CGPointMake(width * _pageControl.currentPage, 0) animated:YES];
    [self.timer invalidate];
}

- (void)activeHeader
{
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kDuration target:self selector:@selector(nextBanner) userInfo:nil repeats:YES];
}

- (void)openLink
{
    NSInteger index = _pageControl.currentPage;
    
    [_delegate bannerDidPressWithIndex:index];
}



@end



