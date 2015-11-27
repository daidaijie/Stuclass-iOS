//
//  DocumentTableViewCell.h
//  stuclass
//
//  Created by JunhaoWang on 11/27/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DocumentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *documentView;

@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
