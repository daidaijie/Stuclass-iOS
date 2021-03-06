//
//  BookDetailViewController.m
//  stuclass
//
//  Created by JunhaoWang on 4/23/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "BookDetailViewController.h"
#import "MBProgressHUD.h"
#import "Define.h"
#import "MobClick.h"

@interface BookDetailViewController () <UIWebViewDelegate>

@property (strong, nonatomic)  UIWebView *webView;
@end

@implementation BookDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [MobClick event:@"Library_ShowPosition"];
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
    
    [self.view addSubview:_webView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:global_timeout];
    
    [_webView loadRequest:request];
    
    BOOL isSecond = [[NSUserDefaults standardUserDefaults] boolForKey:@"SECOND_TIME_OPEN_BOOK_RESULT"];
    
    if (!isSecond) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SECOND_TIME_OPEN_BOOK_RESULT"];
        [self showHUDWithText:@"连续触摸<馆藏地>即可放大显示" andHideDelay:global_hud_delay];
    }
}

- (IBAction)refresh:(id)sender
{
    [_webView stopLoading];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:global_timeout];
    [_webView loadRequest:request];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self showHUDWithText:@"加载失败，请重试" andHideDelay:global_hud_delay];
}

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
