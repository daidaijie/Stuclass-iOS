//
//  DiscussViewController.m
//  stuclass
//
//  Created by JunhaoWang on 10/19/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "DiscussViewController.h"

@interface DiscussViewController ()



@end


@implementation DiscussViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
    l.text = @"3";
    [self.view addSubview:l];
}


@end
