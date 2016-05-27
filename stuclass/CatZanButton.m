//
//  CatZanButton.m
//  CatZanButton
//
//  Created by K-cat on 15/7/13.
//  Copyright (c) 2015年 K-cat. All rights reserved.
//

#import "CatZanButton.h"
#import "Define.h"

@interface CatZanButton (){
    CAEmitterLayer *_effectLayer;
    CAEmitterCell *_effectCell;
    UIImage *_zanImage;
    UIImage *_unZanImage;
    CGRect kFrame;
    CGPoint kCenter;
}

@end

@implementation CatZanButton


-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        _zanImage=[UIImage imageNamed:@"icon-like-selected"];
        _unZanImage=[UIImage imageNamed:@"icon-like"];
        _type=CatZanButtonTypeFirework;
        [self initKFrameCenter];
        [self initBaseLayout];
    }
    return self;
}

- (void)initKFrameCenter
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat offset = 29.0;
    
    if (width == 375.0) {
        offset = 37.0;
    } else if (width == 414.0) {
        offset = 45.0;
    }
    
    CGFloat icon_width = 16;
    kFrame = CGRectMake(0, 0, icon_width, icon_width);
    kCenter = CGPointMake(offset , self.frame.size.height / 2);
}

/**
 *  Init base layout
 */
-(void)initBaseLayout
{
    switch (_type) {
        case CatZanButtonTypeFirework:{
            
            
            _effectLayer=[CAEmitterLayer layer];
            [_effectLayer setFrame:CGRectMake(0, 0, 20, 20)];
            [self.layer addSublayer:_effectLayer];
            [_effectLayer setEmitterShape:kCAEmitterLayerCircle];
            [_effectLayer setEmitterMode:kCAEmitterLayerOutline];
            [_effectLayer setEmitterPosition:kCenter];
            [_effectLayer setEmitterSize:CGSizeMake(20, 20)];
            
            _effectCell=[CAEmitterCell emitterCell];
            [_effectCell setName:@"zanShape"];
            [_effectCell setContents:(__bridge id)[UIImage imageNamed:@"EffectImage"].CGImage];
            [_effectCell setAlphaSpeed:-1.0f];
            [_effectCell setLifetime:0.8f];
            [_effectCell setBirthRate:0];
            [_effectCell setVelocity:20];
            [_effectCell setVelocityRange:20];
            
            [_effectLayer setEmitterCells:@[_effectCell]];
            
            self.imageView.frame = kFrame;
            self.imageView.center = kCenter;
            [self setImage:_unZanImage forState:UIControlStateNormal];
        }
            break;
        case CatZanButtonTypeFocus:{
            
        }
            break;
        default:
            break;
    }
}

/**
 *  An animation for zan action
 */
- (void)setWithStatus:(BOOL)isLike withAnimation:(BOOL)animate
{
    [self setIsZan:isLike];
    if (animate) {
        switch (_type) {
            case CatZanButtonTypeFirework:{
                [self.imageView setBounds:CGRectMake(0, 0, 0, 0)];
                
                [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:5 options:UIViewAnimationOptionCurveLinear animations:^{
                    [self.imageView setBounds:kFrame];
                    self.imageView.center = kCenter;
                    if (isLike) {
                        CABasicAnimation *effectLayerAnimation=[CABasicAnimation animationWithKeyPath:@"emitterCells.zanShape.birthRate"];
                        [effectLayerAnimation setFromValue:[NSNumber numberWithFloat:10]];
                        [effectLayerAnimation setToValue:[NSNumber numberWithFloat:0]];
                        [effectLayerAnimation setDuration:0.0f];
                        [effectLayerAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
                        [_effectLayer addAnimation:effectLayerAnimation forKey:@"ZanCount"];
                    }
                } completion:^(BOOL finished) {
                }];
            }
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - Property method
- (void)setIsZan:(BOOL)isZan
{
    if (isZan) {
        [self setImage:_zanImage forState:UIControlStateNormal];
        [self setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    } else {
        [self setImage:_unZanImage forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithWhite:0.5 alpha:1.0] forState:UIControlStateNormal];
    }
}


@end
