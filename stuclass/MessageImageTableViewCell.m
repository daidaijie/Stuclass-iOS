//
//  MessageTableViewCell.m
//  stuclass
//
//  Created by JunhaoWang on 10/24/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "MessageImageTableViewCell.h"
#import "Define.h"
#import "UIImageView+WebCache.h"

@interface MessageImageTableViewCell () <UIScrollViewDelegate, MessageImgViewDelegate>

@end

@implementation MessageImageTableViewCell

@dynamic delegate;

- (void)awakeFromNib {
    // Initialization code
    
    [super awakeFromNib];
    
    // ScrollManager
    _manager = [ScrollManager sharedManager];
    
    // messageImgView
    self.messageImgView.clipsToBounds = YES;
    self.messageImgView.delegate = self;
}


- (void)setPage:(int)page
{
    CGFloat pageWidth = [UIScreen mainScreen].bounds.size.width;
    float offset_X = pageWidth * page;
    [_messageImgView.scrollView setContentOffset:CGPointMake(offset_X, _messageImgView.scrollView.contentOffset.y)];
    _currentPage = page;
    _messageImgView.pageControl.currentPage = page;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int page = fabs(scrollView.contentOffset.x) / [UIScreen mainScreen].bounds.size.width;
    _currentPage = page;
    _messageImgView.pageControl.currentPage = page;
    if (_managerType == 0) {
        [_manager setpage:_currentPage ForKey:[NSString stringWithFormat:@"%i",self.tag]];
    } else {
        [_manager setMYpage:_currentPage ForKey:[NSString stringWithFormat:@"%i",self.tag]];

    }
}


- (void)setContentImagesWithImageURLs:(NSArray *)imageURLs
{
    UIImage *placeholder = [UIImage imageNamed:@"image-placeholder"];
    
    _messageImgView.scrollView.delegate = self;
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = width * 0.618;
    
    if (imageURLs == nil || imageURLs.count == 0) {
        // nope
        _messageImgView.pageControl.numberOfPages = 0;
        _messageImgView.imageView1.image = nil;
        _messageImgView.imageView2.image = nil;
        _messageImgView.imageView3.image = nil;
        
        _messageImgView.scrollView.contentSize = CGSizeMake(width, height);
        
    } else if (imageURLs.count == 1) {
        // 1 image
        NSURL *url1 = [NSURL URLWithString:imageURLs[0]];
        [_messageImgView.imageView1 sd_setImageWithURL:url1 placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        _messageImgView.imageView2.image = nil;
        _messageImgView.imageView3.image = nil;
        _messageImgView.pageControl.numberOfPages = 1;
        
        _messageImgView.scrollView.contentSize = CGSizeMake(width, height);
        
    } else if (imageURLs.count == 2) {
        // 2 images
        NSURL *url1 = [NSURL URLWithString:imageURLs[0]];
        [_messageImgView.imageView1 sd_setImageWithURL:url1 placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        NSURL *url2 = [NSURL URLWithString:imageURLs[1]];
        [_messageImgView.imageView2 sd_setImageWithURL:url2 placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        _messageImgView.imageView3.image = nil;
        _messageImgView.pageControl.numberOfPages = 2;
        
        _messageImgView.scrollView.contentSize = CGSizeMake(width * 2, height);
        
    } else if (imageURLs.count == 3) {
        // 3 images
        NSURL *url1 = [NSURL URLWithString:imageURLs[0]];
        [_messageImgView.imageView1 sd_setImageWithURL:url1 placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        NSURL *url2 = [NSURL URLWithString:imageURLs[1]];
        [_messageImgView.imageView2 sd_setImageWithURL:url2 placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        NSURL *url3 = [NSURL URLWithString:imageURLs[2]];
        [_messageImgView.imageView3 sd_setImageWithURL:url3 placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        
        _messageImgView.pageControl.numberOfPages = 3;
        
        _messageImgView.scrollView.contentSize = CGSizeMake(width * 3, height);
    }
}


#pragma mark - MessageImgViewDelegate

- (void)messageImgViewBgGestureDidPress
{
    NSUInteger index;
    if (_managerType == 0) {
        index = [_manager getpageForKey:[NSString stringWithFormat:@"%i", self.tag]];
    } else {
        index = [_manager getMYpageForKey:[NSString stringWithFormat:@"%i", self.tag]];
    }
    [self.delegate messageImgViewBgGestureDidPressWithTag:self.tag Index:index];
}

@end






