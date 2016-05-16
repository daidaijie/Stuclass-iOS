//
//  TestingModel.h
//  stuclass
//
//  Created by JunhaoWang on 5/15/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestingModel : NSObject

@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSArray *contentImages;
@property (strong, nonatomic) UIImage *avatarImage;

- (instancetype)initWithNickname:(NSString *)nickname date:(NSString *)date content:(NSString *)content avatarImage:(UIImage *)avatarImage contentImages:(NSArray *)contentImages;

@end
