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
#import <SIAlertView/SIAlertView.h>
#import "AddBoxTableViewController.h"
#import "BoxInfoViewController.h"
#import "WXApi.h"
#import "MeTableViewController.h"
#import "UIImageView+WebCache.h"
#import "MYBlurIntroductionView.h"
#import "MailViewController.h"


static const CGFloat kAnimationDurationForSemesterButton = 0.3;

@interface ClassViewController () <UICollectionViewDelegate, UICollectionViewDataSource, ClassCollectionViewLayoutDelegate, ClassCollectionViewCellDelegate, ClassSemesterDelegate, UIScrollViewDelegate, ClassWeekDelegate, UIGestureRecognizerDelegate, ClassAddBoxDelegate, BoxInfoDelegate, MYIntroductionDelegate>

@property (strong, nonatomic) ClassHeaderView *classHeaderView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIImageView *bgImageView;
@property (strong, nonatomic) ClassSemesterButton *semesterButton;

@property (strong, nonatomic) MoreView *moreView;

@property (strong, nonatomic) DXPopover *popover;

@property (assign, nonatomic) BOOL isSemesterButtonHidden;

@property (weak, nonatomic) IBOutlet UIButton *weekButton;

@property (nonatomic) NSInteger currentWeek;

@property (strong, nonatomic) UIImageView *avatarImageView;

@end

@implementation ClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Notification
    [self initNotification];
    
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
        [UIView performWithoutAnimation:^{
            [_weekButton setTitle:[NSString stringWithFormat:@"第 %d 周", _currentWeek] forState:UIControlStateNormal];
            [_weekButton layoutIfNeeded];
        }];
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
    // LEFT
    
//    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//    NSString *username = [ud objectForKey:@"USERNAME"];
//    
//    UIButton *btn;
//    UIBarButtonItem *connectItem;
//    
//    if ([username isEqualToString:@"15sxwang"]) {
//        connectItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar-thunder"] style:UIBarButtonItemStylePlain target:self action:@selector(sixuePress)];
//    } else {
//        connectItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar-thunder"] style:UIBarButtonItemStylePlain target:self action:@selector(connectItemPress)];
//    }
//
//    if ([username isEqualToString:@"15sxwang"] || [username isEqualToString:@"14jhwang"]) {
//        // For Sixue
//        [MobClick event:@"Sixue_Connect"];
//        btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
//        btn.showsTouchWhenHighlighted = YES;
//        [btn setImage:[UIImage imageNamed:@"toolbar-sixue"] forState:UIControlStateNormal];
//        if ([username isEqualToString:@"15sxwang"]) {
//            [btn addTarget:self action:@selector(connectItemPress) forControlEvents:UIControlEventTouchUpInside];
//        } else {
//            [btn addTarget:self action:@selector(sixuePress) forControlEvents:UIControlEventTouchUpInside];
//        }
//        
//        // longPress
//        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showHello:)];
//        gesture.minimumPressDuration = 6.0;
//        [btn addGestureRecognizer:gesture];
//        
//        UIBarButtonItem *sixueItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
//        self.navigationItem.leftBarButtonItems = @[connectItem, sixueItem];
//    } else {
//        // Others
//        self.navigationItem.leftBarButtonItem = connectItem;
//    }
    
    
    // LEFT
    
    _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 34, 34)];
    _avatarImageView.image = [UIImage imageNamed:@"default_avatar"];
    _avatarImageView.layer.cornerRadius = _avatarImageView.bounds.size.width / 2;
    _avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    _avatarImageView.layer.borderWidth = 1.2;
    _avatarImageView.clipsToBounds = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarImageViewDidTap)];
    [_avatarImageView addGestureRecognizer:tap];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"avatarImageChanged" object:nil];
    
    UIBarButtonItem *connectItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar-connect"] style:UIBarButtonItemStylePlain target:self action:@selector(connectItemPress)];
    UIBarButtonItem *userItem = [[UIBarButtonItem alloc] initWithCustomView:_avatarImageView];
    
    // RIGHT
    
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar-more"] style:UIBarButtonItemStylePlain target:self action:@selector(moreItemPress)];
    
    self.navigationItem.leftBarButtonItems = @[userItem];
    self.navigationItem.rightBarButtonItems = @[moreItem, connectItem];
}

