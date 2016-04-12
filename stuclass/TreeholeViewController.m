//
//  TreeholeViewController.m
//  stuclass
//
//  Created by JunhaoWang on 4/8/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "TreeholeViewController.h"
#import "MBProgressHUD.h"
#import "MobClick.h"
#import <SIAlertView/SIAlertView.h>

@interface TreeholeViewController () <UIWebViewDelegate>
@property (strong, nonatomic)  UIWebView *webView;
@property (nonatomic) BOOL firstLoad;
@end

@implementation TreeholeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _firstLoad = YES;
    [self setupWebView];
    [MobClick event:@"Public_Treehole"];
}

- (void)setupWebView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];

    _webView.delegate = self;
    _webView.opaque = NO;
    _webView.backgroundColor = [UIColor clearColor];

    [self.view addSubview:_webView];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.openstu.com/"]];

    [_webView loadRequest:request];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    _firstLoad = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    if (_firstLoad) {
        
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"错误" andMessage:@"加载失败"];
        
        alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        
        [alertView addButtonWithTitle:@"不去了" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        [alertView addButtonWithTitle:@"再试一次" type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.openstu.com/"]];
            [_webView loadRequest:request];
        }];
        
        [alertView show];
        
    } else {
        [self showHUDWithText:@"加载失败，请重试" andHideDelay:0.8];
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

- (IBAction)goBackPress:(id)sender
{
    [_webView goBack];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
