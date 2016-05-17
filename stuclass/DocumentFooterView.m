//
//  OfficeDocumentFooterView.h
//  stuclass
//
//  Created by JunhaoWang on 7/24/15.
//  Copyright (c) 2015 JunhaoWang. All rights reserved.
//

#import "DocumentFooterView.h"

@interface DocumentFooterView ()

@property (strong, nonatomic) UIActivityIndicatorView *aiv;

@end


@implementation DocumentFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _aiv.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        _aiv.hidesWhenStopped = YES;
        [self addSubview:_aiv];
    }
    
    return self;
}


- (void)showLoading
{
    [_aiv startAnimating];
}


- (void)hideLoading
{
    [_aiv stopAnimating];
}


- (void)showEnd
{
    [_aiv stopAnimating];
    self.frame = CGRectMake(0, 0, 320, 1.4f);
}


@end
