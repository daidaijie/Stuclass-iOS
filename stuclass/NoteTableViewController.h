//
//  NoteTableViewController.h
//  stuclass
//
//  Created by JunhaoWang on 10/23/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NoteTableViewControllerDelegate <NSObject>

- (void)noteTableViewControllerDidSaveNote:(NSString *)noteStr time:(NSString *)timeStr;

@end

@interface NoteTableViewController : UITableViewController

@property (strong, nonatomic) NSString *noteStr;

@property (strong, nonatomic) NSString *classID;

@property (weak, nonatomic) id<NoteTableViewControllerDelegate> delegate;

@end
