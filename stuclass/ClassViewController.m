//
//  ClassViewController.m
//  stuclass
//
//  Created by JunhaoWang on 10/10/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "ClassViewController.h"
#import "ClassHeaderView.h"
#import "ClassCollectionViewCell.h"
#import "ClassCollectionViewLayout.h"
#import "ClassNumberCollectionReusableView.h"
#import "Define.h"
#import <KVNProgress/KVNProgress.h>
#import "ClassParser.h"
#import "CoreDataManager.h"
#import "DetailViewController.h"
#import "ClassBox.h"
#import <AFNetworking/AFNetworking.h>
#import "DXPopover.h"
#import "MoreView.h"
#import "GradeTableViewController.h"
#import "ExamTableViewController.h"
#import "ClassSemesterButton.h"
#import "ClassSemesterTableViewController.h"
#import "DocumentTableViewController.h"
#import "MobClick.h"
#import "JHDater.h"
#import "ClassWeekTableViewController.h"
#import "MBProgressHUD.h"
#import "BackgoundTableViewController.h"


static const CGFloat kAnimationDurationForSemesterButton = 0.3;

@interface ClassViewController () <UICollectionViewDelegate, UICollectionViewDataSource, ClassCollectionViewLayoutDelegate, ClassCollectionViewCellDelegate, ClassSemesterDelegate, UIScrollViewDelegate, ClassWeekDelegate>

@property (strong, nonatomic) ClassHeaderView *classHeaderView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIImageView *bgImageView;
@property (strong, nonatomic) ClassSemesterButton *semesterButton;

@property (strong, nonatomic) MoreView *moreView;

@property (strong, nonatomic) DXPopover *popover;

@property (assign, nonatomic) BOOL isSemesterButtonHidden;

@property (weak, nonatomic) IBOutlet UIButton *weekButton;

@property (nonatomic) NSInteger currentWeek;

@end

@implementation ClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Bar
    [self setupBarBackButton];
    [self initNavigationBar];
    [self setupItems];
    
    // View
    [self initBgImageView];
    [self initPopover];
    [self initMoreView];
    [self initWeekView];
    [self initClassHeaderView];
    [self initCollectionView];
    [self initSemesterButton];
    
    // Notification
    [self initNotification];
    
    // Show Annoucement
    [self showAnnoucement];
}

#pragma mark - View Delegate
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 更新顶部日期
    [_classHeaderView updateCurrentDateOnClassHeaderView];
    
    // Week
    BOOL hasChanged = [self getCurrentWeek];
    
    if (hasChanged) {
        [_weekButton setTitle:[NSString stringWithFormat:@"第 %d 周", _currentWeek] forState:UIControlStateNormal];
        [self.collectionView reloadData];
    }
}


#pragma mark - Initialize Method


// Bar
- (void)setupBarBackButton
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
}

- (void)initNavigationBar
{
    // navigation
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
}

- (void)setupItems
{
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar-more"] style:UIBarButtonItemStylePlain target:self action:@selector(moreItemPress)];
    
//    UIBarButtonItem *publicItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-public"] style:UIBarButtonItemStylePlain target:self action:@selector(publicItemPress)];
    
    UIBarButtonItem *backgroundItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar-background"] style:UIBarButtonItemStylePlain target:self action:@selector(backgroundButtonPress)];
    
    self.navigationItem.leftBarButtonItem = backgroundItem;
    self.navigationItem.rightBarButtonItems = @[moreItem];
}


// View
- (void)initBgImageView
{
    _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64 - 49)];
    
    _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    // 读取背景图片
    BOOL isBgImageExisted = NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 获取存储目录
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imageFilePath = [documentsDirectory stringByAppendingString:@"/class_bg_user.jpg"];
    // 检测是否已存在
    isBgImageExisted = [fileManager fileExistsAtPath:imageFilePath];
    
    if (isBgImageExisted) {
        // 设置自定义背景图
        _bgImageView.image = [UIImage imageWithContentsOfFile:imageFilePath];
    } else {
        // 设置自带背景图
        NSInteger bgSection = [[NSUserDefaults standardUserDefaults] integerForKey:@"bgSection"];
        NSInteger bgIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"bgIndex"];
        UIImage *bgImage = [UIImage imageNamed:[NSString stringWithFormat:@"class_bg_%d_%d.jpg", bgSection, bgIndex]];
        _bgImageView.image = bgImage ? bgImage : [UIImage imageNamed:@"class_bg_0_0.jpg"];
    }
    
    [self.view addSubview:_bgImageView];
}

