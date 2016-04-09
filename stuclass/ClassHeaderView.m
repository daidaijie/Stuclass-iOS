//
//  ClassHeaderView.m
//  stuget
//
//  Created by JunhaoWang on 7/19/15.
//  Copyright (c) 2015 JunhaoWang. All rights reserved.
//

#import "ClassHeaderView.h"
#import "StartView.h"
#import "WeekView.h"
#import "JHDater.h"
#import "Define.h"

#define LINE_WIDTH 0.4
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

@interface ClassHeaderView ()

@property (strong, nonatomic) NSMutableArray *weekViewArray;

@end


@implementation ClassHeaderView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // backGround
        self.backgroundColor = [UIColor clearColor];
        
        // 日期生成器
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat k = width / 320.0;
        
        // 左上角方格
        CGFloat startViewWidth = 22.5 * k;
        StartView *startView = [[StartView alloc] initWithFrame:CGRectMake(0, 0, startViewWidth, frame.size.height)];
        [self addSubview:startView];
        
        // 星期标签
        CGFloat weekViewWidth = 42.5 * k;
        
        _weekViewArray = [NSMutableArray array];
        
        for (NSUInteger i = 0; i < 7; i++) {
            WeekView *weekView = [[WeekView alloc] initWithFrame:CGRectMake(startViewWidth + i * weekViewWidth, 0, weekViewWidth-0.4, frame.size.height-0.4)];
            
            weekView.weekLabel.text = [self weekStrForWeek:i];
            weekView.dateLabel.text = [self dateAtWeekIndex:i];
            
            weekView.backgroundColor = [self colorForDay:i];

            [_weekViewArray addObject:weekView];
            [self addSubview:weekView];
        }
    }
    
    return self;
}

- (NSString *)weekStrForWeek:(NSInteger)week
{
    NSString *weekStr;
    
    switch (week) {
        case 0:
            weekStr = @"周一";
            break;
        case 1:
            weekStr = @"周二";
            break;
        case 2:
            weekStr = @"周三";
            break;
        case 3:
            weekStr = @"周四";
            break;
        case 4:
            weekStr = @"周五";
            break;
        case 5:
            weekStr = @"周六";
            break;
        case 6:
            weekStr = @"周日";
            break;
        default:
            break;
    }
    
    return weekStr;
}


- (NSString *)dateAtWeekIndex:(NSUInteger)i
{
    NSDate *todayDate = [NSDate date];
    NSInteger todayWeek = [[JHDater sharedInstance] weekForDate:todayDate];
    NSDate *weekDate = [[JHDater sharedInstance] dateAfterDay:i - todayWeek];
    
    return [[JHDater sharedInstance] dateStringForDate:weekDate withFormate:@"d日"];
}


- (UIColor *)colorForDay:(NSUInteger)i
{
    NSDate *todayDate = [NSDate date];
    NSInteger todayWeek = [[JHDater sharedInstance] weekForDate:todayDate];
    
    return (todayWeek == i) ? [UIColor colorWithWhite:1.0 alpha:0.45] : [UIColor colorWithWhite:1.0 alpha:0.2];
}


- (void)updateCurrentDateOnClassHeaderView
{
    for (NSUInteger i = 0; i < self.weekViewArray.count; i++) {
        
        WeekView *weekView = self.weekViewArray[i];
        
        weekView.weekLabel.text = [self weekStrForWeek:i];
        weekView.dateLabel.text = [self dateAtWeekIndex:i];
        
        weekView.backgroundColor = [self colorForDay:i];
        
    }
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat k = SCREEN_WIDTH / 320.0;
    CGFloat n = 22.5 * k;
    CGFloat w = 42.5 * k;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, MAIN_COLOR.CGColor);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, LINE_WIDTH);
    
    // --
    CGContextMoveToPoint(context,  0, height - LINE_WIDTH / 2);
    CGContextAddLineToPoint(context, width, height - LINE_WIDTH / 2);
    CGContextStrokePath(context);
    
    // |
    for (int i = 0; i < 6; i++) {
        
        CGContextMoveToPoint(context, n + w * (i + 1) - LINE_WIDTH / 2, 0);
        CGContextAddLineToPoint(context, n + w * (i + 1) - LINE_WIDTH / 2, height);
        CGContextStrokePath(context);
    }
}


@end
