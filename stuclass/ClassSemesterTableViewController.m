//
//  ClassSemesterTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 11/25/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "ClassSemesterTableViewController.h"
#import <KVNProgress/KVNProgress.h>
#import <AFNetworking/AFNetworking.h>
#import "Define.h"
#import "CoreDataManager.h"
#import "ClassParser.h"


static NSString *login_url = @"/syllabus";


@interface ClassSemesterTableViewController ()

@property (strong, nonatomic) NSMutableArray *semesterData;

@property (assign, nonatomic) NSInteger selectedYear;
@property (assign, nonatomic) NSInteger selectedSemester;

@end

@implementation ClassSemesterTableViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupData];
    
    [self setupTableView];
}

#pragma mark - Setup Method

- (void)setupSelectedYear:(NSInteger)year semester:(NSInteger)semester
{
    _selectedYear = year;
    _selectedSemester = semester;
}

- (void)setupData
{
    // 获得年份
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSInteger year = [dateComponent year];
    
    _semesterData = [NSMutableArray array];
    
    for (NSInteger i = 0; i < 4; i++) {
        [_semesterData addObject:[NSNumber numberWithInteger:year - i]];
    }
    
    // ud
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *dict = [ud valueForKey:@"YEAR_AND_SEMESTER"];
    
    NSInteger ud_year = [dict[@"year"] integerValue];
    NSInteger ud_semester = [dict[@"semester"] integerValue];
    
    [self setupSelectedYear:ud_year semester:ud_semester];
}


- (void)setupTableView
{
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.contentInset = UIEdgeInsetsMake(-10, 0, 0, 0);
}



#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _semesterData.count * 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    static NSString *cell_id = @"ClassSemesterCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    
    NSInteger year = [_semesterData[row / 3] integerValue];
    NSInteger semester = indexPath.row % 3 + 1;
    
    // AccessoryType
    if (_selectedYear == year && _selectedSemester == semester) {
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Content
    NSString *semesterStr = @"";
    
    switch (row % 3) {
        case 0:
            semesterStr = @"秋季学期";
            break;
        case 1:
            semesterStr = @"春季学期";
            break;
        case 2:
            semesterStr = @"夏季学期";
            break;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d-%d  %@", year, year + 1, semesterStr];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger year = [_semesterData[indexPath.row / 3] integerValue];
    NSInteger semester = indexPath.row % 3 + 1;
    
    _selectedYear = year;
    _selectedSemester = semester;
    
    [tableView reloadData];
    
//    [_semesterDelegate semesterTableViewControllerDidSelectYear:year semester:semester];
}



- (IBAction)confirmPress:(id)sender
{
    [self confirm];
}

#pragma mark - Confirm

- (void)confirm
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *dict = [ud valueForKey:@"YEAR_AND_SEMESTER"];
    
    NSInteger ud_year = [dict[@"year"] integerValue];
    NSInteger ud_semester = [dict[@"semester"] integerValue];
    
    if (ud_year == _selectedYear && ud_semester == _selectedSemester) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        
        // KVN
        [KVNProgress showWithStatus:@"正在获取该学期课表"];
        
        // ActivityIndicator
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        // Request
        [self sendRequest];
    }
}

- (void)sendRequest
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSString *username = [ud valueForKey:@"USERNAME"];
    NSString *password = [ud valueForKey:@"PASSWORD"];
    
    // post data
    NSDictionary *postData = @{
                               @"username": username,
                               @"password": password,
                               @"years": [NSString stringWithFormat:@"%d-%d", _selectedYear, _selectedYear + 1],
                               @"semester": [NSString stringWithFormat:@"%d", _selectedSemester],
                               @"submit": @"query",
                               };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", global_host, login_url] parameters:postData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
//        NSLog(@"连接服务器 - 成功 - %@", responseObject);
        NSLog(@"连接服务器 - 成功");
        [self parseResponseObject:responseObject withYear:_selectedYear semester:_selectedSemester];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSLog(@"连接服务器 - 失败 - %@", error);
        [KVNProgress showErrorWithStatus:global_connection_failed];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
}

- (void)parseResponseObject:(id)responseObject withYear:(NSInteger)year semester:(NSInteger)semester
{
    if ([responseObject objectForKey:@"ERROR"]) {
        // 错误
        
        if ([responseObject[@"ERROR"] isEqualToString:@"the password is wrong"] || [responseObject[@"ERROR"] isEqualToString:@"account not exist or not allowed"]) {
            // 用户或密码错误  登出
            [_delegate semesterDelegateLogout];
            [self dismissViewControllerAnimated:NO completion:nil];
            [KVNProgress showErrorWithStatus:global_connection_wrong_user_password];
            
        } else if ([responseObject[@"ERROR"] isEqualToString:@"credit system broken"]) {
            // 学分制崩溃了
            [KVNProgress showErrorWithStatus:global_connection_credit_broken];
        } else if ([responseObject[@"ERROR"] isEqualToString:@"No classes"]) {
            // 没有这个课表
            [KVNProgress showErrorWithStatus:@"暂时没有该课表信息"];
        } else {
            // 其他异常情况
            NSLog(@"发生未知错误");
            [KVNProgress showErrorWithStatus:global_connection_failed];
        }
    } else {
        // 成功
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        
        // 设置学期
        [ud setValue:@{@"year":[NSNumber numberWithInteger:year], @"semester":[NSNumber numberWithInteger:semester]} forKey:@"YEAR_AND_SEMESTER"];
        
        // 得到原始数据
        NSMutableArray *originData = [NSMutableArray arrayWithArray:responseObject[@"classes"]];
        
        // 添加class_id
        NSArray *classData = [[ClassParser sharedInstance] generateClassIDForOriginalData:originData withYear:year semester:semester];
        
        // 写入本地CoreData
        [[CoreDataManager sharedInstance] writeClassTableToCoreDataWithClassesArray:classData withYear:year semester:semester username:[ud valueForKey:@"USERNAME"]];
        
        // 生成DisplayData
        NSArray *boxData = [[ClassParser sharedInstance] parseClassData:classData];
        
        // token
        NSString *token = responseObject[@"token"];
        [ud setValue:token forKey:@"USER_TOKEN"];
        
        // nickname
        NSString *nickname = responseObject[@"nickname"];
        [ud setValue:nickname forKey:@"NICKNAME"];
        
        [_delegate semesterDelegateSemesterChanged:boxData semester:_selectedSemester];
        
        [KVNProgress showSuccessWithStatus:@"获取该学期课表成功" completion:^{
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}



- (void)logoutClearData
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    // ud
    [ud setValue:nil forKey:@"USER_TOKEN"];
    [ud setValue:nil forKey:@"YEAR_AND_SEMESTER"];
    [ud setValue:nil forKey:@"NICKNAME"];
}



- (IBAction)cancelPress:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
























