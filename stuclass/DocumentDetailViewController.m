//
//  DocumentDetailViewController.m
//  stuclass
//
//  Created by JunhaoWang on 11/27/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "DocumentDetailViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "MBProgressHUD.h"
#import "Define.h"
#import "WXApi.h"
#import "MobClick.h"

@interface DocumentDetailViewController () <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;

@end

@implementation DocumentDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [MobClick event:@"OA_Detail"];
    [self setupWebView];
}



- (void)setupWebView
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    
    self.webView.backgroundColor = TABLEVIEW_BACKGROUN_COLOR;
    
    self.webView.scalesPageToFit = NO;
    
    [self.webView loadHTMLString:_content baseURL:nil];
    
    self.webView.delegate = self;
    
    self.webView.dataDetectorTypes = UIDataDetectorTypeAll;
    
    [self.view addSubview:self.webView];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ( navigationType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
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


- (IBAction)share:(id)sender
{
    [MobClick event:@"OA_Share"];
    
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        
        NSString *title = [NSString stringWithFormat:@"%@", _oa_title];
        NSString *description = [NSString stringWithFormat:@"%@\n%@\n(点击打开App)", self.title, _date];
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"分享" message:@"\"告诉你同学他上办公自动化了\"" preferredStyle:UIAlertControllerStyleActionSheet];
        
        [controller addAction:[UIAlertAction actionWithTitle:@"微信好友" style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertAction){
            
            //创建发送对象实例
            SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
            sendReq.bText = NO;
            sendReq.scene = 0;
            
            //创建分享内容对象
            WXMediaMessage *urlMessage = [WXMediaMessage message];
            urlMessage.title = title;
            urlMessage.description = description;
            [urlMessage setThumbImage:[UIImage imageNamed:@"WXAppIcon"]];
            
            //创建多媒体对象
            WXWebpageObject *webObj = [WXWebpageObject object];
            webObj.webpageUrl = jump_app_url;
            
            //完成发送对象实例
            urlMessage.mediaObject = webObj;
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
            urlMessage.title = title;
            urlMessage.description = description;
            [urlMessage setThumbImage:[UIImage imageNamed:@"WXAppIcon"]];
            
            //创建多媒体对象
            WXWebpageObject *webObj = [WXWebpageObject object];
            webObj.webpageUrl = jump_app_url;
            
            //完成发送对象实例
            urlMessage.mediaObject = webObj;
            sendReq.message = urlMessage;
            
            //发送分享信息
            [WXApi sendReq:sendReq];
        }]];
        
        [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *alertAction){
            
        }]];
        
        [self presentViewController:controller animated:YES completion:nil];
        
    } else {
        
        [self showHUDWithText:@"当前微信不可用" andHideDelay:global_hud_delay];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end








