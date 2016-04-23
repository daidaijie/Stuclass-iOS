//
//  BookResultTableViewController.m
//  stuclass
//
//  Created by JunhaoWang on 7/23/15.
//  Copyright (c) 2015 JunhaoWang. All rights reserved.
//

#import "BookResultTableViewController.h"
#import "LibraryTableViewCell.h"
#import "LibraryFooterView.h"
#import <AFNetworking/AFNetworking.h>
#import "Define.h"
#import "MBProgressHUD.h"
#import "BookDetailViewController.h"

#define LIBRARY_URL @"http://202.192.155.48:83/opac/searchresult.aspx"

#define LIBRARY_BOOK_URL @"http://202.192.155.48:83/opac/"

@interface BookResultTableViewController () <UITableViewDelegate>
@property (nonatomic) BOOL isLoading;
@end

@implementation BookResultTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupBackBarButton];
    [self setupTableView];
}

- (void)setupBackBarButton
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
}

- (void)setBookData:(NSMutableArray *)bookData resultNum:(NSUInteger)resultNum
{
    _resultNum = resultNum;
    _bookData = bookData;
    // 是否显示结束标签
    if (_bookData.count == _resultNum) {
//        [(FooterView *)self.tableView.tableFooterView showEnd];
        UIView *endFooterView = [[UIView alloc] initWithFrame:CGRectMake(8.6f, 0, self.tableView.bounds.size.width-8.6f, 0.3)];
        endFooterView.backgroundColor = TABLEVIEW_BACKGROUN_COLOR;
        self.tableView.tableFooterView = endFooterView;
    }
}


- (void)setupTableView
{
    LibraryFooterView *footerView = [[LibraryFooterView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 50)];
    self.tableView.sectionHeaderHeight = 24.0;
    self.tableView.rowHeight = 68.0;
    self.tableView.tableFooterView = footerView;

    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPressGesture.minimumPressDuration = 0.4;
    [self.tableView addGestureRecognizer:longPressGesture];
}



// 设置Row行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _bookData.count;
}


// 设置Section颜色
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // 颜色
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [header.textLabel setTextColor:MAIN_COLOR];
    header.contentView.backgroundColor = TABLEVIEW_BACKGROUN_COLOR;
}


// 设置Section数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


// 设置Section标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return [NSString stringWithFormat:@"与 %@ 有关的%lu条结果", _anywords, (unsigned long)_resultNum];
    } else {
        return @"0条";
    }
}


// 设置Row数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    
    LibraryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BOOKCELL"];
    
    cell.nameLabel.text = _bookData[row][@"name"];
    cell.authorLabel.text = _bookData[row][@"author"];
    cell.publisherLabel.text = _bookData[row][@"publisher"];
    cell.indexLabel.text = _bookData[row][@"index"];
    NSString *availableStr = _bookData[row][@"available"];
    cell.availableLabel.text = availableStr;
    [cell setAvailableLabelColor:[availableStr integerValue]];
    
    return cell;
}


// 加载更多数据
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ((scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y < self.tableView.tableFooterView.bounds.size.height) && (_bookData.count < _resultNum) && (!_isLoading)) {
        [self getNewBooks];
    }
}

// 发送新的请求
- (void)getNewBooks
{
    
    _isLoading = YES;
    [(LibraryFooterView *)self.tableView.tableFooterView showLoading];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *encodeStr = [NSString stringWithFormat:@"%@", CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)_anywords, (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]", NULL, kCFStringEncodingGB_18030_2000)];
    
    NSInteger page = _bookData.count / 20 + 1;
    NSString *urlStr = [NSString stringWithFormat:@"%@?ANYWORDS=%@&PAGE=%d", LIBRARY_URL, encodeStr, page];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:global_timeout];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (!connectionError) {
            
            NSLog(@"图书 - 成功");
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [self dealWithHtml:responseStr];
        } else {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            NSLog(@"图书 - 失败 - %@", connectionError);
            [self showHUDWithText:global_connection_failed andHideDelay:0.8];
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height-self.tableView.frame.size.height-self.tableView.tableFooterView.frame.size.height) animated:NO];
            [(LibraryFooterView *)self.tableView.tableFooterView hideLoading];
            _isLoading = NO;
        }
        
    }];
}