- (void)showHello:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 260, 185)];
        view.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, 100);
        view.backgroundColor = [UIColor orangeColor];
        view.layer.cornerRadius = 8.0;
        view.clipsToBounds = YES;
        view.image = [UIImage imageNamed:@"panda.jpg"];
        
        
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"给思学的小彩蛋#3" andMessage:@"思学🙄，你最近好忙啊！\n觉得你很努力，也很可爱！加油！"];
        
        [alertView addButtonWithTitle:@"返回" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView){
            view.hidden = YES;
        }];
        
        [alertView addButtonWithTitle:@"好听的蛋黄Solo" type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://chuckwo.com:81/sixue/ClarinetSolo.mp3"]];
            view.hidden = YES;
        }];
        
        [alertView addSubview:view];
        
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        [alertView show];
    }
}


// View
- (void)initBgImageView
{
    _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64 - 44)];
    
    _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    _bgImageView.clipsToBounds = YES;
    
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
        _bgImageView.image = bgImage ? bgImage : [UIImage imageNamed:@"class_bg_1_6.jpg"];
        
        if (!bgImage) {
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"bgSection"];
            [[NSUserDefaults standardUserDefaults] setInteger:6 forKey:@"bgIndex"];
        }
    }
    
    [self.view addSubview:_bgImageView];
}

- (void)initPopover
{
    _popover = [DXPopover popover];
}

- (void)initMoreView
{
    _moreView = [[MoreView alloc] initWithItems:@[@"添加格子", @"同步课表", @"考试安排", @"我的成绩", @"图书检索", @"汕大邮箱", @"任务清单"] images:@[[UIImage imageNamed:@"more-addbox"], [UIImage imageNamed:@"more-sync"], [UIImage imageNamed:@"more-exam"], [UIImage imageNamed:@"more-grade"], [UIImage imageNamed:@"more-library"], [UIImage imageNamed:@"more-mail"], [UIImage imageNamed:@"more-task"]]];
    
    UIButton *addBtn = _moreView.itemsArray[0];
    [addBtn addTarget:self action:@selector(moreAddPress) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *syncBtn = _moreView.itemsArray[1];
    [syncBtn addTarget:self action:@selector(moreSyncPress) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *examBtn = _moreView.itemsArray[2];
    [examBtn addTarget:self action:@selector(moreExamPress) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *gradeBtn = _moreView.itemsArray[3];
    [gradeBtn addTarget:self action:@selector(moreGradePress) forControlEvents:UIControlEventTouchUpInside];

    UIButton *libraryBtn = _moreView.itemsArray[4];
    [libraryBtn addTarget:self action:@selector(moreLibraryPress) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *mailBtn = _moreView.itemsArray[5];
    [mailBtn addTarget:self action:@selector(moreMailPress) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *taskBtn = _moreView.itemsArray[6];
    [taskBtn addTarget:self action:@selector(moreTaskPress) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initWeekView
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    _currentWeek = [[ud objectForKey:@"WEEK_DATA"][@"week"] integerValue];
    [UIView performWithoutAnimation:^{
        [_weekButton setTitle:[NSString stringWithFormat:@"第 %d 周", _currentWeek] forState:UIControlStateNormal];
        [_weekButton layoutIfNeeded];
    }];
}

- (void)initClassHeaderView
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat k = width / 320.0;
    _classHeaderView = [[ClassHeaderView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 35.0f * k)];
    
    [self.view addSubview:_classHeaderView];
}

- (void)initCollectionView
{
    _collectionView.exclusiveTouch = YES;
    
    // layout
    ClassCollectionViewLayout *layout = [[ClassCollectionViewLayout alloc] init];
    layout.layoutDelegate = self;
    
    // collectionView
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64 + _classHeaderView.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - _classHeaderView.bounds.size.height - 64 - 44) collectionViewLayout:layout];
    
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
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareClass)];
    gesture.numberOfTouchesRequired = 3;
    [_collectionView addGestureRecognizer:gesture];
}


- (void)initSemesterButton
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *dict = [ud valueForKey:@"YEAR_AND_SEMESTER"];
    
    NSInteger semester = [dict[@"semester"] integerValue];
    
    NSString *semesterStr = @"冬季学期";
    
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
    CGFloat yOffset = 218;

    CGFloat height = [UIScreen mainScreen].bounds.size.height;

    if (height == 480) {
        yOffset = 216;
    } else if (height == 667) {
        yOffset = 219;
    } else if (height == 736) {
        yOffset = 223;
    }
    
    _semesterButton = [[ClassSemesterButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - btnWidth, [UIScreen mainScreen].bounds.size.height - yOffset, btnWidth, btnHeight)];
    
    [_semesterButton setTitle:semesterStr forState:UIControlStateNormal];
    
    [_semesterButton addTarget:self action:@selector(semesterButtonPress) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_semesterButton];
}



