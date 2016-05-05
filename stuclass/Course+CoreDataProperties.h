//
//  Course+CoreDataProperties.h
//  stuclass
//
//  Created by JunhaoWang on 5/5/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Course.h"

NS_ASSUME_NONNULL_BEGIN

@interface Course (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *course_credit;
@property (nullable, nonatomic, retain) NSString *course_description;
@property (nullable, nonatomic, retain) NSString *course_id;
@property (nullable, nonatomic, retain) NSNumber *course_isClass;
@property (nullable, nonatomic, retain) NSNumber *course_isColorful;
@property (nullable, nonatomic, retain) NSString *course_name;
@property (nullable, nonatomic, retain) NSString *course_number;
@property (nullable, nonatomic, retain) NSNumber *course_order;
@property (nullable, nonatomic, retain) NSString *course_room;
@property (nullable, nonatomic, retain) NSString *course_span;
@property (nullable, nonatomic, retain) NSString *course_teacher;
@property (nullable, nonatomic, retain) NSDictionary *course_time;
@property (nullable, nonatomic, retain) CourseTable *course_table;

@end

NS_ASSUME_NONNULL_END
