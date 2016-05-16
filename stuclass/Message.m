//
//  Message.m
//  stuclass
//
//  Created by JunhaoWang on 5/15/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "Message.h"

@implementation Message


- (instancetype)initWithNickname:(NSString *)nickname date:(NSString *)date content:(NSString *)content avatarImage:(UIImage *)avatarImage contentImages:(NSArray *)contentImages
{
    self = [super init];
    
    if (self) {
        _nickname = nickname;
        _date = date;
        _content = content;
        _avatarImage = avatarImage;
        _contentImages = contentImages;
    }
    
    return self;
}


@end
