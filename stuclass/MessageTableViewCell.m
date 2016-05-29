//
//  MessageTableViewCell.m
//  stuclass
//
//  Created by JunhaoWang on 5/16/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "MessageTableViewCell.h"
//#import "Define.h"

@interface MessageTableViewCell()<MessageActionViewDelegate>

@end

@implementation MessageTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    [super awakeFromNib];
    
    // avatarImageView
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.size.width / 2.0;
    self.avatarImageView.clipsToBounds = YES;
//    self.avatarImageView.layer.borderColor = MAIN_COLOR.CGColor;
//    self.avatarImageView.layer.borderWidth = 0.6;
    
    // actionView
    self.actionView.delegate = self;
}


- (void)setLikeNum:(NSUInteger)likeNum status:(BOOL)isLike animation:(BOOL)animate
{
    [self.actionView setLikeNum:likeNum status:isLike animation:animate];
}

- (void)setCommentNum:(NSUInteger)commentNum available:(BOOL)available;
{
    [self.actionView setCommentNum:commentNum available:(BOOL)available];
}


#pragma mark - MessageActionViewDelegate

- (void)messageActionViewDelegateDidPressButtonType:(NSUInteger)type
{
    if (type == 1) {
        // like
        [_delegate messageActionViewLikeDidPressWithTag:self.tag];
    } else if (type == 2) {
        // comment
        [_delegate messageActionViewCommentDidPressWithTag:self.tag];
    } else if (type == 3) {
        // share
        [_delegate messageActionViewShareDidPressWithTag:self.tag];
    }
}


// more
- (IBAction)moreButtonPress:(id)sender
{
    [_delegate messageActionViewMoreDidPressWithTag:self.tag];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