// Notification
- (void)initNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bgImageChanged) name:@"bgImageChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avatarImageChanged) name:@"avatarImageChanged" object:nil];
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
            
            NSUInteger flag = 2;
            
            if ([box.box_weekType isEqualToString:@"单"]) {
                flag = 1;
            } else if ([box.box_weekType isEqualToString:@"双"]) {
                flag = 0;
            }
            
//            NSLog(@"%@ - type %@   flag %d", [self shrinkName:box.box_name], box.box_weekType, flag);
            
            // 判断单双周
            if (flag == 2 || _currentWeek % 2 == flag) {
                
                // shrinkName
                
                NSString *className = [self shrinkName:box.box_name];
                
                if (!box.box_isClass) {
                    // not class
                    cell.label.text = [NSString stringWithFormat:@"%@%@", className, box.box_weekType.length == 0 ? @"" : [NSString stringWithFormat:@"(%@周)", box.box_weekType]];
                } else {
                    // is class
                    cell.label.text = [NSString stringWithFormat:@"%@@%@%@", className, box.box_room, box.box_weekType.length == 0 ? @"" : [NSString stringWithFormat:@"(%@周)", box.box_weekType]];
                }
                
                if (box.box_isColorful) {
                    [cell setBtnColor:box.box_color];
                } else {
                    [cell setBtnColor:GRAY_BOX_COLOR];
                }
                
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
    
    ClassBox *box = _boxData[tag];
    
    if (!box.box_isClass) {
        // not class
        BoxInfoViewController *bivc = [[BoxInfoViewController alloc] init];
        
        bivc.hidesBottomBarWhenPushed = YES;
        
        bivc.title = box.box_name;
        
        bivc.boxData = _boxData;
        
        bivc.classBox = box;
        
        bivc.delegate = self;
        
        [self.navigationController pushViewController:bivc animated:YES];
        
        [MobClick event:@"Main_ShowBox"];
        
    } else {
        // is class
        [self performSegueWithIdentifier:@"ShowDetail" sender:_boxData[tag]];
        [MobClick event:@"Main_ShowDetail"];
    }
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

- (void)moreAddPress
{
    [self add];
    
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

- (void)moreLibraryPress
{
    [self book];
    [MobClick event:@"More_Library"];
}

- (void)moreMailPress
{
    [_popover dismiss];
    [MobClick event:@"Show_Mail"];
    [self performSegueWithIdentifier:@"ShowMail" sender:nil];
}

- (void)moreTaskPress
{
    [_popover dismiss];
    [MobClick event:@"Show_TaskList"];
    [self performSegueWithIdentifier:@"ShowTaskList" sender:nil];
}

- (void)connectItemPress
{
    [self connect];
    [MobClick event:@"More_Login"];
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
    [self logout];
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

- (void)logoutClearData
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    // ud
    [ud setValue:nil forKey:@"USER_TOKEN"];
    [ud setValue:nil forKey:@"YEAR_AND_SEMESTER"];
    [ud setValue:nil forKey:@"NICKNAME"];
    [ud setValue:nil forKey:@"AVATAR_URL"];
    [ud setValue:nil forKey:@"USER_ID"];
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
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"警告" andMessage:@"同步课表将抹掉你添加的格子，\n确定同步吗？"];
    [alertView addButtonWithTitle:@"取消" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView){
        [_popover dismiss];
    }];
    
    [alertView addButtonWithTitle:@"同步" type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView){
        [self performSelector:@selector(syncClass) withObject:nil afterDelay:0.3];
    }];
    
    [alertView show];
}

