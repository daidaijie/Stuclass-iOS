//
//  AddBoxTableViewController.h
//  stuclass
//
//  Created by JunhaoWang on 5/1/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ClassAddBoxDelegate <NSObject>

- (void)addBoxDelegateDidAdd;

@end

@interface AddBoxTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *boxData;

@property (weak, nonatomic) id<ClassAddBoxDelegate> delegate;

@end

