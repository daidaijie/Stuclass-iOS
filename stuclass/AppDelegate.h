//
//  AppDelegate.h
//  stuclass
//
//  Created by JunhaoWang on 10/9/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "WXApi.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic, readonly) NSManagedObjectModel *managedObjectModel;

@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

