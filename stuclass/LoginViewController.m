//
//  LoginViewController.m
//  stuclass
//
//  Created by JunhaoWang on 10/9/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "LoginViewController.h"
#import "ClassViewController.h"
#import "InputTextField.h"
#import "InputView.h"
#import <KVNProgress/KVNProgress.h>
#import <AFNetworking/AFNetworking.h>
#import "SemesterTableViewController.h"
#import "MBProgressHUD.h"
#import "Define.h"
#import "ClassParser.h"
#import "CoreDataManager.h"

static NSString *login_url = @"http://10.22.27.65/syllabus";

@interface LoginViewController () <UITextFieldDelegate, SemesterDelegate>

@property (weak, nonatomic) IBOutlet InputView *inputView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *semesterButton;

@property (assign, nonatomic) NSInteger year;
@property (assign, nonatomic) NSInteger semester;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initWrapView];
    [self initNavigationBar];
    [self setupView];
    [self setupDefault];
    [self checkIfLogin];
}

#pragma mark - Setup Method

- (void)initWrapView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 60)];
    view.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:view];
}

- (void)initNavigationBar
{
    // navigation
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
}

- (void)setupView
{
    // semesterButton
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"请选择学期"];
    NSRange strRange = {0, str.length};
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [self.semesterButton setAttributedTitle:str forState:UIControlStateNormal];
    
    // loginButton
    self.loginButton.layer.cornerRadius = 5.0;
    
    // inputView
    self.inputView.usernameTextField.tag = 0;
    self.inputView.passwordTextField.tag = 1;
    self.inputView.usernameTextField.delegate = self;
    self.inputView.passwordTextField.delegate = self;
    [self.inputView.usernameTextField addTarget:self action:@selector(returnKeyPress:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.inputView.passwordTextField addTarget:self action:@selector(returnKeyPress:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    // gesture
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gesture];
}

- (void)setupDefault
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    // username & password
    NSString *username = [ud stringForKey:@"USERNAME"];
    NSString *password = [ud stringForKey:@"PASSWORD"];
    self.inputView.usernameTextField.text = username;
    self.inputView.passwordTextField.text = password;
    
    // year & semester
    NSDictionary *defaultYearAndSemester = [ud objectForKey:@"YEAR_AND_SEMESTER"];
    
    if (defaultYearAndSemester) {
        self.year = [defaultYearAndSemester[@"year"] integerValue];
        self.semester = [defaultYearAndSemester[@"semester"] integerValue];
    }
    
    [self updateSemester];
}


#pragma mark - CheckIfLogin
- (void)checkIfLogin
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *defaultYearAndSemester = [ud objectForKey:@"YEAR_AND_SEMESTER"];
    
    if (defaultYearAndSemester) {
        NSLog(@"读取本地数据");
        // 用户已经登录了
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ClassViewController *cvc = [sb instantiateViewControllerWithIdentifier:@"cvc"];
        
        // Get From CoreData
        NSArray *classData = [[CoreDataManager sharedInstance] getClassDataFromCoreDataWithYear:self.year semester:self.semester username:self.inputView.usernameTextField.text];
        
        // Parse to BoxData
        NSArray *boxData = [[ClassParser sharedInstance] parseClassData:classData];;
        
        cvc.boxData = boxData;
        
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController pushViewController:cvc animated:NO];
    }
}

// returnKeyPress
- (void)returnKeyPress:(UITextField *)textField {
    
    if (textField.tag == 0) {
        // username
        [self.inputView.passwordTextField becomeFirstResponder];
    } else {
        // password
        [self hideKeyboard];
        [self login];
    }
}

// hideKeyboard
- (void)hideKeyboard {
    [self resumeView];
    [self.inputView.usernameTextField resignFirstResponder];
    [self.inputView.passwordTextField resignFirstResponder];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    CGPoint p = self.view.center;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    // 针对处理iphone 4 4s屏幕的上移
    if (height == 480.0) {
        // 3.5-inch
        self.view.center = CGPointMake(p.x, height/2-55); // 182
    } else {
        self.view.center = CGPointMake(p.x, height/2-53);
    }
    
    [UIView commitAnimations];
    
    return YES;
}


// 恢复视图
- (void)resumeView
{
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGPoint p = self.view.center;
    
    if (height == 480.0) {
        // 3.5-inch
        self.view.center = CGPointMake(p.x, height/2);
    } else {
        self.view.center = CGPointMake(p.x, height/2);
    }
    
    [UIView commitAnimations];
}


#pragma mark - Event

- (IBAction)loginButtonPress:(id)sender {
    [self hideKeyboard];
    [self login];
}

- (IBAction)semesterPress:(id)sender
{
    [self hideKeyboard];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SemesterTableViewController *stvc = [sb instantiateViewControllerWithIdentifier:@"semesterVC"];
    stvc.semesterDelegate = self;
    [stvc setupSelectedYear:self.year semester:self.semester];
    UINavigationController *nvc = [[UINavigationController alloc] init];
    nvc.viewControllers = @[stvc];
    [self presentViewController:nvc animated:YES completion:nil];
}


#pragma mark - Login