- (void)initPopover
{
    _popover = [DXPopover popover];
}

- (void)initMoreView
{
    _moreView = [[MoreView alloc] initWithItems:@[@"同步课表", @"考试信息", @"我的成绩", @"办公自动化", @"登录校内网"] images:@[[UIImage imageNamed:@"more-sync"], [UIImage imageNamed:@"more-exam"], [UIImage imageNamed:@"more-grade"], [UIImage imageNamed:@"more-oa"], [UIImage imageNamed:@"more-login"]]];
    
    UIButton *syncBtn = _moreView.itemsArray[0];
    [syncBtn addTarget:self action:@selector(moreSyncPress) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *examBtn = _moreView.itemsArray[1];
    [examBtn addTarget:self action:@selector(moreExamPress) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *gradeBtn = _moreView.itemsArray[2];
    [gradeBtn addTarget:self action:@selector(moreGradePress) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *oaBtn = _moreView.itemsArray[3];
    [oaBtn addTarget:self action:@selector(moreOaPress) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *loginBtn = _moreView.itemsArray[4];
    [loginBtn addTarget:self action:@selector(moreLoginPress) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initWeekView
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    _currentWeek = [[ud objectForKey:@"WEEK_DATA"][@"week"] integerValue];
    [_weekButton setTitle:[NSString stringWithFormat:@"第 %d 周", _currentWeek] forState:UIControlStateNormal];
}

- (void)initClassHeaderView
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat k = width / 320.0;
    _classHeaderView = [[ClassHeaderView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 32.0f * k)];
    
    [self.view addSubview:_classHeaderView];
}

- (void)initCollectionView
{
    _collectionView.exclusiveTouch = YES;
    
    // layout
    ClassCollectionViewLayout *layout = [[ClassCollectionViewLayout alloc] init];
    layout.layoutDelegate = self;
    
    // collectionView
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64+_classHeaderView.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - _classHeaderView.bounds.size.height - 64 - 49) collectionViewLayout:layout];
    
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.bounces = NO;
    _collectionView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:_collectionView];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    // register Cell
    [_collectionView registerClass:[ClassCollectionViewCell class] forCellWithReuseIdentifier:@"ClassCell"];
    
    // register SupplementaryView
    [_collectionView registerClass:[ClassNumberCollectionReusableView class] forSupplementaryViewOfKind:@"ClassNumber" withReuseIdentifier:@"ClassSupplementary"];
}


- (void)initSemesterButton
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *dict = [ud valueForKey:@"YEAR_AND_SEMESTER"];
    
    NSInteger semester = [dict[@"semester"] integerValue];
    
    NSString *semesterStr = @"";
    
    switch (semester) {
            
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
    
    
    CGFloat btnWidth = 27;
    CGFloat btnHeight = 88;
    CGFloat yOffset = 176;
    
    _semesterButton = [[ClassSemesterButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - btnWidth, [UIScreen mainScreen].bounds.size.height - yOffset, btnWidth, btnHeight)];
    
    [_semesterButton setTitle:semesterStr forState:UIControlStateNormal];
    
    [_semesterButton addTarget:self action:@selector(semesterButtonPress) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_semesterButton];
}



// Notification
- (void)initNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bgImageChanged) name:@"bgImageChanged" object:nil];
}


#pragma mark - layout delegate
// 返回cell个数
- (NSInteger)collectionView:(UICollectionView *)collectionView cellCountForCollectionViewLayout:(ClassCollectionViewLayout *)collectionViewLayout
{
    return _boxData.count;
}

// 返回坐标给Layout
- (NSArray *)collectionView:(UICollectionView *)collectionView coordinateForCollectionViewLayout:(ClassCollectionViewLayout *)collectionViewLayout indexPath:(NSIndexPath *)indexPath
{
    ClassBox *box = _boxData[indexPath.row];
    return @[[NSNumber numberWithInteger:box.box_x], [NSNumber numberWithInteger:box.box_y], [NSNumber numberWithInteger:box.box_length]];
}



