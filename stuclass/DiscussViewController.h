//
//  DiscussViewController.h
//  stuclass
//
//  Created by JunhaoWang on 10/19/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiscussViewController : UIViewController

@property (strong, nonatomic) UITableView *tableView;

- (void)getDiscussDataWithClassNumber:(NSString *)number;

@end
