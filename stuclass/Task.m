//
//  Task.m
//  stuclass
//
//  Created by JunhaoWang on 4/11/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "Task.h"

@implementation Task

- (instancetype)initWithTitle:(NSString *)title level:(NSNumber *)level
{
    self = [self init];
    
    self.title = title;
    self.level = level;
    
    return self;
}

@end