#pragma mark - collectionView delegate

// 设置Cell的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // 看看要画多少个课程cell
    return _boxData.count;
}

// CellView
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ClassCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ClassCell" forIndexPath:indexPath];
    
    return [self configureClassCell:cell atIndex:indexPath.row];
}

// 设置cell
- (UICollectionViewCell *)configureClassCell:(ClassCollectionViewCell *)cell atIndex:(NSInteger)row
{
    ClassBox *box = _boxData[row];
    
    if (box) {
        // 在周数区间
        NSInteger startWeek = [box.box_span[0] integerValue];
        NSInteger endWeek = [box.box_span[1] integerValue];
        
        if (_currentWeek >= startWeek && _currentWeek <= endWeek) {
            
            NSInteger flag = 2;
            
            if ([box.box_weekType isEqualToString:@"单"]) {
                flag = 1;
            } else if ([box.box_weekType isEqualToString:@"双"]) {
                flag = 0;
            }
            
            // 判断单双周
            if (box.box_weekType.length == 0 || _currentWeek % 2 == flag) {
                
                // shrinkName
                
                NSString *className = [self shrinkName:box.box_name];
                
                cell.label.text = [NSString stringWithFormat:@"%@@%@%@", className, box.box_room, box.box_weekType.length == 0 ? @"" : [NSString stringWithFormat:@"(%@周)", box.box_weekType]];
                
                [cell setBtnColor:box.box_color];
                
                cell.tag = row;
                cell.delegate = self;
                cell.hidden = NO;
            } else {
                cell.hidden = YES;
            }
        } else {
            cell.hidden = YES;
        }
    }
    
    return cell;
}

- (NSString *)shrinkName:(NSString *)name
{
    NSArray *array = [name componentsSeparatedByString:@"]"];
    
    if (array.count < 3) {
        return [array lastObject];
    } else {
        return name;
    }
}


// SupplementaryView
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    ClassNumberCollectionReusableView *classNumView = [collectionView dequeueReusableSupplementaryViewOfKind:@"ClassNumber" withReuseIdentifier:@"ClassSupplementary" forIndexPath:indexPath];
    
    row++;
    
    NSString *numStr = [NSString stringWithFormat:@"%d", row];
    
    if (row == 10) {
        numStr = @"0";
    } else if (row == 11) {
        numStr = @"A";
    } else if (row == 12) {
        numStr = @"B";
    } else if (row == 13) {
        numStr = @"C";
    }
    
    classNumView.numLabel.text = numStr;
    
    return classNumView;
}




#pragma mark - Events

- (void)classCollectionViewCellDidPressWithTag:(NSInteger)tag
{
    NSLog(@"cell - %d", tag);
    
    [self performSegueWithIdentifier:@"ShowDetail" sender:_boxData[tag]];
    
    [MobClick event:@"Main_ShowDetail"];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"ShowDetail"]) {
    
        ClassBox *box = sender;
        
        DetailViewController *dvc = segue.destinationViewController;
        
        dvc.title = [self shrinkName:box.box_name];
        
        dvc.classBox = box;
        
    } else if ([segue.identifier isEqualToString:@"ShowGrade"]) {
        
        GradeTableViewController *gtvc = segue.destinationViewController;
        
        NSDictionary *gradeData = sender;
        
        gtvc.gradeDict = gradeData;
        
    } else if ([segue.identifier isEqualToString:@"ShowExam"]) {
        
        ExamTableViewController *etvc = segue.destinationViewController;
        
        NSMutableArray *examData = sender;
        
        etvc.examData = examData;
        
    } else if ([segue.identifier isEqualToString:@"ShowDocument"]) {
        
        
        DocumentTableViewController *dtvc = segue.destinationViewController;
        
        NSMutableArray *documentData = sender;
        
        dtvc.documentData = documentData;
    }
}

- (void)moreItemPress
{
    [self more];
    [MobClick event:@"More_Selected"];
}


- (void)more
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    _popover = [DXPopover popover];
    [_popover showAtPoint:CGPointMake(width - (width == 414 ? 31 : 28), 67) popoverPostion:DXPopoverPositionDown withContentView:_moreView inView:self.navigationController.view];
}

- (void)moreSyncPress
{
    [self sync];
    [MobClick event:@"More_Sync"];
}

