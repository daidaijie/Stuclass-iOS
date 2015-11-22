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
#import "SettingTableViewController.h"
#import "Define.h"
//#import "KGModal.h"
#import <KVNProgress/KVNProgress.h>
#import "ClassParser.h"
#import "CoreDataManager.h"
#import "DetailViewController.h"
#import "ClassBox.h"
#import <AFNetworking/AFNetworking.h>
#import <DXPopover/DXPopover.h>
#import "MoreView.h"
#import "GradeTableViewController.h"

static NSString *login_url = @"/syllabus";

static NSString *exam_url = @"/exam";

static NSString *grade_url = @"/grade";

@interface ClassViewController () <UICollectionViewDelegate, UICollectionViewDataSource, ClassCollectionViewLayoutDelegate, ClassCollectionViewCellDelegate, SettingLogOutDelegate>

@property (strong, nonatomic) ClassHeaderView *classHeaderView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIImageView *bgImageView;

@property (strong, nonatomic) MoreView * moreView;

@property (strong, nonatomic) DXPopover *popover;

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
    [self initClassHeaderView];
    [self initCollectionView];
    
    // Notification
    [self initNotification];
}

#pragma mark - View Delegate
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 更新顶部日期
    [_classHeaderView updateCurrentDateOnClassHeaderView];
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
    
    UIBarButtonItem *publicItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-public"] style:UIBarButtonItemStylePlain target:self action:@selector(publicItemPress)];
    
    self.navigationItem.rightBarButtonItems = @[moreItem, publicItem];
}


// View
- (void)initBgImageView
{
    _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
    
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
    _moreView = [[MoreView alloc] initWithItems:@[@"更新课表", @"考试信息", @"我的成绩"]];
    
    UIButton *syncBtn = _moreView.itemsArray[0];
    [syncBtn addTarget:self action:@selector(moreSyncPress) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *examBtn = _moreView.itemsArray[1];
    [examBtn addTarget:self action:@selector(moreExamPress) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *gradeBtn = _moreView.itemsArray[2];
    [gradeBtn addTarget:self action:@selector(moreGradePress) forControlEvents:UIControlEventTouchUpInside];
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
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64+_classHeaderView.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - _classHeaderView.bounds.size.height - 64) collectionViewLayout:layout];
    
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
        
        // shrinkName
        
        NSString *className = [self shrinkName:box.box_name];
        
        [cell setBtnDescription:[NSString stringWithFormat:@"%@@%@%@", className, box.box_room, box.box_weekType.length == 0 ? @"" : [NSString stringWithFormat:@"(%@周)", box.box_weekType]]];
        [cell setBtnColor:box.box_color];
        
        cell.tag = row;
        cell.delegate = self;
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
    }
}

- (void)moreItemPress
{
    [self more];
}


- (void)more
{
    _popover = [DXPopover popover];
    [_popover showAtPoint:CGPointMake(292 * [UIScreen mainScreen].bounds.size.width / 320, 67) popoverPostion:DXPopoverPositionDown withContentView:_moreView inView:self.navigationController.view];
}

- (void)moreSyncPress
{
    [self sync];
}

- (void)moreExamPress
{
    [self exam];
}

- (void)moreGradePress
{
    [self grade];
}


- (void)publicItemPress
{
    // TODO...
}


- (IBAction)settingButtonPress:(id)sender
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SettingTableViewController *stvc = [sb instantiateViewControllerWithIdentifier:@"stvc"];
    stvc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] init];
    nvc.viewControllers = @[stvc];
    [self presentViewController:nvc animated:YES completion:nil];
}



#pragma mark - SettingDelegate

// Log Out
- (void)settingTableViewControllerLogOut
{
    [self logutClearData];
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController popViewControllerAnimated:NO];
    
}

