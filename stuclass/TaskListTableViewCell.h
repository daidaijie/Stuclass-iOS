//
//  TaskListTableViewCell.h
//  stuclass
//
//  Created by JunhaoWang on 4/10/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MGSwipeTableCell/MGSwipeTableCell.h>

@interface TaskListTableViewCell : MGSwipeTableCell
@property (weak, nonatomic) IBOutlet UIView *levelView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end
