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

@interface DocumentDetailViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation DocumentDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupWebView];
}



- (void)setupWebView
{
    self.webView.scalesPageToFit = NO;
    
    [self.webView loadHTMLString:_content baseURL:nil];
    
    self.webView.dataDetectorTypes = UIDataDetectorTypeAll;
}


//- (void)showDetailWithURL:(NSString *)url
//{
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.requestSerializer.timeoutInterval = 3.0;
//    [manager.requestSerializer setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.3 (KHTML, like Gecko) Version/8.0 Mobile/12A4345d Safari/600.1.4" forHTTPHeaderField:@"User-Agent"];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        [self.webView loadHTMLString:[self dealWithHtml:operation.responseString] baseURL:nil];
//        
//        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//        NSLog(@"失败 - %@", error);
//        
//        [self showHUDWithText:@"当前网络不可用(需要连入校内网)" andHideDelay:1.6];
//        
//        [self performSelector:@selector(popover) withObject:nil afterDelay:1.6];
//    }];
//}

//- (void)popover
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}


- (NSString *)dealWithHtml:(NSString *)responseHtml
{
    responseHtml = [[[[responseHtml stringByReplacingOccurrencesOfString:@"FONT-FAMILY: Verdana;" withString:@"background: #eeeeee;"] stringByReplacingOccurrencesOfString:@"#ffffff" withString:@"#eeeeee"] stringByReplacingOccurrencesOfString:@"<hr />" withString:@""] stringByReplacingOccurrencesOfString:@"<hr>" withString:@""];
    return responseHtml;
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
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"分享" message:@"\"告诉你同学可以拿奖学金了\"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [controller addAction:[UIAlertAction actionWithTitle:@"微信好友" style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertAction){
        
    }]];
    
    [controller addAction:[UIAlertAction actionWithTitle:@"微信朋友圈" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *alertAction){
        
    }]];
    
    [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *alertAction){
        
    }]];
    
    [self presentViewController:controller animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end








