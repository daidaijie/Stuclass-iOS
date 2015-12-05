//
//  ClassCollectionViewCell.h
//  stuget
//
//  Created by JunhaoWang on 7/19/15.
//  Copyright (c) 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ClassButton;

@protocol ClassCollectionViewCellDelegate <NSObject>

- (void)classCollectionViewCellDidPressWithTag:(NSInteger)tag;

@end


@interface ClassCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) ClassButton *btn;

@property (strong, nonatomic) UILabel *label;

@property (weak, nonatomic) id<ClassCollectionViewCellDelegate>delegate;

- (void)setBtnColor:(UIColor *)color;

@end
