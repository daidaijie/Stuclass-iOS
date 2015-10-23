//
//  CourseTable+CoreDataProperties.h
//  stuclass
//
//  Created by JunhaoWang on 10/22/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CourseTable.h"

NS_ASSUME_NONNULL_BEGIN

@interface CourseTable (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *semester;
@property (nullable, nonatomic, retain) NSNumber *year;
@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) NSSet<Course *> *course;

@end

@interface CourseTable (CoreDataGeneratedAccessors)

- (void)addCourseObject:(Course *)value;
- (void)removeCourseObject:(Course *)value;
- (void)addCourse:(NSSet<Course *> *)values;
- (void)removeCourse:(NSSet<Course *> *)values;

@end

NS_ASSUME_NONNULL_END
