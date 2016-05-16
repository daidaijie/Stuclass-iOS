//
//  MessageTableViewCell.m
//  stuclass
//
//  Created by JunhaoWang on 10/24/15.
//  Copyright © 2015 JunhaoWang. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "Define.h"

@interface MessageTableViewCell () <UIScrollViewDelegate>

//@property (strong, nonatomic) UIView *bottomLine;

@end

@implementation MessageTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    [super awakeFromNib];
    
    // ScrollManager
    _manager = [ScrollManager sharedManager];
    
    // messageImgView
    self.messageImgView.clipsToBounds = YES;
    self.messageImgView.cell = self;
    
    // avatarImageView
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.size.width / 2.0;
    self.avatarImageView.clipsToBounds = YES;
//    self.avatarImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    self.avatarImageView.layer.borderWidth = 0.3;
}


- (void)setPage:(int)page
{
    CGFloat pageWidth = [UIScreen mainScreen].bounds.size.width;
    float offset_X = pageWidth * page;
    [_messageImgView.scrollView setContentOffset:CGPointMake(offset_X, _messageImgView.scrollView.contentOffset.y)];
    _currentPage = page;
    _messageImgView.pageControl.currentPage = page;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int page = fabs(scrollView.contentOffset.x) / [UIScreen mainScreen].bounds.size.width;
    _currentPage = page;
    _messageImgView.pageControl.currentPage = page;
    [_manager setpage:_currentPage ForKey:[NSString stringWithFormat:@"%i",self.tag]];
}


- (void)setContentImages:(NSArray *)contentImages
{
    _messageImgView.scrollView.delegate = self;
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = width * 0.618;
    
    if (contentImages == nil || contentImages.count == 0) {
        // nope
        _messageImgView.pageControl.numberOfPages = 0;
        _messageImgView.imageView1.image = nil;
        _messageImgView.imageView2.image = nil;
        _messageImgView.imageView3.image = nil;
        
        _messageImgView.scrollView.contentSize = CGSizeMake(width, height);
        
    } else if (contentImages.count == 1) {
        // 1 image
        _messageImgView.imageView1.image = contentImages[0];
        _messageImgView.imageView2.image = nil;
        _messageImgView.imageView3.image = nil;
        _messageImgView.pageControl.numberOfPages = 1;
        
        _messageImgView.scrollView.contentSize = CGSizeMake(width, height);
        
    } else if (contentImages.count == 2) {
        // 2 images
        _messageImgView.imageView1.image = contentImages[0];
        _messageImgView.imageView2.image = contentImages[1];
        _messageImgView.imageView3.image = nil;
        _messageImgView.pageControl.numberOfPages = 2;
        
        _messageImgView.scrollView.contentSize = CGSizeMake(width * 2, height);
        
    } else if (contentImages.count == 3) {
        // 3 images
        _messageImgView.imageView1.image = contentImages[0];
        _messageImgView.imageView2.image = contentImages[1];
        _messageImgView.imageView3.image = contentImages[2];
        
        _messageImgView.pageControl.numberOfPages = 3;
        
        _messageImgView.scrollView.contentSize = CGSizeMake(width * 3, height);
    }
}

- (IBAction)morePress:(id)sender
{
//    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"更多" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//    [controller addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *alertAction){
//        
//    }]];
//    [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *alertAction){
//        
//    }]];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"更多" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil];
    [actionSheet showInView:self];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end






