//
//  MessageTitleButton.m
//  stuclass
//
//  Created by JunhaoWang on 5/28/16.
//  Copyright © 2016 JunhaoWang. All rights reserved.
//

#import "MessageTitleButton.h"

@interface MessageTitleButton ()

@property (strong, nonatomic) UIView *alertView;

@end


@implementation MessageTitleButton



- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 7, 7)];
    _alertView.center = CGPointMake(self.frame.size.width / 2 + 36, self.frame.size.height / 2);
    _alertView.backgroundColor = [UIColor colorWithRed:1.000 green:0.738 blue:0.236 alpha:1.000];
    _alertView.layer.cornerRadius = _alertView.frame.size.width / 2;
    _alertView.hidden = YES;
    [self addSubview:_alertView];
}

- (void)setAlertViewVisible:(BOOL)visilbe
{
    _alertView.hidden = !visilbe;
}



@end
