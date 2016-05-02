//
//  CoreDataManager.h
//  stuclass
//
//  Created by JunhaoWang on 10/21/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataManager : NSObject


+ (instancetype)sharedInstance;


#pragma mark - Class

- (BOOL)isClassTableExistedWithYear:(NSInteger)year semester:(NSInteger)semester username:(NSString *)username;

- (void)writeSyncClassTableToCoreDataWithClassesArray:(NSArray *)data withYear:(NSInteger)year semester:(NSInteger)semester username:(NSString *)username;

- (void)writeOneClassToCoreDataWithClassName:(NSString *)name classID:(NSString *)classID week:(NSUInteger)week start:(NSUInteger)start span:(NSUInteger)span startWeek:(NSUInteger)startWeek endWeek:(NSUInteger)endWeek weekType:(NSString *)weekType withYear:(NSUInteger)year semester:(NSUInteger)semester username:(NSString *)username;

- (NSArray *)getClassDataFromCoreDataWithYear:(NSInteger)year semester:(NSInteger)semester username:(NSString *)username;

- (void)deleteClassTableWithYear:(NSInteger)year semester:(NSInteger)semester;


#pragma mark - Note
- (void)writeNoteToCoreDataWithContent:(NSString *)content time:(NSString *)time classID:(NSString *)class_id username:(NSString *)username;

- (NSDictionary *)getNoteFromCoreDataWithClassID:(NSString *)class_id username:(NSString *)username;


@end
