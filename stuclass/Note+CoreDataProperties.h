//
//  Note+CoreDataProperties.h
//  stuclass
//
//  Created by JunhaoWang on 10/24/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Note.h"

NS_ASSUME_NONNULL_BEGIN

@interface Note (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *class_id;
@property (nullable, nonatomic, retain) NSString *content;
@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) NSString *time;

@end

NS_ASSUME_NONNULL_END
