//
//  BookResultTableViewController.h
//  stuget
//
//  Created by JunhaoWang on 7/23/15.
//  Copyright (c) 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookResultTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *bookData;
@property (nonatomic) NSUInteger resultNum;
@property (copy, nonatomic) NSString *anywords;

- (void)setBookData:(NSMutableArray *)bookData resultNum:(NSUInteger)resultNum;

@end
