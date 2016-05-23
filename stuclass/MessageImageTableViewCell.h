//
//  MessageTableViewCell.h
//  stuclass
//
//  Created by JunhaoWang on 10/24/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "MessageImgView.h"
#import "ScrollManager.h"

@protocol MessageImageTableViewCellDelegate <NSObject, MessageTableViewCellDelegate>

@optional
- (void)messageImgViewBgGestureDidPressWithTag:(NSUInteger)tag Index:(NSUInteger)index;

@end

@interface MessageImageTableViewCell : MessageTableViewCell

@property (weak, nonatomic) IBOutlet MessageImgView *messageImgView;

@property (assign, nonatomic) NSUInteger currentPage;

@property (strong, nonatomic) ScrollManager *manager;

@property (weak, nonatomic) id <MessageImageTableViewCellDelegate> delegate;

- (void)setPage:(int)page;

- (void)setContentImagesWithImageURLs:(NSArray *)imageURLs;

@end
