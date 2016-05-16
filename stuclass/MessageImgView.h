//
//  MessageImgView.h
//  stuclass
//
//  Created by JunhaoWang on 5/15/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAPageControl.h"

@interface MessageImgView : UIView

@property (assign, nonatomic) NSUInteger numberOfImages;

@property (strong, nonatomic) UIImageView *imageView1;
@property (strong, nonatomic) UIImageView *imageView2;
@property (strong, nonatomic) UIImageView *imageView3;

@property (strong, nonatomic) TAPageControl *pageControl;
@property (strong, nonatomic) UIScrollView *scrollView;

@property (weak, nonatomic) UITableViewCell *cell;

//- (void)setContentImages:(NSArray *)contentImages;

@end
