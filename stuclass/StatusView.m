//
//  StatusView.m
//  stuclass
//
//  Created by JunhaoWang on 4/11/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "StatusView.h"

@implementation StatusView

//- (instancetype)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    
//    if (self) {
//        
//        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(27, 10, 100, 20)];
//        _statusLabel.textColor = [UIColor grayColor];
//        _statusLabel.font = [UIFont systemFontOfSize:13.0];
//        [self addSubview:_statusLabel];
//    }
//    
//    return self;
//}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(27, 10, 100, 20)];
        _statusLabel.textColor = [UIColor grayColor];
        _statusLabel.font = [UIFont systemFontOfSize:13.0];
        [self addSubview:_statusLabel];
    }
    
    return self;
}


@end
