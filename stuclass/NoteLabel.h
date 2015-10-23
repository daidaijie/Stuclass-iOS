//
//  NoteLabel.h
//  stuclass
//
//  Created by JunhaoWang on 10/23/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    VerticalAlignmentTop = 0, // default
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;


@interface NoteLabel : UILabel

@property (nonatomic) VerticalAlignment verticalAlignment;

@property (strong, nonatomic) UILabel *placeholder;

- (void)setVerticalAlignment:(VerticalAlignment)verticalAlignment;

@end