- (void)syncClass
{
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
            [self logout];
        }];
        
    } else if ([responseObject[@"ERROR"] isEqualToString:@"credit system broken"]) {
        // 学分制崩溃了
        [KVNProgress showErrorWithStatus:global_connection_credit_broken completion:^{
            [_popover dismiss];
        }];
    } else if ([responseObject[@"ERROR"] isEqualToString:@"the user can't access credit system"]) {
        // 医学院通道
        NSLog(@"医学院通道");
        // 成功
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *username = [ud valueForKey:@"USERNAME"];
        
        // 得到原始数据
        NSMutableArray *originData = [NSMutableArray arrayWithArray:responseObject[@"classes"]];
        
        // 添加class_id
        NSArray *classData = [[ClassParser sharedInstance] generateClassIDForOriginalData:originData withYear:year semester:semester];
        
        // 写入本地CoreData
        [[CoreDataManager sharedInstance] writeSyncClassTableToCoreDataWithClassesArray:classData withYear:year semester:semester username:username];
        
        // 生成DisplayData
        classData = [[CoreDataManager sharedInstance] getClassDataFromCoreDataWithYear:year semester:semester username:username];
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
        NSString *user_id = [NSString stringWithFormat:@"%@", responseObject[@"user_id"]];
        NSLog(@"user_id - %@", user_id);
        [ud setValue:user_id forKey:@"USER_ID"];
        
        [KVNProgress showSuccessWithStatus:@"同步课表成功" completion:^{
            _boxData = boxData;
            [_collectionView reloadData];
            [_collectionView setContentOffset:CGPointZero animated:YES];
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
        [[CoreDataManager sharedInstance] writeSyncClassTableToCoreDataWithClassesArray:classData withYear:year semester:semester username:username];
        
        // 生成DisplayData
        classData = [[CoreDataManager sharedInstance] getClassDataFromCoreDataWithYear:year semester:semester username:username];
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
        NSString *user_id = [NSString stringWithFormat:@"%@", responseObject[@"user_id"]];
        NSLog(@"user_id - %@", user_id);
        [ud setValue:user_id forKey:@"USER_ID"];
        
        [KVNProgress showSuccessWithStatus:@"同步课表成功" completion:^{
            _boxData = boxData;
            [_collectionView reloadData];
            [_collectionView setContentOffset:CGPointZero animated:YES];
            [_popover dismiss];
        }];
    }
}


#pragma mark - Exam

- (void)exam
{
    // KVN
    [KVNProgress showWithStatus:@"正在获取考试安排"];
    
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
        if (operation.response.statusCode == 500) {
            [KVNProgress showErrorWithStatus:@"暂时没有考试信息" completion:^{
                [_popover dismiss];
            }];
        } else {
            [KVNProgress showErrorWithStatus:global_connection_failed completion:^{
                [_popover dismiss];
            }];
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}


- (void)parseExamResponseObject:(id)responseObject
{
    if ([responseObject[@"ERROR"] isEqualToString:@"the password is wrong"] || [responseObject[@"ERROR"] isEqualToString:@"account not exist or not allowed"]) {
        // 账号或密码错误
        [KVNProgress showErrorWithStatus:global_connection_wrong_user_password completion:^{
            [_popover dismiss];
            [self logout];
        }];
        
    } else if ([responseObject[@"ERROR"] isEqualToString:@"credit system broken"]) {
        // 学分制崩溃了
        [KVNProgress showErrorWithStatus:global_connection_credit_broken completion:^{
            [_popover dismiss];
        }];
        
    } else if ([responseObject[@"ERROR"] isEqualToString:@"no exams"]) {
        // 没有考试
        [KVNProgress showErrorWithStatus:@"暂时没有考试安排" completion:^{
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
            [self logout];
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
    [self.navigationController.tabBarController.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Week Update & Get

- (BOOL)getCurrentWeek
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *weekData = [ud objectForKey:@"WEEK_DATA"];
    
    NSInteger week = [weekData[@"week"] integerValue];
    NSDate *startDate = weekData[@"date"];
    
    NSInteger days = [[JHDater sharedInstance] getDaysFrom:startDate To:[NSDate date]];

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
    
    BOOL hasShownWalkThrough = [ud boolForKey:@"SHOW_WALKTHROUGH"];
    
    if (!hasShownWalkThrough) {
        [self showWalkThrough];
        [ud setBool:YES forKey:@"SHOW_WALKTHROUGH"];
    }
}

- (void)showWalkThrough
{
    [MobClick event:@"Walk_Through"];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    UIView *headerView = [[NSBundle mainBundle] loadNibNamed:@"IntroHeader" owner:nil options:nil][0];
    
    MYIntroductionPanel *panel1 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, width, height) title:@"在这里，你可以..." description:@"查看课表、考试安排、成绩、邮件、馆藏图书，一键连接校园Wi-Fi..." image:[UIImage imageNamed:@"intro-img1"] header:headerView];
    
    MYIntroductionPanel *panel2 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, width, height) title:@"在这里，你还可以..." description:@"制作自己的任务清单，让一天的事务一目了然！" image:[UIImage imageNamed:@"intro-img2"] header:nil];
    
    MYIntroductionPanel *panel3 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, width, height) title:@"在这里，你更可以..." description:@"与汕大师生进行互动，分享大学生活点点滴滴！" image:[UIImage imageNamed:@"intro-img3"] header:nil];
    
    MYIntroductionPanel *panel4 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, width, height) title:@"最后" description:@"愿您前程似锦！\n\n2016/5/29" image:nil header:nil];
    
    panel1.PanelDescriptionLabel.font = panel2.PanelDescriptionLabel.font = panel3.PanelDescriptionLabel.font = panel4.PanelDescriptionLabel.font = [UIFont systemFontOfSize:17.0];
    
    panel1.PanelImageView.contentMode = panel2.PanelImageView.contentMode = panel3.PanelImageView.contentMode = panel4.PanelImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    MYBlurIntroductionView *introductionView = [[MYBlurIntroductionView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    
    introductionView.delegate = self;
    
    introductionView.RightSkipButton.hidden = YES;
    [introductionView.RightSkipButton setTitle:@"好的" forState:UIControlStateNormal];
    
    introductionView.BackgroundImageView.image = [UIImage imageNamed:@"intro-bg.jpg"];
    [introductionView setBackgroundColor:[UIColor colorWithRed:90.0f/255.0f green:175.0f/255.0f blue:113.0f/255.0f alpha:0.65]];
    
    [introductionView buildIntroductionWithPanels:@[panel1, panel2, panel3, panel4]];
    
    [self.navigationController.tabBarController.view addSubview:introductionView];
}

#pragma mark - MYIntroduction Delegate

- (void)introduction:(MYBlurIntroductionView *)introductionView didChangeToPanel:(MYIntroductionPanel *)panel withIndex:(NSInteger)panelIndex{
    
    if (panelIndex == 0) {
        [introductionView setBackgroundColor:[UIColor colorWithRed:90.0f/255.0f green:175.0f/255.0f blue:113.0f/255.0f alpha:0.65]];
        introductionView.RightSkipButton.hidden = YES;
    } else if (panelIndex == 1) {
        [introductionView setBackgroundColor:[UIColor colorWithRed:50.0f/255.0f green:79.0f/255.0f blue:133.0f/255.0f alpha:0.65]];
        introductionView.RightSkipButton.hidden = YES;
    } else if (panelIndex == 2) {
        [introductionView setBackgroundColor:[UIColor colorWithRed:0.745 green:0.298 blue:0.235 alpha:0.65]];
        introductionView.RightSkipButton.hidden = YES;
    } else {
        [introductionView setBackgroundColor:[UIColor clearColor]];
        introductionView.RightSkipButton.hidden = NO;
    }
}

- (void)introduction:(MYBlurIntroductionView *)introductionView didFinishWithType:(MYFinishType)finishType {
    NSLog(@"介绍完了!");
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSString *localVersion = [ud stringForKey:@"LOCAL_VERSION"];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    NSLog(@"当前版本 - %@", appVersion);
    
    if (![localVersion isEqualToString:appVersion]) {
        // 显示更新内容
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"更新内容 v%@", appVersion] andMessage:UPDATE_CONTENT];
        
        alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        
        [alertView addButtonWithTitle:@"立即体验 🙄:)" type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
            [ud setObject:appVersion forKey:@"LOCAL_VERSION"];
            if (_boxData.count == 0) {
                [self showHUDWithText:@"点击右上角可以添加格子哟!" andHideDelay:global_hud_long_delay];
                [self performSelector:@selector(showShareClassTip) withObject:nil afterDelay:global_hud_long_delay + 0.2];
            } else {
                [self showHUDWithText:@"三个手指触屏可以分享课表哟!" andHideDelay:global_hud_long_delay];
            }
        }];
        
        [alertView show];
    }
}




