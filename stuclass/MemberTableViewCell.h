//
//  MemberTableViewCell.h
//  stuclass
//
//  Created by JunhaoWang on 4/6/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemberTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *majorLabel;

@property (weak, nonatomic) IBOutlet UIImageView *genderImageView;

@end
