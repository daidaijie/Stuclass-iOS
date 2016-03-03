//
//  JHDater.m
//  stuget
//
//  Created by JunhaoWang on 7/15/15.
//  Copyright (c) 2015 JunhaoWang. All rights reserved.
//

#import "JHDater.h"


@interface JHDater ()

@property (nonatomic) NSUInteger flags;
@property (strong, nonatomic) NSDateFormatter *formatter;

@end

@implementation JHDater


+ (instancetype)sharedInstance {
    
    static id sharedInstance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}


- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday;
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateStyle:NSDateFormatterFullStyle];
        [_formatter setDateFormat:@"yyyy/MM/dd"];
    }
    
    return self;
}


#pragma mark - Date Method

- (long long)getNowSecondFrom1970
{
    NSDate *now = [NSDate date];
    
    return [now timeIntervalSince1970];
}


- (NSString *)getTimeStrWithTimeFrom1970:(long long)pub_time
{
//    NSDate *now = [self getCurrentZoneDate:[NSDate date]];
    NSDate *now = [NSDate date];
    
    long long now_second = [now timeIntervalSince1970];
    
    long long interval = now_second - pub_time;
    
    if (interval >= 0 && interval < 60) {
        return @"1分钟前";
    } else if (interval >= 60 && interval < 3600) {
        return [NSString stringWithFormat:@"%llu分钟前", interval / 60];
    } else if (interval >= 3600 && interval < (3600 * 24)) {
        return [NSString stringWithFormat:@"%llu小时前", interval / 3600];
    } else if (interval >= (3600 * 24) && interval < (3600 * 24 * 30)) {
        return [NSString stringWithFormat:@"%llu天前", interval / 3600 / 24];
    } else if (interval >= (3600 * 24 * 30) && interval < (3600 * 24 * 30 * 365)) {
        return [NSString stringWithFormat:@"%llu月前", interval / 3600 / 24 / 30];
    } else if (interval >= (3600 * 24 * 30 * 365)) {
//        NSLog(@"----------%llu", interval);
        return [NSString stringWithFormat:@"%llu年前", interval / 3600 / 24 / 30 / 365];
    } else if (interval < 0) {
        return [NSString stringWithFormat:@"来自未来"];
    }
    
    
    return @"";
}


- (NSDate *)getCurrentZoneDate:(NSDate *)date {
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    
    return [date dateByAddingTimeInterval:interval];
}


// 返回具体时间
- (NSInteger)yearForDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar components:_flags fromDate:date].year;
}
- (NSInteger)monthForDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar components:_flags fromDate:date].month;
}
- (NSInteger)dayForDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar components:_flags fromDate:date].day;
}
- (NSInteger)hourForDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar components:_flags fromDate:date].hour;
}
- (NSInteger)minuteForDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar components:_flags fromDate:date].minute;
}
- (NSInteger)secondForDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar components:_flags fromDate:date].second;
}



// 返回格式化时间字符串
- (NSString *)dateStringForDate:(NSDate *)date withFormate:(NSString *)format
{
    [_formatter setDateFormat:format];
    return [_formatter stringFromDate:date];
}


// 返回排序后的时间
- (NSMutableArray *)sortDateWithArray:(NSArray *)array
{
    NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:[array sortedArrayUsingComparator:^(id obj1, id obj2) {
        NSDate *date1 = [obj1 objectForKey:@"date"];
        NSDate *date2 = [obj2 objectForKey:@"date"];
        return [date2 compare:date1];
    }]];
    
    return sortedArray;
}


// 生成分类数组
- (NSMutableArray *)generateArray:(NSArray *)fromArray
{
    NSMutableArray *toArray = [NSMutableArray array];
    NSInteger lastYear = 0;
    NSInteger lastMonth = 0;
    for (NSDictionary *dict in fromArray) {
        NSDate *date = [dict objectForKey:@"date"];
        NSInteger year = [self yearForDate:date];
        NSInteger month = [self monthForDate:date];
        if ((year != lastYear) || (month != lastMonth)) {
            NSDictionary *newDict = @{@"category": [self dateStringForDate:date withFormate:@"yyyy / MM"],
                                      @"receipt": [NSMutableArray arrayWithObject:dict],
                                     };
            [toArray addObject:newDict];
            lastYear = year;
            lastMonth = month;
        } else {
            NSDictionary *lastDict = [toArray lastObject];
            [[lastDict objectForKey:@"receipt"] addObject:dict];
        }
    }
    
    return toArray;
}


// 返回星期 周一-0 周日-6
- (NSInteger)weekForDate:(NSDate *)date
{
//    date = [self getCurrentZoneDate:date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger week = [calendar components:NSCalendarUnitWeekday fromDate:date].weekday;
    return week == 1 ? 6 : (week-=2);
}


// 返回day天后的日期
- (NSDate *)dateAfterDay:(NSUInteger)day
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    
    [componentsToAdd setDay:day];
    
    NSDate *dateAfterDay = [calendar dateByAddingComponents:componentsToAdd toDate:[NSDate date] options:0];
    
    return dateAfterDay;
}


- (NSInteger)getDaysFrom:(NSDate *)startDate To:(NSDate *)endDate
{
    NSTimeInterval interval1 = [[self getCurrentZoneDate:startDate] timeIntervalSince1970];
    NSTimeInterval interval2 = [[self getCurrentZoneDate:endDate] timeIntervalSince1970];
    NSInteger daySeconds = 24 * 60 * 60;
    NSInteger days1 = interval1 / daySeconds;
    NSInteger days2 = interval2 / daySeconds;
    return days2 - days1;
}

- (NSDate *)dateFromString:(NSString *)string
{
    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    
    [inputFormatter setDateFormat:@"yyyy/MM/dd/HH"];
    
    return [self getCurrentZoneDate:[inputFormatter dateFromString:string]];
}


@end