- (void)showShareClassTip
{
    [self showHUDWithText:@"三个手指触屏可以分享课表哟!" andHideDelay:global_hud_long_delay];
}

#pragma mark - Connect

- (void)connect
{
    [_popover dismiss];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud valueForKey:@"USERNAME"];
    NSString *password = [ud valueForKey:@"PASSWORD"];
    
    [MobClick event:@"Main_WiFi" attributes:@{@"Username": username}];
    
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
        [self showHUDWithText:@"请连接STU校内网" andHideDelay:global_hud_delay];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失败
        NSString *str = operation.responseString;

        NSRange range = [str rangeOfString:@"Used bytes"];
        if (range.location != NSNotFound && str) {
            NSLog(@"一键联网 - 成功");
            NSUInteger MB = [self getMbFromString:str];
            [self showHUDWithText:[NSString stringWithFormat:@"已使用流量 %dMB", MB] andHideDelay:global_hud_long_delay];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        } else {
            NSLog(@"一键联网 - 失败 - %@", error);
            [self showHUDWithText:@"请连接STU校内网" andHideDelay:global_hud_delay];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }];
}

- (NSUInteger)getMbFromString:(NSString *)responseStr
{
    NSUInteger mb = 0;

    NSError *error = NULL;
    NSString *pattern = @"<tr id=\"ubr\" style=\"line-height: 180%;font-size:12px\">\\s*<td><strong>Used bytes: </strong></td>\\s*<td class=\"text3\" id=\"ub\">(.*?)</td>\\s*</tr>";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];

    NSArray *matchedArray = [regex matchesInString:responseStr options:0 range:NSMakeRange(0, responseStr.length)];
    if (matchedArray.count > 0) {

        NSTextCheckingResult *result = [matchedArray firstObject];

        NSString *str = [responseStr substringWithRange:[result rangeAtIndex:1]];

        NSString *numStr = [str stringByReplacingOccurrencesOfString:@"," withString:@""];

        mb = [numStr integerValue] / 1024 / 1024;

        return mb;
    } else {
        return 0;
    }
}

