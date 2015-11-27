//
//  DocumentTableViewCell.m
//  stuclass
//
//  Created by JunhaoWang on 11/27/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "DocumentTableViewCell.h"

@implementation DocumentTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
//    _documentView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
//    _documentView.layer.shouldRasterize = YES;
    _documentView.layer.cornerRadius = 4.0;
//    _documentView.layer.shadowOpacity = 0.25;
//    _documentView.layer.shadowOffset = CGSizeMake(-0.1, 0.1);
//    _documentView.layer.shadowColor = [UIColor grayColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
