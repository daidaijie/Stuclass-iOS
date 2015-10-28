//
//  HomeworkPostTableViewController.h
//  stuclass
//
//  Created by JunhaoWang on 10/24/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Homework;

@class DetailViewController;

@protocol HomeworkPostTableViewControllerDelegate <NSObject>

- (void)homeworkPostTableViewControllerPostSuccessfullyWithHomework:(Homework *)homework;

@end

@interface HomeworkPostTableViewController : UITableViewController

@property (weak, nonatomic) DetailViewController *dvc;

@property (weak ,nonatomic) id<HomeworkPostTableViewControllerDelegate> delegate;

@end
