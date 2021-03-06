//
//  ScrollManager.h
//  MobileTrading
//
//  Created by Prince Kumar Sharma on 25/07/13.
//  Copyright (c) 2013 Prince Kumar Sharma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScrollManager : NSObject

+ (id)sharedManager;

-(void)setpage:(int)page ForKey:(NSString*)key;
-(int)getpageForKey:(NSString*)key;

-(void)setMYpage:(int)page ForKey:(NSString*)key;
-(int)getMYpageForKey:(NSString*)key;

-(void)setURpage:(int)page ForKey:(NSString*)key;
-(int)getURpageForKey:(NSString*)key;


-(void)restoreState;
-(void)restoreMYState;
-(void)restoreURState;

@end
