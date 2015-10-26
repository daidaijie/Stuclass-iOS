//
//  DiscussTableViewCell.h
//  stuclass
//
//  Created by JunhaoWang on 10/24/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DiscussTableViewCellDelegate <NSObject>

- (void)discussTableViewCellDidLongPressOnCell:(UITableViewCell *)cell;

@end


@interface DiscussTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *discussView;

@property (weak, nonatomic) IBOutlet UILabel *publisherLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (assign, nonatomic) NSInteger discuss_id;

@property (weak, nonatomic) id<DiscussTableViewCellDelegate> delegate;

@end
