//
//  MessageTableViewCell.h
//  stuclass
//
//  Created by JunhaoWang on 10/24/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageImgView.h"
#import "ScrollManager.h"
#import "MessageActionView.h"

//@protocol MessageTableViewCellDelegate <NSObject>

//- (void)messageTableViewCellDidScroll:(UITableViewCell *)cell;

//@end


@interface MessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet MessageImgView *messageImgView;
@property (weak, nonatomic) IBOutlet MessageActionView *actionView;

@property (assign, nonatomic) NSUInteger currentPage;

@property (strong, nonatomic) ScrollManager *manager;

//@property (weak, nonatomic) id<MessageTableViewCellDelegate> delegate;

- (void)setPage:(int)page;

- (void)setContentImagesWithImageURLs:(NSArray *)imageURLs;

- (void)setLike:(NSUInteger)likeNum commentNum:(NSUInteger)commentNum;

@end
