//
//  MyManager.m
//  MobileTrading
//
//  Created by Prince Kumar Sharma on 25/07/13.
//  Copyright (c) 2013 Prince Kumar Sharma. All rights reserved.
//

#import "ScrollManager.h"

static NSMutableDictionary *dictionary;
static NSMutableDictionary *myDictionary;

@implementation ScrollManager

#pragma mark Singleton Methods

+ (id)sharedManager {
    static ScrollManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    
    
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (void)setpage:(int)page ForKey:(NSString*)key
{
    [dictionary setValue:[NSString stringWithFormat:@"%i",page] forKey:key];
}

- (int)getpageForKey:(NSString*)key
{
    return [[dictionary valueForKey:key] intValue];
}

- (void)setMYpage:(int)page ForKey:(NSString*)key
{
    [myDictionary setValue:[NSString stringWithFormat:@"%i",page] forKey:key];
}

- (int)getMYpageForKey:(NSString*)key
{
    return [[myDictionary valueForKey:key] intValue];
}

- (id)init {
    if (self = [super init]) {
        dictionary = [[NSMutableDictionary alloc] init];
        myDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)restoreState
{
    NSLog(@"restoreState");
    dictionary = [[NSMutableDictionary alloc] init];
}

- (void)restoreMYState
{
    NSLog(@"restoreMYState");
    myDictionary = [[NSMutableDictionary alloc] init];
}

@end