- (void)book
{
    [_popover dismiss];
    [self performSegueWithIdentifier:@"ShowLibrary" sender:nil];
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

- (void)add
{
    [_popover dismiss];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    AddBoxTableViewController *abtvc = [sb instantiateViewControllerWithIdentifier:@"AddBoxTVC"];
    
    abtvc.delegate = self;
    
    abtvc.boxData = _boxData;
    
    [self.navigationController pushViewController:abtvc animated:YES];
}

#pragma mark - AddBoxDelegate

- (void)addBoxDelegateDidAdd:(NSArray *)boxData
{
    _boxData = boxData;
    
    [_collectionView reloadData];
}

#pragma mark - BoxInfoDelegate

- (void)boxInfoDelegateDidChanged:(NSArray *)boxData
{
    _boxData = boxData;
    
    [_collectionView reloadData];
}

#pragma mark - ShareClass

- (UIImage *)screenShot
{
    UIImage *image;
    UIGraphicsBeginImageContextWithOptions(self.collectionView.contentSize, NO, 0.0);
    
    {
        CGPoint savedContentOffset = self.collectionView.contentOffset;
        CGRect savedFrame = self.collectionView.frame;
        
        self.collectionView.contentOffset = CGPointZero;
        self.collectionView.frame = CGRectMake(0, 0, self.collectionView.contentSize.width, self.collectionView.contentSize.height);
        
        [self.collectionView.layer renderInContext: UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        self.collectionView.contentOffset = savedContentOffset;
        self.collectionView.frame = savedFrame;
    }
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    return image;
}

- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize

{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
}

- (void)shareClass
{
    [MobClick event:@"Main_ShareClass"];
    
    UIImage *image = [self screenShot];
    
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"分享课表" message:@"课表截图已保存到相册" preferredStyle:UIAlertControllerStyleActionSheet];
        
        [controller addAction:[UIAlertAction actionWithTitle:@"微信好友" style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertAction){
            
            //创建发送对象实例
            SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
            sendReq.bText = NO;
            sendReq.scene = 0;
            
            //创建分享内容对象
            WXMediaMessage *urlMessage = [WXMediaMessage message];
            
            WXImageObject *imageObj = [WXImageObject object];
            
            imageObj.imageData = UIImageJPEGRepresentation(image, 1.0);
            urlMessage.mediaObject = imageObj;
            
            urlMessage.thumbImage = [self reSizeImage:image toSize:CGSizeMake(200, 200 * image.size.height / image.size.width)];
            
            //完成发送对象实例
            sendReq.message = urlMessage;
            
            //发送分享信息
            [WXApi sendReq:sendReq];
            
        }]];
        
        [controller addAction:[UIAlertAction actionWithTitle:@"微信朋友圈" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *alertAction){
            
            //创建发送对象实例
            SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
            sendReq.bText = NO;
            sendReq.scene = 1;
            
            //创建分享内容对象
            WXMediaMessage *urlMessage = [WXMediaMessage message];
            
            WXImageObject *imageObj = [WXImageObject object];
            
            imageObj.imageData = UIImageJPEGRepresentation(image, 1.0);
            urlMessage.mediaObject = imageObj;
            
            urlMessage.thumbImage = [self reSizeImage:image toSize:CGSizeMake(200, 200 * image.size.height / image.size.width)];
            
            //完成发送对象实例
            sendReq.message = urlMessage;
            
            //发送分享信息
            [WXApi sendReq:sendReq];
        }]];
        
        [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *alertAction){
            
        }]];
        
        [self presentViewController:controller animated:YES completion:nil];
        
    } else {
        
        [self showHUDWithText:@"截图已保存到相册(当前微信不可用)" andHideDelay:global_hud_delay];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_popover dismiss];
}


#pragma mark - Avatar

- (void)avatarImageChanged
{
    NSLog(@"重新加载Avatar");
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *urlStr = [ud objectForKey:@"AVATAR_URL"];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    // local
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager diskImageExistsForURL:url];
    
    UIImage *placeholder;
    
    if ([manager diskImageExistsForURL:url]) {
        placeholder = [[manager imageCache] imageFromDiskCacheForKey:urlStr] ? [[manager imageCache] imageFromDiskCacheForKey:urlStr] : [UIImage imageNamed:@"default_avatar"];
    } else {
        placeholder = [UIImage imageNamed:@"default_avatar"];
    }
    
    // fetch
    [_avatarImageView sd_setImageWithURL:url placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
}

- (void)avatarImageViewDidTap
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    MeTableViewController *mtvc = [sb instantiateViewControllerWithIdentifier:@"metableviewcontroller"];
    
    [self.navigationController pushViewController:mtvc animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end









