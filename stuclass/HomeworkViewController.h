//
//  HomeworkViewController.h
//  stuclass
//
//  Created by JunhaoWang on 10/19/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface HomeworkViewController : UIViewController

@property (strong, nonatomic) UITableView *tableView;

@property (weak, nonatomic) DetailViewController *dvc;

- (void)getHomeworkData;

@end
