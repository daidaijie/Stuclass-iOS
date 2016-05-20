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

- (void)setLike:(NSUInteger)likeNum commentNum:(NSUInteger)commentNum;

@end
