//
//  HeaderCollectionReusableView.m
//  stuget
//
//  Created by JunhaoWang on 7/6/15.
//  Copyright (c) 2015 JunhaoWang. All rights reserved.
//

#import "HeaderCollectionReusableView.h"
#import "Define.h"

static const NSTimeInterval kDuration = 4.0;


@interface HeaderCollectionReusableView () <UIScrollViewDelegate, UIAlertViewDelegate>
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
//        self.scrollView.layer.borderWidth = 0.3f;
//        self.scrollView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [self addSubview:self.scrollView];
        
        self.pageControl = [[TAPageControl alloc] initWithFrame:CGRectMake(0, 0, 50, 10)];
        self.pageControl.center = CGPointMake(self.scrollView.bounds.size.width/2, self.scrollView.bounds.size.height - 12.0f);
        self.pageControl.userInteractionEnabled = NO;
        self.pageControl.numberOfPages = 3;
        self.pageControl.currentPage = 0;
        
        _banner1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width * k)];
        _banner2 = [[UIImageView alloc] initWithFrame:CGRectMake(width, 0, width, width * k)];
        _banner3 = [[UIImageView alloc] initWithFrame:CGRectMake(width * 2, 0, width, width * k)];
        
        _banner1.contentMode = _banner2.contentMode = _banner3.contentMode = UIViewContentModeScaleAspectFill;
        
        _banner1.clipsToBounds = _banner2.clipsToBounds = _banner3.clipsToBounds = YES;
        
        [self.scrollView addSubview:_banner1];
        [self.scrollView addSubview:_banner2];
        [self.scrollView addSubview:_banner3];
        [self addSubview:self.pageControl];
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 3, self.scrollView.frame.size.height);
        
        // Banner播放计时器
        self.timer = [NSTimer scheduledTimerWithTimeInterval:4.5 target:self selector:@selector(nextBanner) userInfo:nil repeats:YES];
        
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


- (void)nextBanner
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    if (_pageControl.currentPage == 0) {
        [self.scrollView setContentOffset:CGPointMake(width, 0) animated:YES];
        self.pageControl.currentPage = 1;
    } else if (_pageControl.currentPage == 1) {
        [self.scrollView setContentOffset:CGPointMake(width * 2, 0) animated:YES];
        self.pageControl.currentPage = 2;
    } else if (_pageControl.currentPage == 2) {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        self.pageControl.currentPage = 0;
    }
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
    if (_pageControl.currentPage == 0) {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else if (_pageControl.currentPage == 1) {
        [self.scrollView setContentOffset:CGPointMake(width, 0) animated:YES];
    } else if (_pageControl.currentPage == 2) {
        [self.scrollView setContentOffset:CGPointMake(width * 2, 0) animated:YES];
    }
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
    
    if (index == 0) {
        if (_link1.length > 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"了解更多" message:_link1 delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"访问", nil];
            alertView.tag = 1;
            [alertView show];
        }
    } else if (index == 1) {
        if (_link2.length > 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"了解更多" message:_link2 delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"访问", nil];
            alertView.tag = 2;
            [alertView show];
        }
    } else if (index == 2) {
        if (_link3.length > 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"了解更多" message:_link3 delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"访问", nil];
            alertView.tag = 3;
            [alertView show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger tag = alertView.tag;
    
    if (buttonIndex == 1) {
    
        if (tag == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_link1]];
        } else if (tag == 2) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_link2]];
        } else if (tag == 3) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_link3]];
        }
    }
}



@end



