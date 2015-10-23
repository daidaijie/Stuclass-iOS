//
//  SettingTableViewController.h
//  stuclass
//
//  Created by JunhaoWang on 10/12/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingLogOutDelegate <NSObject>

- (void)settingTableViewControllerLogOut;

@end


@interface SettingTableViewController : UITableViewController

@property (weak, nonatomic) id<SettingLogOutDelegate> delegate;


@end
