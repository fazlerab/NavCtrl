//
//  NCCollectionViewCell.m
//  NavCtrl
//
//  Created by Imran on 12/15/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import "NCCollectionViewCell.h"

@interface NCCollectionViewCell()

@property (retain, nonatomic) IBOutlet UIButton *detailButton;
@property (retain, nonatomic) IBOutlet UIButton *deleteButton;
@property (retain, nonatomic) IBOutlet UIView *detailButtonView;
@property (retain, nonatomic) IBOutlet UIView *mainView;

@end
@implementation NCCollectionViewCell

static int const ButtonWidth = 38;

- (void)awakeFromNib {
    // Initialization code
    _editing = NO;
    _titleLabel.text = @"";
    _subTitleLabel.text = @"";
    
    [self.detailButton addTarget: self
                          action: @selector(handleDetailButton:)
                forControlEvents: UIControlEventTouchUpInside];
    
    [self.deleteButton addTarget: self
                          action: @selector(handleDeleteButton:)
                forControlEvents: UIControlEventTouchUpInside];
}

- (void) revealButtons:(BOOL)reveal {
    CGRect bounds = self.mainView.bounds;
    
    int newWidth = reveal ? self.bounds.size.width - (2 * ButtonWidth) : self.bounds.size.width;
    CGRect newBounds = CGRectMake(bounds.origin.x, bounds.origin.y, newWidth, bounds.size.height);
    
    if (reveal) {
        self.detailButtonView.hidden = NO;
        self.deleteButton.hidden = NO;
    }
    
    [UIView animateWithDuration: 0.2
                     animations: ^{
                         [self.mainView setBounds:newBounds];
                     }
                     completion: ^(BOOL finished){
                         if (!reveal) {
                             self.detailButtonView.hidden = YES;
                             self.deleteButton.hidden = YES;
                         }
                     }];
}

- (void) setEditing:(BOOL)editing {
    [self revealButtons:editing];
}

- (void) handleDetailButton: (UIButton *)sender {
    if (self.actionButtonDelegate) {
        [self.actionButtonDelegate handleDetail:self];
    }
}

- (void) handleDeleteButton: (UIButton *)sender {
    if (self.actionButtonDelegate) {
        [self.actionButtonDelegate handleDelete:self];
    }
}

- (void) prepareForReuse {
    [self.imageView setImage:nil];
    [self.titleLabel setText:@""];
    [self.subTitleLabel setText:@""];
    [super prepareForReuse];
}

- (void)dealloc {
    [_imageView release];
    [_titleLabel release];
    [_subTitleLabel release];
    [_detailButton release];
    [_deleteButton release];
    [_actionButtonDelegate release];
    [_detailButtonView release];
    [_mainView release];
    [super dealloc];
}

@end
