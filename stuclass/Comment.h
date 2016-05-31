//
//  Comment.h
//  stuclass
//
//  Created by JunhaoWang on 5/30/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject

@property (strong, nonatomic) NSString *post_id;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *user_id;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *comment_id;
@property (strong, nonatomic) NSString *content;

@end
