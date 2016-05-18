//
//  Document.h
//  stuclass
//
//  Created by JunhaoWang on 11/27/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Document : NSObject

@property (strong, nonatomic) NSString *department;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *date;

@end