- (void)moreExamPress
{
    [self exam];
    [MobClick event:@"More_Exam"];
}

- (void)moreGradePress
{
    [self grade];
    [MobClick event:@"More_Grade"];
}

- (void)moreOaPress
{
    [self oa];
    [MobClick event:@"More_OA"];
}

- (void)moreLoginPress
{
    [self connect];
    [MobClick event:@"More_Login"];
}

- (void)publicItemPress
{
    [self performSegueWithIdentifier:@"ShowPublic" sender:nil];
}


- (void)backgroundButtonPress
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BackgoundTableViewController *btvc = [sb instantiateViewControllerWithIdentifier:@"btvc"];
//    btvc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] init];
    nvc.viewControllers = @[btvc];
    [self presentViewController:nvc animated:YES completion:nil];
    
    [MobClick event:@"Background_Setting"];
}


- (void)semesterButtonPress
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ClassSemesterTableViewController *cstvc = [sb instantiateViewControllerWithIdentifier:@"classSemesterVC"];
    
    cstvc.delegate = self;
    
    UINavigationController *nvc = [[UINavigationController alloc] init];
    nvc.viewControllers = @[cstvc];
    
    [self presentViewController:nvc animated:YES completion:nil];
    
    [MobClick event:@"Main_Semester"];
}

#pragma mark - ClassSemesterDelegate

- (void)semesterDelegateLogout
{
    [self logoutClearData];
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)semesterDelegateSemesterChanged:(NSArray *)boxData semester:(NSInteger)semester
{
    NSString *semesterStr = @"";
    
    switch (semester) {
            
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
    
    [_semesterButton setTitle:semesterStr forState:UIControlStateNormal];
    
    _boxData = boxData;
    
    [_collectionView reloadData];
    
    [_collectionView setContentOffset:CGPointZero animated:NO];
}

#pragma mark - WeekDelegate

- (IBAction)weekButtonPress:(id)sender
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ClassWeekTableViewController *cwtvc = [sb instantiateViewControllerWithIdentifier:@"ClassWeekTVC"];
    
    cwtvc.delegate = self;
    cwtvc.selectedWeek = _currentWeek;
    
    UINavigationController *nvc = [[UINavigationController alloc] init];
    nvc.viewControllers = @[cwtvc];
    
    [self presentViewController:nvc animated:YES completion:nil];
    
    [MobClick event:@"Main_Week"];
}

- (void)weekDelegateWeekChanged:(NSInteger)week
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDate *date = [NSDate date];
    NSLog(@"更新第一天时间 - %@", date);
    NSDictionary *weekData = @{@"week":[NSNumber numberWithInteger:week], @"date":date};
    [ud setObject:weekData forKey:@"WEEK_DATA"];
}

#pragma mark - SettingDelegate

// Log Out
- (void)settingTableViewControllerLogOut
{
    [self logoutClearData];
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)logoutClearData
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    // ud
    [ud setValue:nil forKey:@"USER_TOKEN"];
    [ud setValue:nil forKey:@"YEAR_AND_SEMESTER"];
    [ud setValue:nil forKey:@"NICKNAME"];
}


- (void)bgImageChanged
{
    // 读取背景图片
    BOOL isBgImageExisted = NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 获取存储目录
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imageFilePath = [documentsDirectory stringByAppendingString:@"/class_bg_user.jpg"];
    // 检测是否已存在
    isBgImageExisted = [fileManager fileExistsAtPath:imageFilePath];
    
    if (isBgImageExisted) {
        // 设置自定义背景图
        _bgImageView.image = [UIImage imageWithContentsOfFile:imageFilePath];
    } else {
        // 设置自带背景图
        NSInteger bgSection = [[NSUserDefaults standardUserDefaults] integerForKey:@"bgSection"];
        NSInteger bgIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"bgIndex"];
        UIImage *bgImage = [UIImage imageNamed:[NSString stringWithFormat:@"class_bg_%d_%d.jpg", bgSection, bgIndex]];
        _bgImageView.image = bgImage ? bgImage : [UIImage imageNamed:@"class_bg_0_0.jpg"];
    }
}


#pragma mark - Sync Class Table

- (void)sync {
    
    // KVN
    [KVNProgress showWithStatus:@"正在获取最新课表信息"];
    
    // ActivityIndicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // Request
    [self sendSyncRequest];
}

