//
//  ClassSemesterTableViewController.h
//  stuclass
//
//  Created by JunhaoWang on 11/25/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ClassSemesterTableViewController;

@protocol ClassSemesterDelegate <NSObject>

- (void)semesterDelegateLogout;

- (void)semesterDelegateSemesterChanged:(NSArray *)boxData semester:(NSInteger)semester;

@end


@interface ClassSemesterTableViewController : UITableViewController

@property (weak, nonatomic) id<ClassSemesterDelegate> delegate;

@end
