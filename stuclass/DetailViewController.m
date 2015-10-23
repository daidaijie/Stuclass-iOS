//
//  DetailViewController.m
//  stuclass
//
//  Created by JunhaoWang on 10/17/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "DetailViewController.h"
#import "BarView.h"
#import "PersonViewController.h"
#import "HomeworkViewController.h"
#import "DiscussViewController.h"

static const CGFloat kBarViewHeight = 43.0;

@interface DetailViewController ()

@property (strong, nonatomic) BarView *barView;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (assign, nonatomic) NSInteger index;

@end

@implementation DetailViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupBarBackButton];
    
    [self setupBarView];
    
    [self setupScrollView];
    
    [self setupViewController];
}


#pragma mark - Setup Method

- (void)setupBarBackButton
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
}

- (void)setupBarView
{
    self.barView = [[BarView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, kBarViewHeight)];
    [self.view addSubview:self.barView];
    
    [self.barView.firstButton addTarget:self action:@selector(barButtonPress:) forControlEvents:UIControlEventTouchDown];
    [self.barView.secondButton addTarget:self action:@selector(barButtonPress:) forControlEvents:UIControlEventTouchDown];
    [self.barView.thirdButton addTarget:self action:@selector(barButtonPress:) forControlEvents:UIControlEventTouchDown];
}


- (void)setupScrollView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.barView.frame.origin.y + kBarViewHeight, self.view.frame.size.width, self.view.frame.size.height - kBarViewHeight - 64)];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.scrollEnabled = NO;
    self.scrollView.bounces = NO;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 3, self.scrollView.frame.size.height);
    [self.view addSubview:self.scrollView];
}


- (void)setupViewController
{
    CGFloat width = self.scrollView.frame.size.width;
    CGFloat height = self.scrollView.frame.size.height;
    
    PersonViewController *pvc = [[PersonViewController alloc] init];
    [self addChildViewController:pvc];
    pvc.view.frame = CGRectMake(0, 0, width, height);
    pvc.classBox = self.classBox;
    [self.scrollView addSubview:pvc.view];
    
    HomeworkViewController *hvc = [[HomeworkViewController alloc] init];
    [self addChildViewController:hvc];
    hvc.view.frame = CGRectMake(width, 0, width, height);
    [self.scrollView addSubview:hvc.view];
    
    DiscussViewController *dvc = [[DiscussViewController alloc] init];
    [self addChildViewController:dvc];
    dvc.view.frame = CGRectMake(width * 2, 0, width, height);
    [self.scrollView addSubview:dvc.view];
}



#pragma mark - Event Method

- (void)barButtonPress:(UIButton *)sender
{
    NSInteger tag = sender.tag;
    
    if (self.index != tag) {
        
        self.index = tag;
        
        [self.barView gotoIndex:tag];
        
        [self.scrollView setContentOffset:CGPointMake(tag * self.scrollView.frame.size.width, 0) animated:YES];
    }
}

@end









