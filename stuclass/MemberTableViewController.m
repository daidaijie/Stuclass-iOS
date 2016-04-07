//
//  MemberTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 4/6/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "MemberTableViewController.h"
#import "MemberTableViewCell.h"
#import "Define.h"

@interface MemberTableViewController () <UISearchDisplayDelegate, UISearchBarDelegate>

@property (strong, nonatomic) NSArray *imageArray;

@property (strong, nonatomic) UISearchDisplayController *searchDisplayController;

@property (strong, nonatomic) NSMutableArray *filterData;

@end

@implementation MemberTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupData];
    [self setupTableView];
}

- (void)setupTableView {

    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    searchBar.translucent = YES;
    searchBar.barStyle = UIBarStyleDefault;
    searchBar.placeholder = @"姓名、学号、专业、性别";
    searchBar.barTintColor = TABLEVIEW_BACKGROUN_COLOR;
    searchBar.backgroundColor = TABLEVIEW_BACKGROUN_COLOR;
    searchBar.tintColor = MAIN_COLOR;
    // remove black line
    [searchBar setBackgroundImage:[[UIImage alloc] init]];
    CGRect rect = searchBar.frame;
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, rect.size.height - 0.5, rect.size.width, 1.3)];
    lineView.backgroundColor = TABLEVIEW_BACKGROUN_COLOR;
    [searchBar addSubview:lineView];
    searchBar.delegate = self;

    _searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    _searchDisplayController.delegate = self;
    _searchDisplayController.searchResultsDelegate = self;
    _searchDisplayController.searchResultsDataSource = self;
    _searchDisplayController.searchResultsTableView.rowHeight = 70;
    _searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] init];

    [self.tableView setTableHeaderView:searchBar];
}

- (void)setupData
{
    _imageArray = @[[UIImage imageNamed:@"male"], [UIImage imageNamed:@"female"]];
    self.title = [NSString stringWithFormat:@"同班同学(%@)", _classInfo[@"stuNum"]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        NSArray *students = _classInfo[@"student"];
        return students.count;
    } else {
        return _filterData.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;

    MemberTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MemberCell"];

    NSArray *students = _classInfo[@"student"];

    if (tableView == self.tableView) {
        cell.nameLabel.text = students[row][@"name"];
        cell.numberLabel.text = students[row][@"number"];
        cell.majorLabel.text = students[row][@"major"];
        cell.genderImageView.image = [students[row][@"gender"] isEqualToString:@"男"] ? _imageArray[0] : _imageArray[1];
    } else {
        cell.nameLabel.text = _filterData[row][@"name"];
        cell.numberLabel.text = _filterData[row][@"number"];
        cell.majorLabel.text = _filterData[row][@"major"];
        cell.genderImageView.image = [_filterData[row][@"gender"] isEqualToString:@"男"] ? _imageArray[0] : _imageArray[1];
    }

    return cell;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name contains [cd] %@) OR (number contains [cd] %@) OR (major contains [cd] %@) OR (gender contains [cd] %@) ", searchText, searchText, searchText, searchText];
    _filterData = [NSMutableArray array];

    NSArray *list = _classInfo[@"student"];
    [_filterData addObjectsFromArray:[list filteredArrayUsingPredicate:predicate]];
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}


- (IBAction)searchButtonPress:(id)sender
{
    [_searchDisplayController setActive:YES animated:YES];
    [_searchDisplayController.searchBar becomeFirstResponder];
}

// 进入搜索
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    NSLog(@"进入搜索模式");
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    self.navigationController.view.backgroundColor = TABLEVIEW_BACKGROUN_COLOR;
}


// 退出搜索
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    NSLog(@"退出搜索模式");
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}


// 解决iOS7搜索栏点的太快而消失的Bug
- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        [self.tableView insertSubview:self.searchDisplayController.searchBar aboveSubview:self.tableView];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end





