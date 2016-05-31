//
//  ExamTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 11/24/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "ExamTableViewController.h"
#import "ExamTableViewCell.h"
#import "Exam.h"
#import "ClassParser.h"
#import <KVNProgress/KVNProgress.h>
#import <AFNetworking/AFNetworking.h>
#import "Define.h"
#import "MobClick.h"
#import "WXApi.h"
#import "MBProgressHUD.h"

static NSString *cell_id = @"ExamTableViewCell";
static NSString *header_cell_id = @"HeaderExamTableViewCell";

static const NSInteger kHeightForHeaderCellRow = 44.0;
static const NSInteger kHeightForCellRow = 46.0;

@interface ExamTableViewController ()

@property (copy, nonatomic) NSString *yearAndSemester;

@end

@implementation ExamTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupYearAndSemester];
    
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

- (void)setupYearAndSemester
{
    // ud
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [ud valueForKey:@"YEAR_AND_SEMESTER"];
    
    NSInteger year = [dict[@"year"] integerValue];
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
    
    _yearAndSemester = [NSString stringWithFormat:@"%d-%d %@", year, year + 1, semesterStr];
}


#pragma mark - TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return kHeightForHeaderCellRow;
    } else {
        return kHeightForCellRow;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _examData.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 1 : 6;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    } else {
        
        return [NSString stringWithFormat:@"第 %d 场考试", section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 0 && row == 0) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:header_cell_id forIndexPath:indexPath];
        
        cell.textLabel.text = _yearAndSemester;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"共有%d门考试", _examData.count];
        
        return cell;
        
    } else {
        
        ExamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id forIndexPath:indexPath];
        
        Exam *exam = _examData[section - 1];
        
        NSString *nameStr = @"";
        NSString *contentStr = @"";
        
        switch (row) {
            case 0:
                nameStr = @"课程名称";
                contentStr = exam.name;
                break;
            case 1:
                nameStr = @"地点";
                contentStr = exam.location;
                break;
            case 2:
                nameStr = @"座位号";
                contentStr = exam.position;
                break;
            case 3:
                nameStr = @"主考、监考";
                contentStr = [NSString stringWithFormat:@"%@, %@", exam.teacher, exam.invigilator];
                break;
            case 4:
                nameStr = @"时间";
                contentStr = exam.time;
                break;
            case 5:
                nameStr = @"备注";
                contentStr = exam.comment;
                break;
                
            default:
                break;
        }
        
        cell.nameLabel.text = nameStr;
        
        cell.contentLabel.text = contentStr;
        
        return cell;
    }
}

#pragma mark - Event
- (IBAction)syncItemPress:(id)sender
{
    [self exam];
    [MobClick event:@"More_Exam"];
}


- (void)exam
{
    // KVN
    [KVNProgress showWithStatus:@"正在获取我的成绩"];
    
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
            [KVNProgress showErrorWithStatus:@"暂时没有考试信息"];
        } else {
            [KVNProgress showErrorWithStatus:global_connection_failed];
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}


- (void)parseExamResponseObject:(id)responseObject
{
    if ([responseObject[@"ERROR"] isEqualToString:@"the password is wrong"] || [responseObject[@"ERROR"] isEqualToString:@"account not exist or not allowed"]) {
        // 账号或密码错误
        [KVNProgress showErrorWithStatus:global_connection_wrong_user_password];
        
        [self performSelector:@selector(logout) withObject:nil afterDelay:0.3];
        
    } else if ([responseObject[@"ERROR"] isEqualToString:@"credit system broken"]) {
        // 学分制崩溃了
        [KVNProgress showErrorWithStatus:global_connection_credit_broken];
    } else if ([responseObject[@"ERROR"] isEqualToString:@"no exams"]) {
        // 没有考试
        [KVNProgress showErrorWithStatus:@"暂时没有考试信息"];
        
    } else {
        // 成功
        
        NSMutableArray *examData = [[ClassParser sharedInstance] parseExamData:responseObject];
        
        _examData = examData;
        
        [self.tableView reloadData];
        
        [KVNProgress showSuccessWithStatus:@"获取考试信息成功" completion:^{
            
            [self.tableView setContentOffset:CGPointMake(0, -58) animated:YES];
        }];
    }
}

- (void)logout
{
    [self logoutClearData];
    [self.navigationController.tabBarController.navigationController popToRootViewControllerAnimated:YES];
}


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

- (IBAction)shareItemPress:(id)sender
{
    [self shareExam];
}

- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize

{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
}

- (void)shareExam
{
    [MobClick event:@"More_Exam_Share"];
    
    UIImage *image = [self screenShot];
    
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"分享考试安排" message:@"截图已保存到相册" preferredStyle:UIAlertControllerStyleActionSheet];
        
        [controller addAction:[UIAlertAction actionWithTitle:@"微信好友" style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertAction){
            
            //创建发送对象实例
            SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
            sendReq.bText = NO;
            sendReq.scene = 0;
            
            //创建分享内容对象
            WXMediaMessage *urlMessage = [WXMediaMessage message];
            
//            urlMessage.thumbImage = [UIImage imageNamed:@"WXAppIcon"];
            
            WXImageObject *imageObj = [WXImageObject object];
            
            imageObj.imageData = UIImageJPEGRepresentation(image, 1.0);
            urlMessage.mediaObject = imageObj;
            
            urlMessage.thumbImage = [self reSizeImage:image toSize:CGSizeMake(200 * image.size.width / image.size.height, 200)];
            
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
            
//            urlMessage.thumbImage = [UIImage imageNamed:@"WXAppIcon"];
            
            WXImageObject *imageObj = [WXImageObject object];
            
            imageObj.imageData = UIImageJPEGRepresentation(image, 1.0);
            urlMessage.mediaObject = imageObj;
            
//            urlMessage.thumbImage = [self reSizeImage:image toSize:CGSizeMake(200, 200 * image.size.height / image.size.width)];
            urlMessage.thumbImage = [self reSizeImage:image toSize:CGSizeMake(200 * image.size.width / image.size.height, 200)];
            
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



- (UIImage *)screenShot
{
    UIImage *image;
    UIGraphicsBeginImageContextWithOptions(self.tableView.contentSize, NO, 0.0);
    
    {
        CGPoint savedContentOffset = self.tableView.contentOffset;
        CGRect savedFrame = self.tableView.frame;
        
        self.tableView.contentOffset = CGPointZero;
        self.tableView.frame = CGRectMake(0, 0, self.tableView.contentSize.width, self.tableView.contentSize.height);
        
        [self.tableView.layer renderInContext: UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        self.tableView.contentOffset = savedContentOffset;
        self.tableView.frame = savedFrame;
    }
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    return image;
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












