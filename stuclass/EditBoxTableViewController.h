//
//  EditBoxTableViewController.h
//  stuclass
//
//  Created by JunhaoWang on 5/23/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClassBox.h"

@protocol ClassEditBoxDelegate <NSObject>

- (void)editBoxDelegateDidEdit:(ClassBox *)classBox boxData:(NSArray *)boxData;

@end

@interface EditBoxTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *boxData;

@property (strong, nonatomic) ClassBox *classBox;

@property (weak, nonatomic) id<ClassEditBoxDelegate> delegate;

@end

