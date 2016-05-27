//
//  ClassParser.h
//  stuclass
//
//  Created by JunhaoWang on 10/14/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassParser : NSObject


+ (instancetype)sharedInstance;

- (NSMutableArray *)parseClassData:(NSArray *)classData;

- (NSArray *)generateClassIDForOriginalData:(NSMutableArray *)originalData withYear:(NSInteger)year semester:(NSInteger)semester;

- (NSDictionary *)parseGradeData:(NSDictionary *)gradeData;

- (NSMutableArray *)parseExamData:(NSDictionary *)examData;

- (NSMutableArray *)parseDocumentData:(NSArray *)documentData;

- (NSMutableArray *)parseMessageData:(NSArray *)postList uid:(NSString *)my_uid;

@end
