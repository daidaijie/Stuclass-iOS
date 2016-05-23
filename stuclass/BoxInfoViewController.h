//
//  BoxInfoViewController.h
//  stuclass
//
//  Created by JunhaoWang on 5/2/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClassBox.h"

@protocol BoxInfoDelegate <NSObject>

- (void)boxInfoDelegateDidChanged:(NSArray *)boxData;

@end


@interface BoxInfoViewController : UIViewController

@property (strong, nonatomic) ClassBox *classBox;

@property (strong, nonatomic) NSArray *boxData;

@property (weak, nonatomic) id<BoxInfoDelegate> delegate;

@end
