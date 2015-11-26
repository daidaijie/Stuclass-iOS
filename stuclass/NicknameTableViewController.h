//
//  NicknameTableViewController.h
//  stuclass
//
//  Created by JunhaoWang on 11/26/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NicknameChangedDelegate <NSObject>

- (void)nicknameChangedTo:(NSString *)nickname;

@end


@interface NicknameTableViewController : UITableViewController

@property (weak, nonatomic) id<NicknameChangedDelegate> delegate;

@end
