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
    
    _documentView.layer.cornerRadius = 4.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
