//
//  DocumentFavoriteTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 4/8/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "DocumentFavoriteTableViewController.h"
#import "DocumentDetailViewController.h"
#import "Define.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "Document.h"
#import "DocumentTableViewCell.h"
#import "DocumentFooterView.h"
#import "MBProgressHUD.h"
#import "DetailViewController.h"
#import "MobClick.h"
#import <SIAlertView/SIAlertView.h>

static const CGFloat kHeightForSectionHeader = 8.0;

static NSString *cell_id = @"DocumentTableViewCell";

@interface DocumentFavoriteTableViewController () <UIActionSheetDelegate>

@property (strong, nonatomic) NSMutableArray *documentData;

@property (strong, nonatomic) UIView *sectionHeaderView;

@property (strong, nonatomic) UIView *emptyView;

@end

@implementation DocumentFavoriteTableViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    [self setupBackBarButton];
    [self setupOfficeData];
    [self setupTableView];
    
    [MobClick event:@"Document_Favorite"];
}

- (void)setupBackBarButton
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
}

- (void)setupOfficeData
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    NSMutableArray *officeData = [ud objectForKey:@"DOCUMENTS"];

    _documentData = officeData;

    [self.tableView reloadData];
}

- (void)setupTableView
{
    // emptyView
    _emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height - 64)];

    _emptyView.backgroundColor = TABLEVIEW_BACKGROUN_COLOR;
    UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _emptyView.frame.size.width, 50)];
    emptyLabel.center = CGPointMake(_emptyView.frame.size.width / 2, _emptyView.frame.size.height / 2 + 25);
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.textColor = MAIN_COLOR;
    emptyLabel.text = @"你还没有收藏记录哦!";
    [_emptyView addSubview:emptyLabel];

    UIImageView *emptyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 88, 88)];
    emptyImageView.center = CGPointMake(_emptyView.frame.size.width / 2, _emptyView.frame.size.height / 2 - 41);
    emptyImageView.image = [UIImage imageNamed:@"icon-empty-discuss"];
    [_emptyView addSubview:emptyImageView];

    [self.view addSubview:_emptyView];



    self.tableView.backgroundColor = TABLEVIEW_BACKGROUN_COLOR;

    self.tableView.fd_debugLogEnabled = NO;

    // FooterView
    DocumentFooterView *footerView = [[DocumentFooterView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 50)];
    self.tableView.tableFooterView = footerView;

    // sectionHeaderView
    _sectionHeaderView = [[UIView alloc] init];
    _sectionHeaderView.backgroundColor = [UIColor clearColor];

    // LongPress
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPressGesture.minimumPressDuration = 0.4;
    [self.tableView addGestureRecognizer:longPressGesture];
}

#pragma mark - TableView Delegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeightForSectionHeader;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    _emptyView.hidden = (_documentData.count != 0);
    tableView.scrollEnabled = (_documentData.count != 0);
    return _documentData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DocumentTableViewCell *cell;

    cell = [tableView dequeueReusableCellWithIdentifier:cell_id forIndexPath:indexPath];

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (void)configureCell:(DocumentTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = _documentData[indexPath.section];

    cell.nameLabel.text = dict[@"title"];
    cell.dateLabel.text = dict[@"date"];
    cell.departmentLabel.text = dict[@"department"];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:cell_id cacheByIndexPath:indexPath configuration:^(id cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;

    NSDictionary *dict = _documentData[section];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DocumentDetailViewController *ddvc = [sb instantiateViewControllerWithIdentifier:@"ddvc"];
    ddvc.content = dict[@"content"];
    ddvc.oa_title = dict[@"title"];
    ddvc.date = dict[@"date"];
    ddvc.title = dict[@"department"];
    [self.navigationController pushViewController:ddvc animated:YES];
}


#pragma mark - Long Press
// 长按触发方法
- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [gesture locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
        if (indexPath == nil) return ;
        // 显示ActionSheet
        NSUInteger section = indexPath.section;

        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"取消收藏" otherButtonTitles:nil];

        actionSheet.tag = 10000 + section;

        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (actionSheet.tag >= 10000 && buttonIndex == 0) {
        // 取消收藏

        NSUInteger section = actionSheet.tag - 10000;

        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

        NSMutableArray *documentArray = [NSMutableArray arrayWithArray:[ud objectForKey:@"DOCUMENTS"]];

        NSInteger flag = -1;

        for (NSInteger i = 0; i < documentArray.count; i++) {

            NSString *title = _documentData[section][@"title"];
            
            if ([title isEqualToString:documentArray[i][@"title"]]) {
                // 找到
                flag = i;
                break;
            }
        }

        if (flag != -1) {
            [documentArray removeObjectAtIndex:flag];
            [ud setObject:documentArray forKey:@"DOCUMENTS"];
        }

        _documentData = documentArray;

        [self.tableView reloadData];

//        [self displayUD];

        [self showHUDWithText:@"取消成功" andHideDelay:0.8];

    } else if (actionSheet.tag < 10000 && buttonIndex == 0) {
        // 添加收藏

        NSUInteger section = actionSheet.tag;

        NSMutableDictionary *document = [NSMutableDictionary dictionary];

        document[@"title"] = _documentData[section][@"title"];
        document[@"department"] = _documentData[section][@"department"];
        document[@"content"] = _documentData[section][@"content"];
        document[@"date"] = _documentData[section][@"date"];

        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

        NSMutableArray *documentArray = [NSMutableArray arrayWithArray:[ud objectForKey:@"DOCUMENTS"]];

        [documentArray addObject:document];

        [ud setObject:documentArray forKey:@"DOCUMENTS"];

        _documentData = documentArray;

        [self.tableView reloadData];

//        [self displayUD];

        [self showHUDWithText:@"添加成功" andHideDelay:0.8];
    }
}


- (void)displayUD
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    NSArray *documentArray = [ud objectForKey:@"DOCUMENTS"];

    for (NSDictionary *dict in documentArray) {
        NSLog(@"<><><><><> %@", dict[@"title"]);
    }
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


- (IBAction)trashPress:(id)sender
{
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"警告" andMessage:@"确认清空收藏?"];
    
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    
    [alertView addButtonWithTitle:@"不忍心" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
        
    }];
    
    [alertView addButtonWithTitle:@"删了" type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:nil forKey:@"DOCUMENTS"];
        _documentData = nil;
        [self.tableView reloadData];
    }];
    
    [alertView show];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end





