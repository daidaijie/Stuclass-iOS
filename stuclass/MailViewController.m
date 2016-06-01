//
//  MailViewController.m
//  stuclass
//
//  Created by JunhaoWang on 6/1/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "MailViewController.h"
#import "Define.h"
#import "MBProgressHUD.h"

@interface MailViewController () <UIWebViewDelegate>

@property (strong, nonatomic)  UIWebView *webView;

@end

@implementation MailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupWebView];
}

- (void)setupWebView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    _webView.delegate = self;
    _webView.opaque = NO;
    _webView.backgroundColor = [UIColor clearColor];
    _webView.scalesPageToFit = YES;
    _webView.dataDetectorTypes = UIDataDetectorTypeAll;
    
    [self.view addSubview:_webView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.stu.edu.cn/"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:global_timeout];
    
    [_webView loadRequest:request];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (IBAction)refresh:(id)sender
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.stu.edu.cn/"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:global_timeout];
    
    [_webView loadRequest:request];
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
