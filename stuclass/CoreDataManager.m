//
//  CoreDataManager.m
//  stuclass
//
//  Created by JunhaoWang on 10/21/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "CoreDataManager.h"
#import "AppDelegate.h"
#import "CourseTable.h"
#import "Course.h"
#import "Note.h"
#import "AppDelegate.h"

@interface CoreDataManager ()

@property (weak, nonatomic) AppDelegate *appDelagate;

@end


@implementation CoreDataManager


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
        // Init here
        _appDelagate = [UIApplication sharedApplication].delegate;
    }
    
    return self;
}

#pragma mark - CoreData


#pragma mark - Class

- (BOOL)isClassTableExistedWithYear:(NSInteger)year semester:(NSInteger)semester username:(NSString *)username
{
    // 判断是否存在
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CourseTable"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year==%d AND semester==%d AND username==%@", year, semester, username];
    
    request.predicate = predicate;
    
    NSError *error = nil;
    NSArray *obj = [_appDelagate.managedObjectContext executeFetchRequest:request error:&error];
    
    CourseTable *table = [obj firstObject];
    
    if (error) {
        NSLog(@"课程 - 查询错误 - %@", error);
    }
    
    if (table) {
        return YES;
    } else {
        return NO;
    }
}

// 写入课表到数据库
- (void)writeSyncClassTableToCoreDataWithClassesArray:(NSMutableArray *)data withYear:(NSInteger)year semester:(NSInteger)semester username:(NSString *)username
{
    // 判断是否存在
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CourseTable"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year==%d AND semester==%d AND username==%@", year, semester, username];
    
    request.predicate = predicate;
    
    NSError *error = nil;
    NSArray *obj = [_appDelagate.managedObjectContext executeFetchRequest:request error:&error];
    
    CourseTable *table = [obj firstObject];
    
    if (error) {
        NSLog(@"课程 - 查询错误 - %@", error);
        return;
    }
    
    if (table) {
        // 存在 要删掉现在的
        NSLog(@"删掉课程表 %@ - %@ - %@", table.username, table.year, table.semester);
        
        [_appDelagate.managedObjectContext deleteObject:table];
    }
    
    // 新建课程表
    CourseTable *newTable = [NSEntityDescription insertNewObjectForEntityForName:@"CourseTable" inManagedObjectContext:_appDelagate.managedObjectContext];
    
    newTable.year = [NSNumber numberWithInteger:year];
    newTable.semester = [NSNumber numberWithInteger:semester];
    newTable.username = username;
    
    NSLog(@"新建课程表 %@ - %@ - %@", newTable.username, newTable.year, newTable.semester);
    
    NSInteger order = 0;
    
    for (NSDictionary *class in data) {
        
        NSString *course_id = class[@"class_id"] ? class[@"class_id"] : @"";
        NSString *course_number = class[@"id"] ? class[@"id"] : @"";
        NSString *course_name = class[@"name"] ? class[@"name"] : @"";
        NSString *course_room = class[@"room"] ? class[@"room"] : @"";
        NSString *course_span = class[@"duration"] ? class[@"duration"] : @"";
        NSString *course_teacher = class[@"teacher"] ? class[@"teacher"] : @"";
        NSString *course_credit = class[@"credit"] ? class[@"credit"] : @"";
        NSDictionary *course_time = class[@"days"] ? class[@"days"] : [NSDictionary dictionary];
        
        Course *course = [NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:_appDelagate.managedObjectContext];
        
        course.course_id = course_id;
        course.course_number = course_number;
        course.course_name = course_name;
        course.course_room = course_room;
        course.course_span = course_span;
        course.course_teacher = course_teacher;
        course.course_credit = course_credit;
        course.course_time = course_time;
        course.course_order = [NSNumber numberWithInteger:order];
        
        [newTable addCourseObject:course];
        
        order++;
    }
    
    [_appDelagate.managedObjectContext save:&error];
    
    if (error) {
        NSLog(@"课程 - 不存在时添加错误 - %@", error);
        return;
    }
}