// 解析新的请求
- (void)dealWithHtml:(NSString *)responseHtml
{
    // 获取检索信息
    NSString *pattern = [NSString stringWithFormat:@"<td><input type=\"checkbox\" name=\"searchresult_cb\" value=\".*?\" onclick=\"savethis\\(this\\);\"/>.*?</td>\\s*<td><span class=\"title\"><a href=\"(.*?)\" target=\"_blank\">(.*?)</a></span></td>\\s*<td>(.*?)</td>\\s*<td>(.*?)</td>\\s*<td>.*?</td>\\s*<td class=\"tbr\">(.*?)</td>\\s*<td class=\"tbr\">.*?</td>\\s*<td class=\"tbr\">(.*?)</td>"];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators error:NULL];
    
    NSArray *matchedArray = [regex matchesInString:responseHtml options:0 range:NSMakeRange(0, responseHtml.length)];
    if (matchedArray.count > 0) {
        // 匹配成功
        NSMutableArray *bookData = [NSMutableArray array];
        for (NSTextCheckingResult *result in matchedArray) {
            
            NSDictionary *book = @{
                                   @"link": [responseHtml substringWithRange:[result rangeAtIndex:1]],
                                   @"name": [responseHtml substringWithRange:[result rangeAtIndex:2]],
                                   @"author": [responseHtml substringWithRange:[result rangeAtIndex:3]],
                                   @"publisher": [responseHtml substringWithRange:[result rangeAtIndex:4]],
                                   @"index": [responseHtml substringWithRange:[result rangeAtIndex:5]],
                                   @"available": [responseHtml substringWithRange:[result rangeAtIndex:6]]
                                   };
            [bookData addObject:book];
        }
        [self addNewBooksWith:bookData];
    } else {
        NSLog(@"没有匹配");
        // 一般不会发生 - 未知错误 - 网页被修改了
        [self showHUDWithText:global_connection_failed andHideDelay:0.8];
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height-self.tableView.frame.size.height-self.tableView.tableFooterView.frame.size.height) animated:NO];
        [(LibraryFooterView *)self.tableView.tableFooterView hideLoading];
        _isLoading = NO;
    }
}

// 设置新的数据
- (void)addNewBooksWith:(NSMutableArray *)bookData
{
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [_bookData addObjectsFromArray:bookData];
    [self.tableView reloadData];
    [(LibraryFooterView *)self.tableView.tableFooterView hideLoading];
    if (_bookData.count >= _resultNum) {
        UIView *endFooterView = [[UIView alloc] initWithFrame:CGRectMake(8.6f, 0, self.tableView.bounds.size.width - 8.6f, 0.3)];
        endFooterView.backgroundColor = TABLEVIEW_BACKGROUN_COLOR;
        self.tableView.tableFooterView = endFooterView;
    }
    _isLoading = NO;
}


#pragma mark - HUD

- (void)showHUDWithText:(NSString *)string andHideDelay:(NSTimeInterval)delay {
    
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];

    if (self.navigationController.view) {

        if (delay == 0) {

            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = string;
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            [hud show:YES];

        } else {

            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = string;
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:delay];
        }
    }
}


- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [gesture locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
        if (indexPath == nil) return;

        NSUInteger row = indexPath.row;

        NSString *bookURLStr = _bookData[row][@"link"];

        if (bookURLStr) {

            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            BookDetailViewController *bdvc = [sb instantiateViewControllerWithIdentifier:@"bdvc"];
            
            bdvc.url = [NSString stringWithFormat:@"%@%@", LIBRARY_BOOK_URL, bookURLStr];
            
            UINavigationController *nvc = [[UINavigationController alloc] init];
            
            nvc.viewControllers = @[bdvc];
            
            [self presentViewController:nvc animated:YES completion:nil];
        }
    }
}

// 解析
- (void)dealBookWithHtml:(NSString *)responseHtml
{
    // 获取检索信息
    NSString *pattern = [NSString stringWithFormat:@"<td><input type=\"checkbox\" name=\"searchresult_cb\" value=\".*?\" onclick=\"savethis\\(this\\);\"/>.*?</td>\\s*<td><span class=\"title\"><a href=\"(.*?)\" target=\"_blank\">(.*?)</a></span></td>\\s*<td>(.*?)</td>\\s*<td>(.*?)</td>\\s*<td>.*?</td>\\s*<td class=\"tbr\">(.*?)</td>\\s*<td class=\"tbr\">.*?</td>\\s*<td class=\"tbr\">(.*?)</td>"];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators error:NULL];

    NSArray *matchedArray = [regex matchesInString:responseHtml options:0 range:NSMakeRange(0, responseHtml.length)];
    if (matchedArray.count > 0) {
        // 匹配成功
        NSMutableArray *bookData = [NSMutableArray array];
        for (NSTextCheckingResult *result in matchedArray) {

            NSDictionary *book = @{
                    @"link": [responseHtml substringWithRange:[result rangeAtIndex:1]],
                    @"name": [responseHtml substringWithRange:[result rangeAtIndex:2]],
                    @"author": [responseHtml substringWithRange:[result rangeAtIndex:3]],
                    @"publisher": [responseHtml substringWithRange:[result rangeAtIndex:4]],
                    @"index": [responseHtml substringWithRange:[result rangeAtIndex:5]],
                    @"available": [responseHtml substringWithRange:[result rangeAtIndex:6]]
            };
            [bookData addObject:book];
        }
        [self addNewBooksWith:bookData];
    } else {
        NSLog(@"没有匹配");
        // 一般不会发生 - 未知错误 - 网页被修改了
        [self showHUDWithText:global_connection_failed andHideDelay:0.8];
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height-self.tableView.frame.size.height-self.tableView.tableFooterView.frame.size.height) animated:NO];
        [(LibraryFooterView *)self.tableView.tableFooterView hideLoading];
        _isLoading = NO;
    }
}


@end
