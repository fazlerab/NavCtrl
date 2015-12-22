//
//  NCCollectionViewCellButtonDelegate.h
//  NavCtrl
//
//  Created by Imran on 12/17/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NCCollectionViewCell;

// The NCCollectionViewCell calls the delegate when its buttons are pressed.
@protocol NCCollectionViewCellActionDelegate <NSObject>

- (void) handleDetail:(NCCollectionViewCell *)sender;
- (void) handleDelete:(NCCollectionViewCell *)sender;

@end
