//
//  ClassNoteTableViewCell.h
//  stuclass
//
//  Created by JunhaoWang on 10/19/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteLabel.h"

@interface ClassNoteTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet NoteLabel *noteLabel;

@end
