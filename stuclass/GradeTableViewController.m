//
//  GradeTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 11/22/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "GradeTableViewController.h"
#import "GradeTableViewCell.h"
#import "Grade.h"
#import "ClassParser.h"
#import <KVNProgress/KVNProgress.h>
#import <AFNetworking/AFNetworking.h>
#import "Define.h"
#import "MobClick.h"

static NSString *cell_id = @"GradeTableViewCell";
static NSString *gpa_cell_id = @"GPAGradeTableViewCell";

static const NSInteger kHeightForGPACellRow = 44.0;
static const NSInteger kHeightForCellRow = 56.0;

@interface GradeTableViewController ()

@end

@implementation GradeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTableView];
}

#pragma mark - Setup Method

- (void)setupTableView
{
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.tableView.contentInset = UIEdgeInsetsMake(-6, 0, 0, 0);
    
    UINib *nib = [UINib nibWithNibName:cell_id bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:cell_id];
}

#pragma mark - TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return kHeightForGPACellRow;
    } else {
        return kHeightForCellRow;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_gradeDict[@"semesters"] count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 1 : [_gradeDict[@"semesters"][section - 1][@"grades"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    } else {
        NSString *year = _gradeDict[@"semesters"][section - 1][@"year"];
        NSString *semester = _gradeDict[@"semesters"][section - 1][@"semester"];

        return [NSString stringWithFormat:@"%@ %@", year, semester];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 0 && row == 0) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:gpa_cell_id forIndexPath:indexPath];
        
        cell.textLabel.text = @"GPA（平均绩点）";
        cell.detailTextLabel.text = _gradeDict[@"gpa"];
        
        return cell;
        
    } else {
        
        GradeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id forIndexPath:indexPath];
        
        Grade *grade = _gradeDict[@"semesters"][section - 1][@"grades"][row];
        
        cell.nameLabel.text = grade.name;
        cell.gradeLabel.text = grade.grade;
        cell.creditLabel.text = grade.credit;
        
        return cell;
    }
}

#pragma mark - Event
- (IBAction)syncItemPress:(id)sender
{
    [self grade];
    [MobClick event:@"More_Grade"];
}


- (void)grade
{
    // KVN
    [KVNProgress showWithStatus:@"正在获取我的成绩"];
    
    // ActivityIndicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // Request
    [self sendGradeRequest];
}

- (void)sendGradeRequest
{
    // ud
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud valueForKey:@"USERNAME"];
    NSString *password = [ud valueForKey:@"PASSWORD"];
    
    // post data
    NSDictionary *postData = @{
                               @"username": username,
                               @"password": password,
                               };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", global_host, grade_url] parameters:postData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
        NSLog(@"连接服务器 - 成功");
        [self parseGradeResponseObject:responseObject];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSLog(@"连接服务器 - 失败 - %@", error);
        [KVNProgress showErrorWithStatus:global_connection_failed];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}


- (void)parseGradeResponseObject:(id)responseObject
{
    if ([responseObject[@"ERROR"] isEqualToString:@"the password is wrong"] || [responseObject[@"ERROR"] isEqualToString:@"account not exist or not allowed"]) {
        // 账号或密码错误
        [KVNProgress showErrorWithStatus:global_connection_wrong_user_password];
        
        [self performSelector:@selector(logout) withObject:nil afterDelay:0.3];
        
    } else if ([responseObject[@"ERROR"] isEqualToString:@"credit system broken"]) {
        // 学分制崩溃了
        [KVNProgress showErrorWithStatus:global_connection_credit_broken];
    } else if ([responseObject[@"ERROR"] isEqualToString:@"there is no information about grade"]) {
        // 没有成绩
        [KVNProgress showErrorWithStatus:@"暂时没有成绩信息"];
    } else {
        // 成功
        
        NSDictionary *gradeData = [[ClassParser sharedInstance] parseGradeData:responseObject];
        
        _gradeDict = gradeData;
        
        [self.tableView reloadData];
        
        [KVNProgress showSuccessWithStatus:@"获取成绩成功" completion:^{
            
            [self.tableView setContentOffset:CGPointMake(0, -58) animated:YES];
        }];
    }
}


- (void)logout
{
    [self logoutClearData];
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (void)logoutClearData
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    // ud
    [ud setValue:nil forKey:@"USER_TOKEN"];
    [ud setValue:nil forKey:@"YEAR_AND_SEMESTER"];
    [ud setValue:nil forKey:@"NICKNAME"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end












