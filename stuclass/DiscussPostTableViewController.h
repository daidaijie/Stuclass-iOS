//
//  DiscussPostTableViewController.h
//  stuclass
//
//  Created by JunhaoWang on 10/25/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Discuss;

@class DetailViewController;

@protocol DiscussPostTableViewControllerDelegate <NSObject>

- (void)discussPostTableViewControllerPostSuccessfullyWithDiscuss:(Discuss *)dicuss;

@end

@interface DiscussPostTableViewController : UITableViewController

@property (weak, nonatomic) DetailViewController *dvc;

@property (weak, nonatomic) id<DiscussPostTableViewControllerDelegate> delegate;

@end
