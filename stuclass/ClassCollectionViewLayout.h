//
//  ClassCollectionViewLayout.h
//  stuclass
//
//  Created by JunhaoWang on 10/12/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ClassCollectionViewLayout;

@protocol ClassCollectionViewLayoutDelegate <NSObject>

@required

// get cellCount
- (NSInteger)collectionView:(UICollectionView *)collectionView cellCountForCollectionViewLayout:(ClassCollectionViewLayout *)collectionViewLayout;

// get coordinate
- (NSArray *)collectionView:(UICollectionView *)collectionView coordinateForCollectionViewLayout:(ClassCollectionViewLayout *)collectionViewLayout indexPath:(NSIndexPath *)indexPath;

@end


@interface ClassCollectionViewLayout : UICollectionViewLayout

@property (strong, nonatomic) id<ClassCollectionViewLayoutDelegate> layoutDelegate;

@end
