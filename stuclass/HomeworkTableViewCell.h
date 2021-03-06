//
//  HomeworkTableViewCell.h
//  stuclass
//
//  Created by JunhaoWang on 10/24/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HomeworkTableViewCellDelegate <NSObject>

- (void)homeworkTableViewCellDidLongPressOnCell:(UITableViewCell *)cell;

@end


@interface HomeworkTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *homeworkView;

@property (weak, nonatomic) IBOutlet UILabel *publisherLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *deadlineLabel;


@property (assign, nonatomic) NSInteger homework_id;

@property (weak, nonatomic) id<HomeworkTableViewCellDelegate> delegate;

@end
