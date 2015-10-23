//
//  ClassInfoTableViewCell.h
//  stuclass
//
//  Created by JunhaoWang on 10/19/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassInfoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end
