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

- (void)writeClassTableToCoreDataWithClassesArray:(NSArray *)data withYear:(NSInteger)year semester:(NSInteger)semester username:(NSString *)username;

- (NSArray *)getClassDataFromCoreDataWithYear:(NSInteger)year semester:(NSInteger)semester username:(NSString *)username;

- (void)deleteClassTableWithYear:(NSInteger)year semester:(NSInteger)semester;

@end
