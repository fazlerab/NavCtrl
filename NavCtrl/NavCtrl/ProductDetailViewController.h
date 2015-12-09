//
//  NewProductViewController.h
//  NavCtrl
//
//  Created by Imran on 11/3/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Product;
@class Company;

@interface ProductDetailViewController : UIViewController

@property (nonatomic, retain) Company *company;
@property (nonatomic, retain) Product *product;
@property (nonatomic, copy) void(^completionHandler)(void);

@end
