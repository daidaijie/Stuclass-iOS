//
//  HomeworkTableViewCell.m
//  stuclass
//
//  Created by JunhaoWang on 10/24/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "HomeworkTableViewCell.h"

@implementation HomeworkTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    [super awakeFromNib];
    
//    CGFloat width = [UIScreen mainScreen].bounds.size.width;
//    self.contentLabel.preferredMaxLayoutWidth = width - 36.0; // 36.0 is the margin
    
    // postView
    self.homeworkView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.homeworkView.layer.shouldRasterize = YES;
    self.homeworkView.layer.cornerRadius = 4.0;
    self.homeworkView.layer.shadowOpacity = 0.2;
    self.homeworkView.layer.shadowOffset = CGSizeMake(-0.1, 0.1);
    self.homeworkView.layer.shadowColor = [UIColor blackColor].CGColor;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