- (void)sendSyncRequest
{
    // ud
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud valueForKey:@"USERNAME"];
    NSString *password = [ud valueForKey:@"PASSWORD"];
    NSDictionary *dict = [ud valueForKey:@"YEAR_AND_SEMESTER"];
    NSInteger year = [dict[@"year"] integerValue];
    NSInteger semester = [dict[@"semester"] integerValue];
    
    // post data
    NSDictionary *postData = @{
                               @"username": username,
                               @"password": password,
                               @"years": [NSString stringWithFormat:@"%d-%d", year, year + 1],
                               @"semester": [NSString stringWithFormat:@"%d", semester],
                               @"submit": @"query",
                               
                               };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", global_host, login_url] parameters:postData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
        NSLog(@"连接服务器 - 成功");
        [self parseResponseObject:responseObject withYear:year semester:semester];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSLog(@"连接服务器 - 失败 - %@", error);
        [KVNProgress showErrorWithStatus:global_connection_failed completion:^{
            [_popover dismiss];
        }];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}


- (void)parseResponseObject:(id)responseObject withYear:(NSInteger)year semester:(NSInteger)semester
{
    if ([responseObject[@"ERROR"] isEqualToString:@"the password is wrong"] || [responseObject[@"ERROR"] isEqualToString:@"account not exist or not allowed"]) {
        // 账号或密码错误
        [KVNProgress showErrorWithStatus:global_connection_wrong_user_password completion:^{
            [_popover dismiss];
            [self logoutClearData];
            self.navigationController.navigationBarHidden = YES;
            [self.navigationController popViewControllerAnimated:NO];
        }];
        
    } else if ([responseObject[@"ERROR"] isEqualToString:@"credit system broken"]) {
        // 学分制崩溃了
        [KVNProgress showErrorWithStatus:global_connection_credit_broken completion:^{
            [_popover dismiss];
        }];
    } else {
        // 成功
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *username = [ud valueForKey:@"USERNAME"];
        
        // 得到原始数据
        NSMutableArray *originData = [NSMutableArray arrayWithArray:responseObject[@"classes"]];
        
        // 添加class_id
        NSArray *classData = [[ClassParser sharedInstance] generateClassIDForOriginalData:originData withYear:year semester:semester];
        
        // 写入本地CoreData
        [[CoreDataManager sharedInstance] writeClassTableToCoreDataWithClassesArray:classData withYear:year semester:semester username:username];
        
        // 生成DisplayData
        NSArray *boxData = [[ClassParser sharedInstance] parseClassData:classData];
        
        // token
        NSString *token = responseObject[@"token"];
        [ud setValue:token forKey:@"USER_TOKEN"];
        
        // nickname
        NSString *nickname = responseObject[@"nickname"];
        [ud setValue:nickname forKey:@"NICKNAME"];
        
        _boxData = boxData;
        
        [_collectionView reloadData];
        
        [KVNProgress showSuccessWithStatus:@"同步课表成功" completion:^{
            [_collectionView setContentOffset:CGPointZero animated:YES];
            [_popover dismiss];
        }];
    }
}


#pragma mark - Exam

- (void)exam
{
    // KVN
    [KVNProgress showWithStatus:@"正在获取考试信息"];
    
    // ActivityIndicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // Request
    [self sendExamRequest];
}

- (void)sendExamRequest
{
    // ud
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud valueForKey:@"USERNAME"];
    NSString *password = [ud valueForKey:@"PASSWORD"];
    NSDictionary *dict = [ud valueForKey:@"YEAR_AND_SEMESTER"];
    NSInteger year = [dict[@"year"] integerValue];
    NSInteger semester = [dict[@"semester"] integerValue];
    
    // post data
    NSDictionary *postData = @{
                               @"username": username,
                               @"password": password,
                               @"years": [NSString stringWithFormat:@"%d-%d", year, year + 1],
                               @"semester": [NSString stringWithFormat:@"%d", semester],
                               };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", global_host, exam_url] parameters:postData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
        NSLog(@"连接服务器 - 成功");
        [self parseExamResponseObject:responseObject];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSLog(@"连接服务器 - 失败 - %@", error);
        [KVNProgress showErrorWithStatus:global_connection_failed completion:^{
            [_popover dismiss];
        }];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}


