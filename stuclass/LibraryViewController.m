//
//  LibraryViewController.m
//  stuclass
//
//  Created by JunhaoWang on 4/9/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "LibraryViewController.h"
#import "LibraryTextField.h"
#import <KVNProgress/KVNProgress.h>
#import <AFNetworking/AFNetworking.h>
#import "Define.h"
#import "BookResultTableViewController.h"

#define LIBRARY_URL @"http://202.192.155.48:83/opac/searchresult.aspx"

@interface LibraryViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *libraryImageView;
@property (weak, nonatomic) IBOutlet LibraryTextField *textField;

@end

@implementation LibraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupBackBarButton];
    [self setupViewForiPhone4];
}



- (void)setupBackBarButton
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
}

- (void)setupViewForiPhone4
{
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    if (height == 480.0) {
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) {
            // iOS 7.1
            NSLog(@"iPhone 4(s) - 7.1");
            self.libraryImageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
            CATransform3D t = CATransform3DMakeScale(0.8, 0.8, 0);
            t = CATransform3DTranslate(t, 43, -15, 0);
            self.libraryImageView.layer.transform = t;
            CGAffineTransform t2 = CGAffineTransformMakeTranslation(0, -155);
            self.textField.transform = t2;
        } else {
            // iOS 8
            NSLog(@"iPhone 4(s) - 8.0");
            CGAffineTransform t1 = CGAffineTransformMakeScale(0.85, 0.85);
            t1 = CGAffineTransformTranslate(t1, 0, -33);
            self.libraryImageView.transform = t1;
            CGAffineTransform t2 = CGAffineTransformMakeTranslation(0, -70);
            self.textField.transform = t2;
        }
    } else {
        return;
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.textField becomeFirstResponder];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 0) {
        // 保存历史记录
        [self.textField resignFirstResponder];
        [self sendRequestWithText:textField.text];
        return YES;
    } else {
        return NO;
    }
}

- (void)sendRequestWithText:(NSString *)text
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [KVNProgress showWithStatus:@"正在获取图书信息"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
    manager.requestSerializer.stringEncoding = enc;
    manager.requestSerializer.timeoutInterval = global_timeout;
    NSDictionary *parameters = @{@"ANYWORDS": text};
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:LIBRARY_URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSString *responseHtml = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"成功");
        [self getResultNumWithResponseHtml:responseHtml];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"失败 - %@", error);
        [KVNProgress showErrorWithStatus:global_connection_failed completion:^{
            [self.textField becomeFirstResponder];
        }];
    }];
}


- (void)getResultNumWithResponseHtml:(NSString *)responseHtml
{
    // 获取结果数
    NSString *pantten = [NSString stringWithFormat:@"<span>结果数：<span id=\"ctl00_ContentPlaceHolder1_countlbl\"><font color=\"Red\">(.*?)</font></span>"];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pantten options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators error:NULL];
    NSTextCheckingResult *result = [regex firstMatchInString:responseHtml options:0 range:NSMakeRange(0, [responseHtml length])];
    if (result) {
        // 得到结果数 > 0
        NSString *resultNumStr = [responseHtml substringWithRange:[result rangeAtIndex:1]];
        NSUInteger resultNum = [resultNumStr integerValue];
        NSLog(@"结果数: %lu", (unsigned long)resultNum);
        // 处理结果数
        [self dealWithResultNum:resultNum responseHtml:responseHtml];
    } else {
        // 获取结果数
        NSString *pantten = [NSString stringWithFormat:@"<span>结果数：<span id=\"ctl00_ContentPlaceHolder1_notfoundcountlbl\"><font color=\"Red\">(.*?)</font></span>"];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pantten options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators error:NULL];
        NSTextCheckingResult *result = [regex firstMatchInString:responseHtml options:0 range:NSMakeRange(0, [responseHtml length])];
        if (result) {
            // 得到结果数 - 0
            NSString *resultNumStr = [responseHtml substringWithRange:[result rangeAtIndex:1]];
            NSUInteger resultNum = [resultNumStr integerValue];
            NSLog(@"结果数: %lu", (unsigned long)resultNum);
            // 处理结果数
            [self dealWithResultNum:resultNum responseHtml:responseHtml];
        } else {
            // 一般不会发生 - 未知错误
            [KVNProgress showErrorWithStatus:global_connection_failed completion:^{
                [self.textField becomeFirstResponder];
            }];
        }
    }
}


- (void)dealWithResultNum:(NSUInteger)resultNum responseHtml:(NSString *)responseHtml
{
    // 处理结果数
    if (resultNum > 0) {
        // 有结果
        [self getResultBookWithResponseHtml:responseHtml resultNum:resultNum];
    } else {
        // 无结果
        [KVNProgress showErrorWithStatus:@"没有你要检索的书目" completion:^{
            [self.textField becomeFirstResponder];
        }];
    }
}


- (void)getResultBookWithResponseHtml:(NSString *)responseHtml resultNum:(NSUInteger)resultNum
{
    // 获取检索信息
    NSString *pattern = [NSString stringWithFormat:@"<td><input type=\"checkbox\" name=\"searchresult_cb\" value=\".*?\" onclick=\"savethis\\(this\\);\"/>.*?</td>\\s*<td><span class=\"title\"><a href=\".*?\" target=\"_blank\">(.*?)</a></span></td>\\s*<td>(.*?)</td>\\s*<td>(.*?)</td>\\s*<td>.*?</td>\\s*<td class=\"tbr\">(.*?)</td>\\s*<td class=\"tbr\">.*?</td>\\s*<td class=\"tbr\">(.*?)</td>"];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators error:NULL];
    
    NSArray *matchedArray = [regex matchesInString:responseHtml options:0 range:NSMakeRange(0, responseHtml.length)];
    if (matchedArray.count > 0) {
        // 匹配成功
        NSMutableArray *bookData = [NSMutableArray array];
        for (NSTextCheckingResult *result in matchedArray) {
            NSDictionary *book = @{
                                   @"name": [responseHtml substringWithRange:[result rangeAtIndex:1]],
                                   @"author": [responseHtml substringWithRange:[result rangeAtIndex:2]],
                                   @"publisher": [responseHtml substringWithRange:[result rangeAtIndex:3]],
                                   @"index": [responseHtml substringWithRange:[result rangeAtIndex:4]],
                                   @"available": [responseHtml substringWithRange:[result rangeAtIndex:5]]
                                   };
            [bookData addObject:book];
        }
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BookResultTableViewController *brtvc = [sb instantiateViewControllerWithIdentifier:@"brtvc"];
        
        [brtvc setAnywords:self.textField.text];
        [brtvc setBookData:bookData resultNum:resultNum];
        
        [KVNProgress dismiss];
        [self.navigationController pushViewController:brtvc animated:YES];
    } else {
        NSLog(@"没有匹配");
        // 一般不会发生 - 未知错误
        [KVNProgress showErrorWithStatus:global_connection_failed completion:^{
            [self.textField becomeFirstResponder];
        }];
    }
}












- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
