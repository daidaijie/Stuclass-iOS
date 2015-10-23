//
//  ClassCollectionViewLayout.m
//  stuclass
//
//  Created by JunhaoWang on 10/12/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "ClassCollectionViewLayout.h"
#import "ClassBackgroundCollectionReusableView.h"
#import "ClassNumberCollectionReusableView.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

static const NSInteger kAmountOfClasses = 13;

@interface ClassCollectionViewLayout ()

@property (assign, nonatomic) CGFloat numWidth;
@property (assign, nonatomic) CGFloat cellWidth;

@property (assign, nonatomic) NSInteger cellCount;

@end


@implementation ClassCollectionViewLayout


- (void)prepareLayout
{
    [super prepareLayout];
    
    // calculating
    CGFloat k = SCREEN_WIDTH / 320.0;
    self.cellWidth = 42.5 * k;
    self.numWidth = 22.5 *k;
    self.cellCount = [self.layoutDelegate collectionView:self.collectionView cellCountForCollectionViewLayout:self];
    
    // register for DecorationView
    [self registerClass:[ClassBackgroundCollectionReusableView class] forDecorationViewOfKind:@"ClassBackground"];
    
    // register for SupplementaryView
    [self registerClass:[ClassNumberCollectionReusableView class] forDecorationViewOfKind:@"ClassNumber"];
}


- (CGSize)collectionViewContentSize
{
    return CGSizeMake(SCREEN_WIDTH, self.cellWidth * kAmountOfClasses);
}


// layoutAttrsForElementsInRect
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSMutableArray *attributes = [[NSMutableArray alloc] init];
    
    // DecorationView
    for (int i = 0; i < kAmountOfClasses; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [attributes addObject:[self layoutAttributesForDecorationViewOfKind:@"ClassBackground" atIndexPath:indexPath]];
    }
    
    // SupplementaryView
    for (int i = 0; i < kAmountOfClasses; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [attributes addObject:[self layoutAttributesForSupplementaryViewOfKind:@"ClassNumber" atIndexPath:indexPath]];
    }
    
    // Cell
    for (int i = 0; i < self.cellCount; i++) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    
    
    return attributes;
}


// layoutForCell
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *att = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    NSArray *coordinate = [self.layoutDelegate collectionView:self.collectionView coordinateForCollectionViewLayout:self indexPath:indexPath];
    
    NSInteger x = [coordinate[0] integerValue];
    NSInteger y = [coordinate[1] integerValue];
    NSInteger length = [coordinate[2] integerValue];
    
    att.frame = CGRectMake(self.numWidth + self.cellWidth * x, self.cellWidth * y, self.cellWidth, self.cellWidth * length);
    
//    [self printRect:att.frame andIndex:indexPath.row];
    
    return att;
}

// layoutForDecorationView
- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *att = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:elementKind withIndexPath:indexPath];
    
    CGRect f = CGRectMake(self.numWidth, 0, SCREEN_WIDTH, self.cellWidth);
    
    f.origin.y = indexPath.row * f.size.height;
    
    att.frame = f;
    
    att.zIndex = -1;
    
//    [self printRect:f andIndex:indexPath.row];
    
    return att;
}

// layoutForSupplementaryView
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *att = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    
    CGRect f = CGRectMake(0, 0, self.numWidth, self.cellWidth);
    
    f.origin.y = indexPath.row * f.size.height;
    
    att.frame = f;
    
//    [self printRect:f andIndex:indexPath.row];
    
    return att;
}



- (void)printRect:(CGRect)rect andIndex:(NSInteger)index {
    NSLog(@"index - %d   rect (%.1f, %.1f, %.1f, %.1f)", index, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}



@end






















