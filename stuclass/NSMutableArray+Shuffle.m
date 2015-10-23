//
//  NSMutableArray+Shuffle.m
//  stuclass
//
//  Created by JunhaoWang on 10/12/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "NSMutableArray+Shuffle.h"

@implementation NSMutableArray (Shuffle)


- (void)shuffle
{
    int count = [self count];
    
    for (int i = 0; i < count; ++i) {
        int n = (arc4random() % (count - i)) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}


@end
