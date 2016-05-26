//
//  Message.h
//  stuclass
//
//  Created by JunhaoWang on 5/15/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Message : NSObject


// user
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *userid;
@property (strong, nonatomic) NSString *avatarURL;

// data
@property (strong, nonatomic) NSString *messageid;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSArray *imageURLs;
@property (strong, nonatomic) NSString *source;

// comment
@property (strong, nonatomic) NSArray *comments;

// like
@property (strong, nonatomic) NSArray *likes;

@end
