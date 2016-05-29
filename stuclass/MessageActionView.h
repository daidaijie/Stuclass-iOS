//
//  MessageActionView.h
//  stuclass
//
//  Created by JunhaoWang on 5/15/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MessageActionViewDelegate <NSObject>

- (void)messageActionViewDelegateDidPressButtonType:(NSUInteger)type;

@end

@interface MessageActionView : UIView

@property (weak, nonatomic) id<MessageActionViewDelegate> delegate;

- (void)setLikeNum:(NSUInteger)likeNum status:(BOOL)isLike animation:(BOOL)animate;
- (void)setCommentNum:(NSUInteger)commentNum available:(BOOL)available;

@end
