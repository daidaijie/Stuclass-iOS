//
//  Homework.h
//  stuclass
//
//  Created by JunhaoWang on 10/24/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Homework : NSObject

@property (strong, nonatomic) NSString *publisher;
@property (strong, nonatomic) NSString *nickname;
@property (assign, nonatomic) long long pub_time;
@property (strong, nonatomic) NSString *content;
@property (assign, nonatomic) NSInteger homework_id;
@property (strong, nonatomic) NSString *deadline;

@end
