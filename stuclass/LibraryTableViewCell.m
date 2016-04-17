//
//  LibraryTableViewCell.m
//  stuclass
//
//  Created by JunhaoWang on 7/24/15.
//  Copyright (c) 2015 JunhaoWang. All rights reserved.
//

#import "LibraryTableViewCell.h"
#import "Define.h"

#define RGB(r, g, b) [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0]

@interface LibraryTableViewCell ()

@end

@implementation LibraryTableViewCell


- (void)awakeFromNib
{
    [super awakeFromNib];
}


- (UIEdgeInsets)layoutMargins
{
    return UIEdgeInsetsZero;
}


- (void)setAvailableLabelColor:(NSInteger)availableNum
{
    if (availableNum == 0) {
        self.availableLabel.backgroundColor = MAIN_COLOR;
    } else {
        self.availableLabel.backgroundColor = [UIColor colorWithRed:0.333 green:0.596 blue:0.263 alpha:1.000];
    }
}


@end
