//
//  BarView.h
//  stuclass
//
//  Created by JunhaoWang on 10/18/15.
//  Copyright (c) 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarView : UIView

@property (strong, nonatomic) UIButton *firstButton;

@property (strong, nonatomic) UIButton *secondButton;

@property (strong, nonatomic) UIButton *thirdButton;


- (void)gotoIndex:(NSInteger)index;


@end
