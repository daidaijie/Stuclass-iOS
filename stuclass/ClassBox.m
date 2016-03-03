//
//  ClassBox.m
//  stuclass
//
//  Created by JunhaoWang on 10/21/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "ClassBox.h"

@implementation ClassBox

- (ClassBox *)copyClassBox
{
    ClassBox *box = [[ClassBox alloc] init];
    
    box.box_id = _box_id;
    box.box_number = _box_number;
    box.box_name = _box_name;
    box.box_room = _box_room;
    box.box_span = _box_span;
    box.box_teacher = _box_teacher;
    box.box_credit = _box_credit;
    box.box_color = _box_color;
    box.box_x = _box_x;
    box.box_y = _box_y;
    box.box_length = _box_length;
    box.box_weekType = _box_weekType;
    
    return box;
}

@end
