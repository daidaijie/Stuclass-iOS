//
//  MessageDetailTableViewController.h
//  stuclass
//
//  Created by JunhaoWang on 5/29/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Message;

@interface MessageDetailTableViewController : UITableViewController

@property (strong, nonatomic) Message *message;

@end