// 从数据库拿出课表
- (NSArray *)getClassDataFromCoreDataWithYear:(NSInteger)year semester:(NSInteger)semester username:(NSString *)username
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CourseTable"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year==%d AND semester==%d AND username==%@", year, semester, username];
    
    request.predicate = predicate;
    
    NSError *error = nil;
    NSArray *obj = [_appDelagate.managedObjectContext executeFetchRequest:request error:&error];
    
    CourseTable *table = [obj firstObject];
    
    if (error) {
        NSLog(@"课程 - 查询错误 - %@", error);
        return nil;
    }
    
    NSMutableArray *classData = [NSMutableArray array];
    
    if (table) {
        
        // 将取出的课程按order排序
        NSArray *sortDescription = @[[[NSSortDescriptor alloc] initWithKey:@"course_order" ascending:YES]];
        NSArray *sortedArray = [table.course sortedArrayUsingDescriptors:sortDescription];
        
        for (Course *class in sortedArray) {
            
            NSDictionary *dict = @{
                                   @"class_id": class.course_id,
                                   @"id": class.course_number,
                                   @"name": class.course_name,
                                   @"room": class.course_room,
                                   @"duration": class.course_span,
                                   @"teacher": class.course_teacher,
                                   @"credit": class.course_credit,
                                   @"days": class.course_time,
                                   @"order": class.course_order,
                                   };
            [classData addObject:dict];
        }
        
    }

    return classData;
}


// 从数据库删除课表
- (void)deleteClassTableWithYear:(NSInteger)year semester:(NSInteger)semester
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CourseTable"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year==%d AND semester==%d", year, semester];
    
    request.predicate = predicate;
    
    NSError *error = nil;
    NSArray *obj = [_appDelagate.managedObjectContext executeFetchRequest:request error:&error];
    
    CourseTable *table = [obj firstObject];
    
    if (error) {
        NSLog(@"课程 - 查询错误 - %@", error);
        return;
    }
    
    [_appDelagate.managedObjectContext deleteObject:table];
    
    [_appDelagate.managedObjectContext save:&error];
}

- (void)deleteClassWithClassID:(NSString *)classID withYear:(NSUInteger)year semester:(NSUInteger)semester username:(NSString *)username
{
    // 判断是否存在
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CourseTable"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year==%d AND semester==%d AND username==%@", year, semester, username];
    
    request.predicate = predicate;
    
    NSError *error = nil;
    NSArray *obj = [_appDelagate.managedObjectContext executeFetchRequest:request error:&error];
    
    CourseTable *table = [obj firstObject];
    
    if (error) {
        NSLog(@"课程 - 查询错误 - %@", error);
        return;
    }
    
    if (table) {
        // 获取课表
        
        Course *toDelete;
        
        for (Course *course in table.course) {
            if ([course.course_id isEqualToString:classID]) {
                toDelete = course;
                break;
            }
        }
        
        if (toDelete) {
            [table removeCourseObject:toDelete];
            
            [_appDelagate.managedObjectContext save:&error];
            
            NSLog(@"删除课程 %@ - %@ - %@ - %@", table.username, table.year, table.semester, toDelete.course_id);
            
            if (error) {
                NSLog(@"课程 - 删除课程错误 - %@", error);
                return;
            }
        }
    }
}


