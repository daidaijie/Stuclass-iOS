//
//  GradeTableViewCell.m
//  stuclass
//
//  Created by JunhaoWang on 11/22/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "GradeTableViewCell.h"

@implementation GradeTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (UIEdgeInsets)layoutMargins
{
    return UIEdgeInsetsMake(0, 15, 0, 0);
}

@end