- (void)logutClearData
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    //    NSDictionary *dict = [ud valueForKey:@"YEAR_AND_SEMESTER"];
    
    //    NSInteger year = [dict[@"year"] integerValue];
    //    NSInteger semester = [dict[@"semester"] integerValue];
    
    // CoreData
    //    [[CoreDataManager sharedInstance] deleteClassTableWithYear:year semester:semester];
    
    // ud
    [ud setValue:nil forKey:@"USER_TOKEN"];
    [ud setValue:nil forKey:@"YEAR_AND_SEMESTER"];
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
//        NSLog(@"连接服务器 - 成功 - %@", responseObject);
        NSLog(@"连接服务器 - 成功");
        [self parseResponseObject:responseObject withYear:year semester:semester];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSLog(@"连接服务器 - 失败 - %@", error);
        [KVNProgress showErrorWithStatus:@"连接服务器失败\n(请连接校园网)" completion:^{
            [_popover dismiss];
        }];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}


- (void)parseResponseObject:(id)responseObject withYear:(NSInteger)year semester:(NSInteger)semester
{
    if ([responseObject[@"ERROR"] isEqualToString:@"the password is wrong"] || [responseObject[@"ERROR"] isEqualToString:@"account not exist or not allowed"]) {
        // 账号或密码错误
        [KVNProgress showErrorWithStatus:@"账号或密码有误，请重新登录" completion:^{
            [_popover dismiss];
            [self logutClearData];
            self.navigationController.navigationBarHidden = YES;
            [self.navigationController popViewControllerAnimated:NO];
        }];
        
    } else if ([responseObject[@"ERROR"] isEqualToString:@"credit system broken"]) {
        // 学分制崩溃了
        [KVNProgress showErrorWithStatus:@"天哪！学分制系统崩溃了！" completion:^{
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
        
        _boxData = boxData;
        
        [_collectionView.collectionViewLayout invalidateLayout];
        
        ClassCollectionViewLayout *layout = [[ClassCollectionViewLayout alloc] init];
        
        layout.layoutDelegate = self;
        
        [_collectionView setCollectionViewLayout:layout animated:YES];
        
        [_collectionView reloadData];
        
        [_collectionView setContentOffset:CGPointZero animated:YES];
        
        [KVNProgress showSuccessWithStatus:@"更新课表成功" completion:^{
            [_popover dismiss];
        }];
    }
}


#pragma mark - Exam

- (void)exam
{
    
}

#pragma mark - My Grade

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
        //        NSLog(@"连接服务器 - 成功 - %@", responseObject);
        NSLog(@"连接服务器 - 成功");
        [self parseGradeResponseObject:responseObject];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSLog(@"连接服务器 - 失败 - %@", error);
        [KVNProgress showErrorWithStatus:@"连接服务器失败\n(请连接校园网)" completion:^{
            [_popover dismiss];
        }];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}


- (void)parseGradeResponseObject:(id)responseObject
{
    if ([responseObject[@"ERROR"] isEqualToString:@"the password is wrong"] || [responseObject[@"ERROR"] isEqualToString:@"account not exist or not allowed"]) {
        // 账号或密码错误
        [KVNProgress showErrorWithStatus:@"账号或密码有误，请重新登录" completion:^{
            [_popover dismiss];
            [self logutClearData];
            self.navigationController.navigationBarHidden = YES;
            [self.navigationController popViewControllerAnimated:NO];
        }];
        
    } else if ([responseObject[@"ERROR"] isEqualToString:@"credit system broken"]) {
        // 学分制崩溃了
        [KVNProgress showErrorWithStatus:@"天哪！学分制系统崩溃了！" completion:^{
            [_popover dismiss];
        }];
    } else {
        // 成功
        
        NSDictionary *gradeData = [[ClassParser sharedInstance] parseGradeData:responseObject];
        
//        NSLog(@"%@", gradeData);
        
        [KVNProgress dismiss];
        [_popover dismiss];
        
        [self performSegueWithIdentifier:@"ShowGrade" sender:gradeData];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end