- (void)writeOneClassToCoreDataWithClassName:(NSString *)name classID:(NSString *)classID week:(NSUInteger)week start:(NSUInteger)start span:(NSUInteger)span startWeek:(NSUInteger)startWeek endWeek:(NSUInteger)endWeek weekType:(NSString *)weekType withYear:(NSUInteger)year semester:(NSUInteger)semester username:(NSString *)username
{
    // 判断是否存在
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CourseTable"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year==%d AND semester==%d AND username==%@", year, semester, username];
    
    request.predicate = predicate;
    
    NSError *error = nil;
    NSArray *obj = [_appDelagate.managedObjectContext executeFetchRequest:request error:&error];
    
    CourseTable *table = [obj firstObject];
    
    if (error) {
        NSLog(@"课程 - 查询错误 - %@", error);
        return;
    }
    
    if (table) {
        // 排序取最大order
        NSArray *sortDescription = @[[[NSSortDescriptor alloc] initWithKey:@"course_order" ascending:YES]];
        NSArray *sortedArray = [table.course sortedArrayUsingDescriptors:sortDescription];
        
        Course *lastCourse = [sortedArray lastObject];
        
        NSUInteger order = [lastCourse.course_order integerValue] + 1;
        
        // 插入课程吧
        Course *course = [NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:_appDelagate.managedObjectContext];
        
        course.course_id = classID;
        course.course_number = @"";
        
        course.course_name = name;
        course.course_room = @"";
        course.course_span = [NSString stringWithFormat:@"%d-%d", startWeek, endWeek];
        course.course_teacher = @"";
        course.course_credit = @"";
        course.course_order = [NSNumber numberWithInteger:order];
        
        NSMutableDictionary *time = [NSMutableDictionary dictionaryWithDictionary:@{@"w0": @"None", @"w1": @"None", @"w2": @"None", @"w3": @"None", @"w4": @"None", @"w5": @"None", @"w6": @"None"}];
        
        // time
        NSMutableString *timeStr = [NSMutableString string];
        for (NSUInteger i = 0; i < span; i++) {
            NSUInteger time = start + i;
            
            NSString *timeCh = [NSString stringWithFormat:@"%d", time];
            if (time == 10) {
                timeCh = @"0";
            } else if (time == 11) {
                timeCh = @"A";
            } else if (time == 12) {
                timeCh = @"B";
            } else if (time == 13) {
                timeCh = @"C";
            }
            
            [timeStr appendString:timeCh];
        }
        
        if (weekType.length != 0) {
            timeStr = [NSMutableString stringWithFormat:@"%@%@", weekType, timeStr];
        }
        
        if (week == 1) {
            time[@"w1"] = timeStr;
        } else if (week == 2) {
            time[@"w2"] = timeStr;
        } else if (week == 3) {
            time[@"w3"] = timeStr;
        } else if (week == 4) {
            time[@"w4"] = timeStr;
        } else if (week == 5) {
            time[@"w5"] = timeStr;
        } else if (week == 6) {
            time[@"w6"] = timeStr;
        } else if (week == 7) {
            time[@"w0"] = timeStr;
        }
        
        course.course_time = time;
        
        [table addCourseObject:course];
        
        [_appDelagate.managedObjectContext save:&error];
        
        NSLog(@"插入课程 %@ - %@ - %@ - %@", table.username, table.year, table.semester, name);
        
        if (error) {
            NSLog(@"课程 - 插入课程错误 - %@", error);
            return;
        }
    }
}



#pragma mark - Note

// 写入笔记
- (void)writeNoteToCoreDataWithContent:(NSString *)content time:(NSString *)time classID:(NSString *)class_id username:(NSString *)username
{
    // 判断是否存在
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Note"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class_id==%@ AND username==%@", class_id, username];
    
    request.predicate = predicate;
    
    NSError *error = nil;
    NSArray *obj = [_appDelagate.managedObjectContext executeFetchRequest:request error:&error];
    
    Note *note = [obj firstObject];
    
    if (error) {
        NSLog(@"笔记 - 查询错误 - %@", error);
        return;
    }
    
    if (note) {
        // 更新
        
        NSLog(@"更新笔记 %@ - %@ - %@", note.username, note.class_id, content);
        
        note.content = content;
        note.time = time;
        
        NSError *error = nil;
        
        [_appDelagate.managedObjectContext save:&error];
        
        if (error) {
            NSLog(@"笔记 - 存在时添加错误 - %@", error);
            return;
        }
        
        
    } else {
        // 新增
        Note *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:_appDelagate.managedObjectContext];
        
        newNote.class_id = class_id;
        newNote.username = username;
        newNote.content = content;
        newNote.time = time;
        
        NSLog(@"新建笔记 %@ - %@ - %@", newNote.username, newNote.class_id, newNote.content);
        
        NSError *error = nil;
        
        [_appDelagate.managedObjectContext save:&error];
        
        if (error) {
            NSLog(@"笔记 - 不存在时添加错误 - %@", error);
            return;
        }
    }
}

// 拿出笔记
- (NSDictionary *)getNoteFromCoreDataWithClassID:(NSString *)class_id username:(NSString *)username
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Note"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class_id==%@ AND username==%@", class_id, username];
    
    request.predicate = predicate;
    
    NSError *error = nil;
    NSArray *obj = [_appDelagate.managedObjectContext executeFetchRequest:request error:&error];
    
    Note *note = [obj firstObject];
    
    if (error) {
        NSLog(@"笔记 - 查询错误 - %@", error);
        return nil;
    }
    
    if (note) {
        
        return @{@"content": note.content, @"time": note.time};
        
    } else {
        
        // 不存在笔记
        return @{@"content": @"", @"time": @""};
    }
}


@end













