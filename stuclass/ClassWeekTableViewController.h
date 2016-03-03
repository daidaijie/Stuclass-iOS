//
//  ClassWeekTableViewController.h
//  stuclass
//
//  Created by JunhaoWang on 3/2/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ClassWeekTableViewController;

@protocol ClassWeekDelegate <NSObject>

- (void)weekDelegateWeekChanged:(NSInteger)week;

@end


@interface ClassWeekTableViewController : UITableViewController

@property (weak, nonatomic) id<ClassWeekDelegate> delegate;

@end

