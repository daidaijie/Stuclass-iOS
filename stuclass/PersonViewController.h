//
//  PersonViewController.h
//  stuclass
//
//  Created by JunhaoWang on 10/19/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ClassBox;

@interface PersonViewController : UIViewController

@property (strong, nonatomic) ClassBox *classBox;

- (void)setupBoxData:(ClassBox *)boxData;

@end


