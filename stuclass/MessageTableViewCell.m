//
//  MessageTableViewCell.m
//  stuclass
//
//  Created by JunhaoWang on 5/16/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "MessageTableViewCell.h"

@interface MessageTableViewCell()<MessageActionViewDelegate>

@end

@implementation MessageTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    [super awakeFromNib];
    
    // avatarImageView
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.size.width / 2.0;
    self.avatarImageView.clipsToBounds = YES;
    //    self.avatarImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    //    self.avatarImageView.layer.borderWidth = 0.3;
    
    // actionView
    self.actionView.delegate = self;
}

- (void)setLike:(NSUInteger)likeNum commentNum:(NSUInteger)commentNum
{
    [self.actionView setLike:likeNum commentNum:commentNum];
}


#pragma mark - MessageActionViewDelegate

- (void)messageActionViewDelegateDidPressButtonType:(NSUInteger)type
{
    if (type == 1) {
        // like
    } else if (type == 2) {
        // comment
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
