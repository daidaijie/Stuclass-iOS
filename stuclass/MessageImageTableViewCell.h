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

@interface MessageImageTableViewCell : MessageTableViewCell

@property (weak, nonatomic) IBOutlet MessageImgView *messageImgView;

@property (assign, nonatomic) NSUInteger currentPage;

@property (strong, nonatomic) ScrollManager *manager;


- (void)setPage:(int)page;

- (void)setContentImagesWithImageURLs:(NSArray *)imageURLs;

@end
