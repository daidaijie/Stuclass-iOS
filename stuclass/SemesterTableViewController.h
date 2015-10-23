//
//  SemesterTableViewController.h
//  stuclass
//
//  Created by JunhaoWang on 10/12/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SemesterDelegate <NSObject>

- (void)semesterTableViewControllerDidSelectYear:(NSInteger)year semester:(NSInteger)semester;

@end

@interface SemesterTableViewController : UITableViewController

@property (weak, nonatomic) id<SemesterDelegate> semesterDelegate;

- (void)setupSelectedYear:(NSInteger)year semester:(NSInteger)semester;

@end
