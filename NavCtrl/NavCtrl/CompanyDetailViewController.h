//
//  NewCompanyViewController.h
//  NavCtrl
//
//  Created by Imran on 11/2/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Company;

@interface CompanyDetailViewController : UIViewController

@property (nonatomic, retain) Company *company;
@property (nonatomic, copy) void(^completionHandler)(void);

@end
