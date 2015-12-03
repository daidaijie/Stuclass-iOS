//
//  DiscussTableViewCell.m
//  stuclass
//
//  Created by JunhaoWang on 10/24/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "DiscussTableViewCell.h"
#import "Define.h"

@interface DiscussTableViewCell ()

@property (strong, nonatomic) UIView *bottomLine;

@end

@implementation DiscussTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    [super awakeFromNib];
    
    //    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    //    _contentLabel.preferredMaxLayoutWidth = width - 36.0; // 36.0 is the margin
    
    // postView
//    _discussView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
//    _discussView.layer.shouldRasterize = YES;
//    _discussView.layer.cornerRadius = 4.0;
//    _discussView.layer.shadowOpacity = 0.25;
//    _discussView.layer.shadowOffset = CGSizeMake(-0.1, 0.1);
//    _discussView.layer.shadowColor = [UIColor grayColor].CGColor;
    
    // lineView
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat lineWidth = 0.5;
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, lineWidth)];
    topLine.backgroundColor = [UIColor colorWithWhite:0.843 alpha:1.000];
    [_discussView addSubview:topLine];
    
    _bottomLine = [[UIView alloc] init];
    _bottomLine.backgroundColor = [UIColor colorWithWhite:0.843 alpha:1.000];
    [_discussView addSubview:_bottomLine];
    
    // Gesture
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    gesture.minimumPressDuration = 0.4;
    
    [self addGestureRecognizer:gesture];
}


- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        [_delegate discussTableViewCellDidLongPressOnCell:self];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    _bottomLine.frame = CGRectMake(0, self.frame.size.height, width, 0.5);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end






