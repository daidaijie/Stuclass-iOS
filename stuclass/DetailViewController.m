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
    _barView = [[BarView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, global_BarViewHeight)];
    [self.view addSubview:_barView];
    
    [_barView.firstButton addTarget:self action:@selector(barButtonPress:) forControlEvents:UIControlEventTouchDown];
    [_barView.secondButton addTarget:self action:@selector(barButtonPress:) forControlEvents:UIControlEventTouchDown];
    [_barView.thirdButton addTarget:self action:@selector(barButtonPress:) forControlEvents:UIControlEventTouchDown];
}


- (void)setupScrollView
{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _barView.frame.origin.y + global_BarViewHeight, self.view.frame.size.width, self.view.frame.size.height - global_BarViewHeight - 64)];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.scrollEnabled = NO;
    _scrollView.bounces = NO;
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * 3, _scrollView.frame.size.height);
    [self.view addSubview:_scrollView];
}

- (void)setupGesture
{
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    
    rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:rightSwipeRecognizer];
    
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    
    leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [_scrollView addGestureRecognizer:leftSwipeRecognizer];
}


- (void)setupViewController
{
    CGFloat width = _scrollView.frame.size.width;
    CGFloat height = _scrollView.frame.size.height;
    
    _pvc = [[PersonViewController alloc] init];
    _pvc.dvc = self;
    [self addChildViewController:_pvc];
    _pvc.view.frame = CGRectMake(0, 0, width, height);
    [_scrollView addSubview:_pvc.view];
    
    _hvc = [[HomeworkViewController alloc] init];
    _hvc.dvc = self;
    [self addChildViewController:_hvc];
    _hvc.view.frame = CGRectMake(width, 0, width, height);
    [_scrollView addSubview:_hvc.view];
    
    _dvc = [[DiscussViewController alloc] init];
    _dvc.dvc = self;
    [self addChildViewController:_dvc];
    _dvc.view.frame = CGRectMake(width * 2, 0, width, height);
    [_scrollView addSubview:_dvc.view];
}



#pragma mark - Event Method

- (void)barButtonPress:(UIButton *)sender
{
    NSInteger tag = sender.tag;
    
    if (_index != tag) {
        
        _index = tag;
        
        [_barView gotoIndex:tag];
        
        [_scrollView setContentOffset:CGPointMake(tag * _scrollView.frame.size.width, 0) animated:YES];
        
        if (_index == 1) {
            [self performSelector:@selector(getHomework) withObject:nil afterDelay:0.3];
        } else if (_index == 2) {
            [self performSelector:@selector(getDiscuss) withObject:nil afterDelay:0.3];
        }
    }
    
    [self updateScrollsToTop];
}

- (void)getHomework
{
    [_hvc getHomeworkData];
}

- (void)getDiscuss
{
    [_dvc getDiscussData];
}


#pragma mark - Gesture

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)sender
{
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        
        if (_index == 0 || _index == 1) {
            
            _index++;
            [_barView gotoIndex:_index];
            
            [_scrollView setContentOffset:CGPointMake(_index * _scrollView.frame.size.width, 0) animated:YES];
            
            if (_index == 1) {
                [self performSelector:@selector(getHomework) withObject:nil afterDelay:0.3];
            } else if (_index == 2) {
                [self performSelector:@selector(getDiscuss) withObject:nil afterDelay:0.3];
            }
        }
        
    } else {
        
        if (_index == 2 || _index == 1) {
            
            _index--;
            [_barView gotoIndex:_index];
            
            [_scrollView setContentOffset:CGPointMake(_index * _scrollView.frame.size.width, 0) animated:YES];
            
            if (_index == 1) {
                [self performSelector:@selector(getHomework) withObject:nil afterDelay:0.3];
            } else if (_index == 2) {
                [self performSelector:@selector(getDiscuss) withObject:nil afterDelay:0.3];
            }
        }
    }
    
    [self updateScrollsToTop];
}


#pragma mark - StatusBar ScrollsToTop

- (void)updateScrollsToTop
{
    if (_index == 0) {
        _pvc.tableView.scrollsToTop = YES;
        _hvc.tableView.scrollsToTop = NO;
        _dvc.tableView.scrollsToTop = NO;
    } else if (_index == 1) {
        _pvc.tableView.scrollsToTop = NO;
        _hvc.tableView.scrollsToTop = YES;
        _dvc.tableView.scrollsToTop = NO;
    } else if (_index == 2) {
        _pvc.tableView.scrollsToTop = NO;
        _hvc.tableView.scrollsToTop = NO;
        _dvc.tableView.scrollsToTop = YES;
    }
}



@end









