//
//  ProductViewController.h
//  NavCtrl
//
//  Created by Aditya Narayan on 10/22/13.
//  Copyright (c) 2013 Aditya Narayan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Product;
@class Company;

@interface ProductViewController : UITableViewController

@property (nonatomic, retain) Company *company;

- (void) addProduct:(Product *)product;
- (void) updateProduct:(Product *)product;

@end
