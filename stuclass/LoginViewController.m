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
#import "MobClick.h"


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
    
    [self setupExclusiveTouch];
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

- (void)setupExclusiveTouch
{
    self.navigationController.navigationBar.exclusiveTouch = YES;
    for (UIView *view in self.navigationController.navigationBar.subviews) {
        [view setExclusiveTouch:YES];
    }
}

- (void)setupView
{
    // semesterButton
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"请选择学期"];
    NSRange strRange = {0, str.length};
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [_semesterButton setAttributedTitle:str forState:UIControlStateNormal];
    
    // loginButton
    _loginButton.layer.cornerRadius = 5.0;
    
    // inputView
    _inputView.usernameTextField.tag = 0;
    _inputView.passwordTextField.tag = 1;
    _inputView.usernameTextField.delegate = self;
    _inputView.passwordTextField.delegate = self;
    [_inputView.usernameTextField addTarget:self action:@selector(returnKeyPress:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [_inputView.passwordTextField addTarget:self action:@selector(returnKeyPress:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
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
    _inputView.usernameTextField.text = username;
    _inputView.passwordTextField.text = password;
    
    // year & semester
    NSDictionary *defaultYearAndSemester = [ud objectForKey:@"YEAR_AND_SEMESTER"];
    
    if (defaultYearAndSemester) {
        _year = [defaultYearAndSemester[@"year"] integerValue];
        _semester = [defaultYearAndSemester[@"semester"] integerValue];
    }
    
    [self updateSemester];
}


#pragma mark - CheckIfLogin
- (void)checkIfLogin
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *defaultYearAndSemester = [ud objectForKey:@"YEAR_AND_SEMESTER"];
    NSString *user_id = [ud objectForKey:@"USER_ID"];
    
    if (defaultYearAndSemester && user_id) {
        NSLog(@"读取本地数据");
        // 用户已经登录了
        
        // Get From CoreData
        NSArray *classData = [[CoreDataManager sharedInstance] getClassDataFromCoreDataWithYear:_year semester:_semester username:_inputView.usernameTextField.text];
        
        // Parse to BoxData
        NSArray *boxData = [[ClassParser sharedInstance] parseClassData:classData];;
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        UITabBarController *tbc = [sb instantiateViewControllerWithIdentifier:@"tbc"];
        
        UINavigationController *nvc = tbc.viewControllers[0];
        ClassViewController *cvc = nvc.viewControllers[0];
        
        cvc.boxData = boxData;
        
        [self.navigationController pushViewController:tbc animated:NO];
    }
}

// returnKeyPress
- (void)returnKeyPress:(UITextField *)textField {
    
    if (textField.tag == 0) {
        // username
        [_inputView.passwordTextField becomeFirstResponder];
    } else {
        // password
        [self hideKeyboard];
        [self login];
    }
}

// hideKeyboard
- (void)hideKeyboard {
    [self resumeView];
    [_inputView.usernameTextField resignFirstResponder];
    [_inputView.passwordTextField resignFirstResponder];
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
    [stvc setupSelectedYear:_year semester:_semester];
    UINavigationController *nvc = [[UINavigationController alloc] init];
    nvc.viewControllers = @[stvc];
    
    [self presentViewController:nvc animated:YES completion:nil];
}


#pragma mark - Login

- (void)login {
    
    // locally checking
    NSString *username = _inputView.usernameTextField.text;
    NSString *password = _inputView.passwordTextField.text;
    
    if (username.length == 0 || password.length == 0) {
        [self showHUDWithText:@"请输入账号和密码" andHideDelay:global_hud_delay];
        return;
    } else if (_year == 0 && _semester == 0) {
//        [self showHUDWithText:@"请选择学期" andHideDelay:global_hud_delay];
        [self semesterPress:nil];
        return;
    }
    
    
    // KVN
    [KVNProgress showWithStatus:@"正在登录"];
    
    // ActivityIndicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // Request
    [self sendRequest];
}

- (void)sendRequest
{
    // post data
    NSDictionary *postData = @{
                                 @"username": _inputView.usernameTextField.text,
                                 @"password": _inputView.passwordTextField.text,
                                 @"years": [NSString stringWithFormat:@"%d-%d", _year, _year + 1],
                                 @"semester": [NSString stringWithFormat:@"%d", _semester],
                                 @"submit": @"query",
                                 
                                 };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", global_host, login_url] parameters:postData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
        NSLog(@"连接服务器 - 成功 - %@", responseObject);
        NSLog(@"连接服务器 - 成功");
        [self parseResponseObject:responseObject withYear:_year semester:_semester];
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
            // 用户或密码错误
            [KVNProgress showErrorWithStatus:@"账号或密码有误"];
        } else if ([responseObject[@"ERROR"] isEqualToString:@"credit system broken"]) {
            // 学分制崩溃了
            [KVNProgress showErrorWithStatus:global_connection_credit_broken];
        } else if ([responseObject[@"ERROR"] isEqualToString:@"the user can't access credit system"]) {
            // 医学院通道
            NSLog(@"医学院通道");
            // 成功
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            
            // 设置username & 密码 & 学期
            [ud setValue:_inputView.usernameTextField.text forKey:@"USERNAME"];
            [ud setValue:_inputView.passwordTextField.text forKey:@"PASSWORD"];
            [ud setValue:@{@"year":[NSNumber numberWithInteger:year], @"semester":[NSNumber numberWithInteger:semester]} forKey:@"YEAR_AND_SEMESTER"];
            
            NSArray *classData;
            
            if ([[CoreDataManager sharedInstance] isClassTableExistedWithYear:year semester:semester username:_inputView.usernameTextField.text]) {
                // 存在本地数据
                NSLog(@"登录获取课表 - 本地存在");
                classData = [[CoreDataManager sharedInstance] getClassDataFromCoreDataWithYear:year semester:semester username:_inputView.usernameTextField.text];
            } else {
                // 不存在
                // 得到原始数据
                NSLog(@"登录获取课表 - 本地不存在");
                NSMutableArray *originData = [NSMutableArray arrayWithArray:responseObject[@"classes"]];
                
                // 添加class_id
                classData = [[ClassParser sharedInstance] generateClassIDForOriginalData:originData withYear:year semester:semester];
                
                // 写入本地CoreData
                [[CoreDataManager sharedInstance] writeSyncClassTableToCoreDataWithClassesArray:classData withYear:year semester:semester username:_inputView.usernameTextField.text];
            }
            
            // 生成DisplayData
            classData = [[CoreDataManager sharedInstance] getClassDataFromCoreDataWithYear:year semester:semester username:_inputView.usernameTextField.text];
            NSArray *boxData = [[ClassParser sharedInstance] parseClassData:classData];
            
            // token
            NSString *token = responseObject[@"token"];
            [ud setValue:token forKey:@"USER_TOKEN"];
            
            // nickname
            NSString *nickname = responseObject[@"nickname"];
            [ud setValue:nickname forKey:@"NICKNAME"];
            
            // avatar
            NSString *avatarURL = responseObject[@"avatar"];
            if ([avatarURL isEqual:[NSNull null]]) {
                NSLog(@"avatarURL - NULL");
                [ud setValue:nil forKey:@"AVATAR_URL"];
            } else {
                NSLog(@"avatarURL - %@", avatarURL);
                [ud setValue:avatarURL forKey:@"AVATAR_URL"];
            }
            
            // user_id
            NSString *user_id = responseObject[@"user_id"];
            NSLog(@"user_id - %@", user_id);
            [ud setValue:user_id forKey:@"USER_ID"];
            
            [KVNProgress showSuccessWithStatus:@"登录成功" completion:^{
                [MobClick event:@"Login_Login" attributes:@{@"Username": _inputView.usernameTextField.text}];
                
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                
                UITabBarController *tbc = [sb instantiateViewControllerWithIdentifier:@"tbc"];
                UINavigationController *nvc = tbc.viewControllers[0];
                ClassViewController *cvc = nvc.viewControllers[0];
                
                cvc.boxData = boxData;
                
                [self.navigationController pushViewController:tbc animated:YES];
            }];
        } else {
            // 其他异常情况
            NSLog(@"发生未知错误");
            [KVNProgress showErrorWithStatus:global_connection_failed];
        }
    } else {
        // 成功
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        
        // 设置username & 密码 & 学期
        [ud setValue:_inputView.usernameTextField.text forKey:@"USERNAME"];
        [ud setValue:_inputView.passwordTextField.text forKey:@"PASSWORD"];
        [ud setValue:@{@"year":[NSNumber numberWithInteger:year], @"semester":[NSNumber numberWithInteger:semester]} forKey:@"YEAR_AND_SEMESTER"];
        
        NSArray *classData;
        
        if ([[CoreDataManager sharedInstance] isClassTableExistedWithYear:year semester:semester username:_inputView.usernameTextField.text]) {
            // 存在本地数据
            NSLog(@"登录获取课表 - 本地存在");
            classData = [[CoreDataManager sharedInstance] getClassDataFromCoreDataWithYear:year semester:semester username:_inputView.usernameTextField.text];
        } else {
            // 不存在
            // 得到原始数据
            NSLog(@"登录获取课表 - 本地不存在");
            NSMutableArray *originData = [NSMutableArray arrayWithArray:responseObject[@"classes"]];
            
            // 添加class_id
            classData = [[ClassParser sharedInstance] generateClassIDForOriginalData:originData withYear:year semester:semester];
            
            // 写入本地CoreData
            [[CoreDataManager sharedInstance] writeSyncClassTableToCoreDataWithClassesArray:classData withYear:year semester:semester username:_inputView.usernameTextField.text];
        }
        
        // 生成DisplayData
        classData = [[CoreDataManager sharedInstance] getClassDataFromCoreDataWithYear:year semester:semester username:_inputView.usernameTextField.text];
        NSArray *boxData = [[ClassParser sharedInstance] parseClassData:classData];
        
        // token
        NSString *token = responseObject[@"token"];
        [ud setValue:token forKey:@"USER_TOKEN"];
        
        // nickname
        NSString *nickname = responseObject[@"nickname"];
        [ud setValue:nickname forKey:@"NICKNAME"];
        
        // avatar
        NSString *avatarURL = responseObject[@"avatar"];
        if ([avatarURL isEqual:[NSNull null]]) {
            NSLog(@"avatarURL - NULL");
            [ud setValue:nil forKey:@"AVATAR_URL"];
        } else {
            NSLog(@"avatarURL - %@", avatarURL);
            [ud setValue:avatarURL forKey:@"AVATAR_URL"];
        }
        
        // user_id
        NSString *user_id = responseObject[@"user_id"];
        NSLog(@"user_id - %@", user_id);
        [ud setValue:user_id forKey:@"USER_ID"];
        
        [KVNProgress showSuccessWithStatus:@"登录成功" completion:^{
            [MobClick event:@"Login_Login" attributes:@{@"Username": _inputView.usernameTextField.text}];
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            UITabBarController *tbc = [sb instantiateViewControllerWithIdentifier:@"tbc"];
            UINavigationController *nvc = tbc.viewControllers[0];
            ClassViewController *cvc = nvc.viewControllers[0];
            
            cvc.boxData = boxData;
            
            [self.navigationController pushViewController:tbc animated:YES];
        }];
    }
}



#pragma mark - Semester Delegate

- (void)semesterTableViewControllerDidSelectYear:(NSInteger)year semester:(NSInteger)semester
{
    _year = year;
    _semester = semester;
    
    [self updateSemester];
}

- (void)updateSemester
{
    if (_year == 0 && _semester == 0) {
        
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:@"请选择学期"];
        NSRange strRange = {0, attStr.length};
        [attStr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
        [_semesterButton setAttributedTitle:attStr forState:UIControlStateNormal];
        
        return;
    }
    
    
    NSString *semesterStr = @"";
    
    switch (_semester) {
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
    
    NSString *str = [NSString stringWithFormat:@"%d-%d %@", _year, _year + 1, semesterStr];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:str];
    NSRange strRange = {0, attStr.length};
    [attStr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [_semesterButton setAttributedTitle:attStr forState:UIControlStateNormal];
}


#pragma mark - HUD

- (void)showHUDWithText:(NSString *)string andHideDelay:(NSTimeInterval)delay {
    
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    
    if (self.navigationController.view) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = string;
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:delay];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

















