//
//  MessageCommentTableViewCell.h
//  stuclass
//
//  Created by JunhaoWang on 5/30/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCommentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
