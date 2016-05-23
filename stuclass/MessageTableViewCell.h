//
//  MessageTableViewCell.h
//  stuclass
//
//  Created by JunhaoWang on 5/16/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageActionView.h"

@protocol MessageTableViewCellDelegate <NSObject>

- (void)messageActionViewShareDidPressWithTag:(NSUInteger)tag;
- (void)messageActionViewMoreDidPressWithTag:(NSUInteger)tag;

@end

@interface MessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet MessageActionView *actionView;

@property (weak, nonatomic) id<MessageTableViewCellDelegate> delegate;

- (void)setLike:(NSUInteger)likeNum commentNum:(NSUInteger)commentNum;


@end
