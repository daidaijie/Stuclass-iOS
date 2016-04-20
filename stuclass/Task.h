//
//  Task.h
//  stuclass
//
//  Created by JunhaoWang on 4/11/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Task : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSNumber *level;

- (instancetype)initWithTitle:(NSString *)title level:(NSNumber *)level;

@end
