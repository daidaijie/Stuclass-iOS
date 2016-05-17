//
//  MainTabBar.m
//  stuclass
//
//  Created by JunhaoWang on 5/17/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "MainTabBar.h"

@implementation MainTabBar


- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize sizeThatFits = [super sizeThatFits:size];
    sizeThatFits.height = 44;
    
    return sizeThatFits;
}


@end
