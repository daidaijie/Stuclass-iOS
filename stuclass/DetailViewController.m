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
#import "Define.h"
#import "ClassBox.h"

@interface DetailViewController ()

@property (strong, nonatomic) BarView *barView;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (assign, nonatomic) NSInteger index;

@property (strong, nonatomic) PersonViewController *pvc;

@property (strong, nonatomic) HomeworkViewController *hvc;

@property (strong, nonatomic) DiscussViewController *dvc;

@end

@implementation DetailViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupBarBackButton];
    
    [self setupBarView];
    
    [self setupScrollView];
    
    [self setupGesture];
    
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
    self.barView = [[BarView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, global_BarViewHeight)];
    [self.view addSubview:self.barView];
    
    [self.barView.firstButton addTarget:self action:@selector(barButtonPress:) forControlEvents:UIControlEventTouchDown];
    [self.barView.secondButton addTarget:self action:@selector(barButtonPress:) forControlEvents:UIControlEventTouchDown];
    [self.barView.thirdButton addTarget:self action:@selector(barButtonPress:) forControlEvents:UIControlEventTouchDown];
}


- (void)setupScrollView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.barView.frame.origin.y + global_BarViewHeight, self.view.frame.size.width, self.view.frame.size.height - global_BarViewHeight - 64)];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.scrollEnabled = NO;
    self.scrollView.bounces = NO;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 3, self.scrollView.frame.size.height);
    [self.view addSubview:self.scrollView];
}

- (void)setupGesture
{
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    
    rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:rightSwipeRecognizer];
    
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    
    leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.scrollView addGestureRecognizer:leftSwipeRecognizer];
}


- (void)setupViewController
{
    CGFloat width = self.scrollView.frame.size.width;
    CGFloat height = self.scrollView.frame.size.height;
    
    self.pvc = [[PersonViewController alloc] init];
    [self addChildViewController:self.pvc];
    self.pvc.view.frame = CGRectMake(0, 0, width, height);
    [self.pvc setupBoxData:self.classBox];
    [self.scrollView addSubview:self.pvc.view];
    
    self.hvc = [[HomeworkViewController alloc] init];
    [self addChildViewController:self.hvc];
    self.hvc.view.frame = CGRectMake(width, 0, width, height);
    [self.scrollView addSubview:self.hvc.view];
    
    self.dvc = [[DiscussViewController alloc] init];
    [self addChildViewController:self.dvc];
    self.dvc.view.frame = CGRectMake(width * 2, 0, width, height);
    [self.scrollView addSubview:self.dvc.view];
}



#pragma mark - Event Method

- (void)barButtonPress:(UIButton *)sender
{
    NSInteger tag = sender.tag;
    
    if (self.index != tag) {
        
        self.index = tag;
        
        [self.barView gotoIndex:tag];
        
        [self.scrollView setContentOffset:CGPointMake(tag * self.scrollView.frame.size.width, 0) animated:YES];
        
        if (self.index == 1) {
            [self performSelector:@selector(getHomework) withObject:nil afterDelay:0.3];
        } else if (self.index == 2) {
            [self performSelector:@selector(getDiscuss) withObject:nil afterDelay:0.3];
        }
    }
}

- (void)getHomework
{
    [self.hvc getHomeworkDataWithClassNumber:_classBox.box_number];
}

- (void)getDiscuss
{
    [self.dvc getDiscussDataWithClassNumber:_classBox.box_number];
}


#pragma mark - Gesture

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)sender
{
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        
        if (self.index == 0 || self.index == 1) {
            
            self.index++;
            [self.barView gotoIndex:self.index];
            
            [self.scrollView setContentOffset:CGPointMake(self.index * self.scrollView.frame.size.width, 0) animated:YES];
            
            if (self.index == 1) {
                [self performSelector:@selector(getHomework) withObject:nil afterDelay:0.3];
            } else if (self.index == 2) {
                [self performSelector:@selector(getDiscuss) withObject:nil afterDelay:0.3];
            }
        }
        
    } else {
        
        if (self.index == 2 || self.index == 1) {
            
            self.index--;
            [self.barView gotoIndex:self.index];
            
            [self.scrollView setContentOffset:CGPointMake(self.index * self.scrollView.frame.size.width, 0) animated:YES];
            
            if (self.index == 1) {
                [self performSelector:@selector(getHomework) withObject:nil afterDelay:0.3];
            } else if (self.index == 2) {
                [self performSelector:@selector(getDiscuss) withObject:nil afterDelay:0.3];
            }
        }
    }
}


@end