- (void)parseExamResponseObject:(id)responseObject
{
    if ([responseObject[@"ERROR"] isEqualToString:@"the password is wrong"] || [responseObject[@"ERROR"] isEqualToString:@"account not exist or not allowed"]) {
        // 账号或密码错误
        [KVNProgress showErrorWithStatus:global_connection_wrong_user_password completion:^{
            [_popover dismiss];
            [self logoutClearData];
            self.navigationController.navigationBarHidden = YES;
            [self.navigationController popViewControllerAnimated:NO];
        }];
        
    } else if ([responseObject[@"ERROR"] isEqualToString:@"credit system broken"]) {
        // 学分制崩溃了
        [KVNProgress showErrorWithStatus:global_connection_credit_broken completion:^{
            [_popover dismiss];
        }];
        
    } else if ([responseObject[@"ERROR"] isEqualToString:@"no exams"]) {
        // 没有考试
        [KVNProgress showErrorWithStatus:@"暂时没有考试信息" completion:^{
            [_popover dismiss];
        }];
    } else {
        // 成功
        
        NSMutableArray *examData = [[ClassParser sharedInstance] parseExamData:responseObject];
        
        [KVNProgress dismiss];
        [_popover dismiss];
        
        [self performSegueWithIdentifier:@"ShowExam" sender:examData];
    }
}


#pragma mark - Grade

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
        [KVNProgress showErrorWithStatus:global_connection_failed completion:^{
            [_popover dismiss];
        }];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}


- (void)parseGradeResponseObject:(id)responseObject
{
    if ([responseObject[@"ERROR"] isEqualToString:@"the password is wrong"] || [responseObject[@"ERROR"] isEqualToString:@"account not exist or not allowed"]) {
        // 账号或密码错误
        [KVNProgress showErrorWithStatus:global_connection_wrong_user_password completion:^{
            [_popover dismiss];
            [self logoutClearData];
            self.navigationController.navigationBarHidden = YES;
            [self.navigationController popViewControllerAnimated:NO];
        }];
        
    } else if ([responseObject[@"ERROR"] isEqualToString:@"credit system broken"]) {
        // 学分制崩溃了
        [KVNProgress showErrorWithStatus:global_connection_credit_broken completion:^{
            [_popover dismiss];
        }];
        
    } else if ([responseObject[@"ERROR"] isEqualToString:@"there is no information about grade"]) {
        // 没有成绩
        [KVNProgress showErrorWithStatus:@"暂时没有成绩信息" completion:^{
            [_popover dismiss];
        }];
    } else {
        // 成功
        
        NSDictionary *gradeData = [[ClassParser sharedInstance] parseGradeData:responseObject];
        
        [KVNProgress dismiss];
        [_popover dismiss];
        
        [self performSegueWithIdentifier:@"ShowGrade" sender:gradeData];
    }
}



#pragma mark - OA

- (void)oa
{
    // KVN
    [KVNProgress showWithStatus:@"正在获取办公自动化信息"];
    
    // ActivityIndicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // Request
    [self sendOaRequest];
}

- (void)sendOaRequest
{
    // ud
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud valueForKey:@"USERNAME"];
    NSString *token = [ud valueForKey:@"USER_TOKEN"];
    
    // post data
    NSDictionary *postData = @{
                               @"username": username,
                               @"token": token,
                               @"pageindex": @"1",
                               };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = global_timeout;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", global_host, oa_url] parameters:postData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
        NSLog(@"连接服务器 - 成功");
        [self parseOaResponseObject:responseObject];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSLog(@"连接服务器 - 失败 - %@", error);
        [KVNProgress showErrorWithStatus:global_connection_failed completion:^{
            [_popover dismiss];
        }];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}


- (void)parseOaResponseObject:(id)responseObject
{
    if ([responseObject[@"ERROR"] isEqualToString:@"wrong token"]) {
        // wrong token
        [KVNProgress showErrorWithStatus:global_connection_wrong_token];
        
        [self performSelector:@selector(logout) withObject:nil afterDelay:0.3];
        
        [_popover dismiss];
        
    } else if ([responseObject[@"ERROR"] isEqualToString:@"invalid input"]) {
        // 未知错误
        [KVNProgress showErrorWithStatus:global_connection_failed completion:^{
            [_popover dismiss];
        }];
        
    } else {
        // 成功
        
        NSMutableArray *documentData = [[ClassParser sharedInstance] parseDocumentData:responseObject];
        
        [KVNProgress dismiss];
        [_popover dismiss];
        
        [self performSegueWithIdentifier:@"ShowDocument" sender:documentData];
    }
}






