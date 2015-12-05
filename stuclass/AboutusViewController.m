//
//  AboutusViewController.m
//  stuclass
//
//  Created by JunhaoWang on 12/5/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "AboutusViewController.h"

@interface AboutusViewController ()

@end

@implementation AboutusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)aboutusPress:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://hjsmallfly.wicp.net/app/aboutus.html"]];
}

@end
