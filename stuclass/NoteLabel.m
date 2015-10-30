//
//  NoteLabel.m
//  stuclass
//
//  Created by JunhaoWang on 10/23/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "NoteLabel.h"

@implementation NoteLabel

@synthesize verticalAlignment = verticalAlignment_;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Alignment
    self.verticalAlignment = VerticalAlignmentTop;
    
    // Placeholder
    self.placeholder = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 28)];
    self.placeholder.textColor = [UIColor colorWithRed:0.804 green:0.804 blue:0.827 alpha:1.0];
    self.placeholder.font = [UIFont systemFontOfSize:16.0];
    self.placeholder.text = @"今天，我要认真听课...";
    
    [self addSubview:self.placeholder];
}

- (void)setVerticalAlignment:(VerticalAlignment)verticalAlignment
{
    verticalAlignment_ = verticalAlignment;
    [self setNeedsDisplay];
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    switch (self.verticalAlignment) {
        case VerticalAlignmentTop:
            textRect.origin.y = bounds.origin.y + 5;
            break;
        case VerticalAlignmentBottom:
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height;
            break;
        case VerticalAlignmentMiddle:
            // Fall through.
        default:
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0;
    }
    return textRect;
}

- (void)drawTextInRect:(CGRect)requestedRect
{
    CGRect actualRect = [self textRectForBounds:requestedRect limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:actualRect];
}


- (void)setText:(NSString *)text
{
    [super setText:text];
    
    if (text.length == 0 || text == nil) {
        self.placeholder.hidden = NO;
    } else {
        self.placeholder.hidden = YES;
    }
}




@end








