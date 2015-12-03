//
//  DiscussTableViewCell.m
//  stuclass
//
//  Created by JunhaoWang on 10/24/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "DiscussTableViewCell.h"

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


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
