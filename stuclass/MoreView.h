//
//  MoreView.h
//  stuclass
//
//  Created by JunhaoWang on 11/22/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreView : UIView

@property (strong, nonatomic) NSArray *itemsArray;

- (instancetype)initWithItems:(NSArray *)items;

@end
