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
// 写入课表到数据库
- (void)writeClassTableToCoreDataWithClassesArray:(NSMutableArray *)data withYear:(NSInteger)year semester:(NSInteger)semester username:(NSString *)username
{
//     testing
//    data = [NSMutableArray arrayWithArray:data];
//    [data addObject:@{@"class_id":@"diao ni hi", @"name":@"lao mu", @"room":@"hell", @"duration":@"1-16"}];
//    [data addObject:@{@"class_id":@"diao ni hi c", @"name":@"lao mu c", @"room":@"hell", @"duration":@"1-16"}];
//    [data addObject:@{@"class_id":@"diao ni hi b", @"name":@"lao mu b", @"room":@"hell", @"duration":@"1-16"}];
    
    
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
        // 覆盖
        
        NSLog(@"更新课程表 %@ - %@ - %@", table.username, table.year, table.semester);
        
        // 该课表本地所有课程
        NSSet *courses = table.course;
        
        NSInteger order = 0;
        
        // 添加及更新
        for (NSDictionary *class in data) {
            
            order++;
            
            NSString *course_id = class[@"class_id"] ? class[@"class_id"] : @"";
            NSString *course_number = class[@"id"] ? class[@"id"] : @"";
            NSString *course_name = class[@"name"] ? class[@"name"] : @"";
            NSString *course_room = class[@"room"] ? class[@"room"] : @"";
            NSString *course_span = class[@"duration"] ? class[@"duration"] : @"";
            NSString *course_teacher = class[@"teacher"] ? class[@"teacher"] : @"";
            NSString *course_credit = class[@"credit"] ? class[@"credit"] : @"";
            NSDictionary *course_time = class[@"days"] ? class[@"days"] : [NSDictionary dictionary];
            
            BOOL newCourse = YES;
            
            for (Course *c in courses) {
                if ([c.course_id isEqualToString:course_id]) {
                    // 找到该课程 - 找不到说明是新的
                    // 更新数据
                    NSLog(@"更新本地存在的课程 %@ - %@", course_name, course_id);
                    c.course_id = course_id;
                    c.course_number = course_number;
                    c.course_name = course_name;
                    c.course_room = course_room;
                    c.course_span = course_span;
                    c.course_teacher = course_teacher;
                    c.course_credit = course_credit;
                    c.course_time = course_time;
                    c.course_order = [NSNumber numberWithInteger:order];
                    
                    newCourse = NO;
                }
            }
            
            // 添加本地不存在的新课程
            if (newCourse) {
                
                Course *course = [NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:_appDelagate.managedObjectContext];
                NSLog(@"添加本地不存在的课程 %@ - %@", course_name, course_id);
                course.course_id = course_id;
                course.course_number = course_number;
                course.course_name = course_name;
                course.course_room = course_room;
                course.course_span = course_span;
                course.course_teacher = course_teacher;
                course.course_credit = course_credit;
                course.course_time = course_time;
                course.course_order = [NSNumber numberWithInteger:order];
                
                [table addCourseObject:course];
            }
        }
        
        // 删掉服务器没有的课程
        
        BOOL shouldDelete = NO;
        
        NSMutableSet *classes_should_be_deleted = [NSMutableSet set];
        
        for (Course *c in courses) {
            
            BOOL notFoundInData = YES;
            
            for (NSDictionary *class in data) {
                if ([c.course_id isEqualToString:class[@"class_id"]]) {
                    // Found
                    notFoundInData = NO;
                    break;
                }
            }
            
            if (notFoundInData) {
                shouldDelete = YES;
                [classes_should_be_deleted addObject:c];
            }
        }
        
        if (shouldDelete) {
            NSLog(@"删除服务器不存在的课程 %@", classes_should_be_deleted);
            [table removeCourse:classes_should_be_deleted];
        }
        
        NSError *error = nil;
        
        [_appDelagate.managedObjectContext save:&error];
        
        if (error) {
            NSLog(@"课程 - 存在时添加错误 - %@", error);
            return;
        }
        
    } else {
        // 新增
        CourseTable *newTable = [NSEntityDescription insertNewObjectForEntityForName:@"CourseTable" inManagedObjectContext:_appDelagate.managedObjectContext];
        
        newTable.year = [NSNumber numberWithInteger:year];
        newTable.semester = [NSNumber numberWithInteger:semester];
        newTable.username = username;
        
        NSLog(@"新建课程表 %@ - %@ - %@", newTable.username, newTable.year, newTable.semester);
        
        NSInteger order = 0;
        
        for (NSDictionary *class in data) {
            
            order++;
            
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
        }
        
        NSError *error = nil;
        
        [_appDelagate.managedObjectContext save:&error];
        
        if (error) {
            NSLog(@"课程 - 不存在时添加错误 - %@", error);
            return;
        }
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
        note.content = time;
        
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