#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.y;
    
    if (offset > 0.0) {
        [self setSemesterButtonHidden:YES];
    } else {
        [self setSemesterButtonHidden:NO];
    }
}


- (void)setSemesterButtonHidden:(BOOL)hidden
{
    if (_isSemesterButtonHidden != hidden) {
    
        _isSemesterButtonHidden = !_isSemesterButtonHidden;
        
        if (hidden) {
            
            [UIView animateWithDuration:kAnimationDurationForSemesterButton delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                
                _semesterButton.alpha = 0.0;
                
            } completion:nil];
            
        } else {
            
            [UIView animateWithDuration:kAnimationDurationForSemesterButton delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                
                _semesterButton.alpha = 1.0;
                
            } completion:nil];
            
        }
    }
}



// Log Out
- (void)logout
{
    [self logoutClearData];
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

#pragma mark - Week Update & Get

- (BOOL)getCurrentWeek
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *weekData = [ud objectForKey:@"WEEK_DATA"];
    
    NSInteger week = [weekData[@"week"] integerValue];
    NSDate *startDate = weekData[@"date"];
    
    NSInteger days = [[JHDater sharedInstance] getDaysFrom:startDate To:[NSDate date]];
//    NSLog(@"%@", startDate);
//    NSLog(@"%@", [NSDate date]);
//    NSLog(@"days = %d", days);
//    NSLog(@"startWeek = 星期%d", [[JHDater sharedInstance] weekForDate:startDate] + 1);
    NSInteger offset = (days + [[JHDater sharedInstance] weekForDate:startDate]) / 7;
    
    NSInteger newWeek = week + offset;
    
    if (newWeek <= 16 && newWeek >= 1) {
        BOOL hasChanged = (_currentWeek != newWeek);
        _currentWeek = newWeek;
        
        return hasChanged;
    } else {
        _currentWeek = (newWeek > 16) ? 16 : 1;
        return YES;
    }
}

#pragma mark - Show Annoucement

- (void)showAnnoucement
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSString *localVersion = [ud stringForKey:@"LOCAL_VERSION"];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    NSLog(@"当前版本 - %@", appVersion);
    
    if (![localVersion isEqualToString:appVersion]) {
        // 显示更新内容
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"更新内容 v%@", appVersion] message:@"1. 点击导航标题可以设置周数，\n同时周数会自动增加;\n2. 增加了一键登录校内Wi-Fi的功能;\n3. 校园动态增加了公告栏，\n提供各种有关校内活动的信息;\n4. 访问服务器更加快速、稳定;\n5. 解决了显示错误等一大堆Bugs!\n\n目前用户量已达2000多人，谢谢大家!" delegate:nil cancelButtonTitle:@"立即体验 喵:)" otherButtonTitles:nil];
        [alertView show];
        [ud setObject:appVersion forKey:@"LOCAL_VERSION"];
    }
}


#pragma mark - Connect

- (void)connect
{
    [_popover dismiss];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud valueForKey:@"USERNAME"];
    NSString *password = [ud valueForKey:@"PASSWORD"];
    
    // post data
    NSDictionary *postData = @{
                               @"AuthenticateUser": username,
                               @"AuthenticatePassword": password,
                               @"Submit": @"",
                               };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = login_timeout;
    
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    [manager POST:login_host parameters:postData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功
        NSLog(@"一键联网 - 失败");
        [self showHUDWithText:@"请连接STU校内网" andHideDelay:1.0];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSString *str = operation.responseString;
        if ([str containsString:@"Used bytes"]) {
            NSLog(@"一键联网 - 成功");
            [self showHUDWithText:@"已成功登录校内网" andHideDelay:1.0];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        } else {
            NSLog(@"一键联网 - 失败 - %@", error);
            [self showHUDWithText:@"请连接STU校内网" andHideDelay:1.0];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }];
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









