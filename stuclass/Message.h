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

// comment
@property (strong, nonatomic) NSArray *comments;

// like
@property (strong, nonatomic) NSArray *likes;


// testing
@property (strong, nonatomic) NSArray *contentImages;
@property (strong, nonatomic) UIImage *avatarImage;

- (instancetype)initWithNickname:(NSString *)nickname date:(NSString *)date content:(NSString *)content avatarImage:(UIImage *)avatarImage contentImages:(NSArray *)contentImages;

@end
