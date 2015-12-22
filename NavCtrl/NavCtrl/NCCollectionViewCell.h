//
//  NCCollectionViewCell.h
//  NavCtrl
//
//  Created by Imran on 12/15/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCCollectionViewCellActionDelegate.h"

@interface NCCollectionViewCell : UICollectionViewCell

@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *subTitleLabel;

@property (assign, nonatomic) id<NCCollectionViewCellActionDelegate> actionButtonDelegate;

@property (nonatomic, getter=isEditing) BOOL editing;

@end