- (void)login {
    
    // locally checking
    NSString *username = self.inputView.usernameTextField.text;
    NSString *password = self.inputView.passwordTextField.text;
    
    if (username.length == 0 || password.length == 0) {
        [self showHUDWithText:@"请输入账号和密码" andHideDelay:1.2];
        return;
    } else if (_year == 0 && _semester == 0) {
//        [self showHUDWithText:@"请选择学期" andHideDelay:1.2];
        [self semesterPress:nil];
        return;
    } else if (password.length < 6) {
        [self showHUDWithText:@"请输入6位或6位以上的密码" andHideDelay:1.2];
        return;
    }
    
    
    // KVN
    [KVNProgress showWithStatus:@"登录中"];
    
    // ActivityIndicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // Request
    [self sendRequest];
}

- (void)sendRequest
{
    // post data
    NSDictionary *postData = @{
                                 @"username": self.inputView.usernameTextField.text,
                                 @"password": self.inputView.passwordTextField.text,
                                 @"years": [NSString stringWithFormat:@"%d-%d", self.year, self.year + 1],
                                 @"semester": [NSString stringWithFormat:@"%d", self.semester],
                                 @"submit": @"query",
                                 
                                 };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager POST:login_url parameters:postData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
//        NSLog(@"连接服务器 - 成功 - %@", responseObject);
        NSLog(@"连接服务器 - 成功");
        [self parseResponseObject:responseObject withYear:self.year semester:self.semester];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSLog(@"连接服务器 - 失败 - %@", error);
        [KVNProgress showErrorWithStatus:@"连接服务器失败\n(请连接校园网)"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
}

- (void)parseResponseObject:(id)responseObject withYear:(NSInteger)year semester:(NSInteger)semester
{
    if ([responseObject objectForKey:@"ERROR"]) {
        // 错误
        
        if ([responseObject[@"ERROR"] isEqualToString:@"the password is wrong"] || [responseObject[@"ERROR"] isEqualToString:@"account not exist or not allowed"]) {
            // 用户或密码错误
            [KVNProgress showErrorWithStatus:@"账号或密码有误"];
        } else if ([responseObject[@"ERROR"] isEqualToString:@"credit system broken"]) {
            // 学分制崩溃了
            [KVNProgress showErrorWithStatus:@"天哪！学分制系统崩溃了！"];
        } else if ([responseObject[@"ERROR"] isEqualToString:@"No classes"]) {
            // 没有这个课表
            [KVNProgress showErrorWithStatus:@"暂时没有该课表信息"];
        } else {
            // 其他异常情况
            [KVNProgress showErrorWithStatus:@"发生未知错误"];
        }
    } else {
        // 成功
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        
        // 设置username & 密码 & 学期
        [ud setValue:self.inputView.usernameTextField.text forKey:@"USERNAME"];
        [ud setValue:self.inputView.passwordTextField.text forKey:@"PASSWORD"];
        [ud setValue:@{@"year":[NSNumber numberWithInteger:year], @"semester":[NSNumber numberWithInteger:semester]} forKey:@"YEAR_AND_SEMESTER"];
        
        // 得到原始数据
        NSMutableArray *originData = [NSMutableArray arrayWithArray:responseObject[@"classes"]];
        
        // 添加class_id
        NSArray *classData = [[ClassParser sharedInstance] generateClassIDForOriginalData:originData withYear:year semester:semester];
        
        // 写入本地CoreData
        [[CoreDataManager sharedInstance] writeClassTableToCoreDataWithClassesArray:classData withYear:year semester:semester username:self.inputView.usernameTextField.text];
        
        // 生成DisplayData
        NSArray *boxData = [[ClassParser sharedInstance] parseClassData:classData];
        
        // token
        NSString *token = responseObject[@"token"];
        [ud setValue:token forKey:@"USER_TOKEN"];
        
        [KVNProgress showSuccessWithStatus:@"登录成功" completion:^{
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ClassViewController *cvc = [sb instantiateViewControllerWithIdentifier:@"cvc"];
            
            cvc.boxData = boxData;
            
            self.navigationController.navigationBarHidden = NO;
            [self.navigationController pushViewController:cvc animated:YES];
        }];
    }
}



#pragma mark - Semester Delegate

- (void)semesterTableViewControllerDidSelectYear:(NSInteger)year semester:(NSInteger)semester
{
    self.year = year;
    self.semester = semester;
    
    [self updateSemester];
}

- (void)updateSemester
{
    if (self.year == 0 && self.semester == 0) {
        
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:@"请选择学期"];
        NSRange strRange = {0, attStr.length};
        [attStr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
        [self.semesterButton setAttributedTitle:attStr forState:UIControlStateNormal];
        
        return;
    }
    
    
    NSString *semesterStr = @"";
    
    switch (self.semester) {
        case 1:
            semesterStr = @"秋季学期";
            break;
        case 2:
            semesterStr = @"春季学期";
            break;
        case 3:
            semesterStr = @"夏季学期";
            break;
        default:
            break;
    }
    
    NSString *str = [NSString stringWithFormat:@"%d-%d %@", self.year, self.year + 1, semesterStr];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:str];
    NSRange strRange = {0, attStr.length};
    [attStr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [self.semesterButton setAttributedTitle:attStr forState:UIControlStateNormal];
}


#pragma mark - HUD

- (void)showHUDWithText:(NSString *)string andHideDelay:(NSTimeInterval)delay {
    
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = string;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:delay];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

















