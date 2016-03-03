//
//  ClassBox.h
//  stuclass
//
//  Created by JunhaoWang on 10/21/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassBox : NSObject

@property (strong, nonatomic) NSString *box_id;
@property (strong, nonatomic) NSString *box_number;
@property (strong, nonatomic) NSString *box_name;
@property (strong, nonatomic) NSString *box_room;
@property (strong, nonatomic) NSArray *box_span;
@property (strong, nonatomic) NSString *box_teacher;
@property (strong, nonatomic) NSString *box_credit;
@property (strong, nonatomic) UIColor *box_color;
@property (assign, nonatomic) NSInteger box_x;
@property (assign, nonatomic) NSInteger box_y;
@property (assign, nonatomic) NSInteger box_length;
@property (strong, nonatomic) NSString *box_weekType;

- (ClassBox *)copyClassBox;

@end
