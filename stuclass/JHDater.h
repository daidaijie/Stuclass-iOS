//
//  JHDater.h
//  stuget
//
//  Created by JunhaoWang on 7/15/15.
//  Copyright (c) 2015 JunhaoWang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JHDater : NSObject



// 返回具体时间
- (NSInteger)yearForDate:(NSDate *)date;
- (NSInteger)monthForDate:(NSDate *)date;
- (NSInteger)dayForDate:(NSDate *)date;
- (NSInteger)hourForDate:(NSDate *)date;
- (NSInteger)minuteForDate:(NSDate *)date;
- (NSInteger)secondForDate:(NSDate *)date;

// 返回格式化时间字符串
- (NSString *)dateStringForDate:(NSDate *)date withFormate:(NSString *)format;

// 返回排序后的时间
- (NSMutableArray *)sortDateWithArray:(NSArray *)array;

// 生成分类数组
- (NSMutableArray *)generateArray:(NSArray *)fromArray;

// 返回星期
- (NSInteger)weekForDate:(NSDate *)date;

// 返回day天后的日期
- (NSDate *)dateAfterDay:(NSUInteger)day;

@end
