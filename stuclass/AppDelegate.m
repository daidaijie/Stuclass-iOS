//
//  AppDelegate.m
//  stuclass
//
//  Created by JunhaoWang on 10/9/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "AppDelegate.h"
#import <KVNProgress/KVNProgress.h>
#import "Define.h"
#import "MobClick.h"
#import "JHDater.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Umeng
    [MobClick startWithAppkey:@"565fd3d1e0f55adf58000149" reportPolicy:BATCH channelId:@"App Store"];
    
    // version标识
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    
    
    // Week Configuration
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *weekData = [ud objectForKey:@"WEEK_DATA"];
    
    if (!weekData) {
        NSDate *date = [NSDate date];
        NSLog(@"更新第一天时间 - %@", date);
        weekData = @{@"week":@1, @"date":date};
        [ud setObject:weekData forKey:@"WEEK_DATA"];
    }
    
    // KVN Configuration
    KVNProgressConfiguration *configuration = [[KVNProgressConfiguration alloc] init];
    
    configuration.fullScreen = YES;
    
    configuration.backgroundTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1f];
    
    configuration.minimumErrorDisplayTime = 1.0;
    
    configuration.minimumSuccessDisplayTime = 1.0;
    
    configuration.circleStrokeForegroundColor = [UIColor colorWithWhite:0.25 alpha:1.0];
    
    configuration.statusColor = [UIColor colorWithWhite:0.25 alpha:1.0];
    
    [KVNProgress setConfiguration:configuration];
    
    // UIApplication
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    
    UIImage *backBtnIcon = [UIImage imageNamed:@"toolbar-back"];
    [UINavigationBar appearance].backIndicatorImage = backBtnIcon;
    [UINavigationBar appearance].backIndicatorTransitionMaskImage = backBtnIcon;
    
    [UINavigationBar appearance].barTintColor = MAIN_COLOR_BAR;
    [UINavigationBar appearance].titleTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:19.0], NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    [UITabBar appearance].tintColor = MAIN_COLOR;
    
    // 启动等待时间
    [NSThread sleepForTimeInterval:0.2];
    
    NSLog(@"当前用户 - TOKEN - %@", [[NSUserDefaults standardUserDefaults] valueForKey:@"USER_TOKEN"]);
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - CoreData

//托管对象
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

//托管对象上下文
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

//持久化存储协调器
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    NSURL *storeURL = [NSURL fileURLWithPath:[doc stringByAppendingPathComponent:@"CoreDataCourse.sqlite"]];
    
    NSLog(@"path is %@",storeURL);
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Error: %@, %@",error,[error userInfo]);
    }
    
    return _persistentStoreCoordinator;
}






@end
