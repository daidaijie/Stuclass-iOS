//
//  DocumentSearchTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 5/14/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "DocumentSearchTableViewController.h"
#import "Define.h"

@interface DocumentSearchTableViewController ()
@property (strong, nonatomic) UISearchBar *searchBar;
@end

@implementation DocumentSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBackBarButton];
    [self setupTableView];
    [self setupSearchBar];
}

#pragma mark - setup
- (void)setupBackBarButton
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
}


- (void)setupSearchBar
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(40, 0, self.view.bounds.size.width - 52, 44)];
    
    self.searchBar.placeholder = @"搜索";
    self.searchBar.text = @"";
//    self.searchBar.tintColor = [UIColor whiteColor];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    
    
//    self.searchBar.delegate = self;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.searchBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.searchBar becomeFirstResponder];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}


- (void)setupTableView
{
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
