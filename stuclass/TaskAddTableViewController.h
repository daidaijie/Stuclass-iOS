//
//  TaskAddTableViewController.h
//  stuclass
//
//  Created by JunhaoWang on 4/11/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TaskAddDelegate <NSObject>

- (void)taskDidAddWithTitle:(NSString *)title;

@end

@interface TaskAddTableViewController : UITableViewController

@property (weak, nonatomic) id<TaskAddDelegate> delegate;

@end
