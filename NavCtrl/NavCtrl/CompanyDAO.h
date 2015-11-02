//
//  CompanyDAO.h
//  NavCtrl
//
//  Created by Fazle Rab on 10/29/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Company;
@class Product;

@interface CompanyDAO : NSObject

+ (CompanyDAO *) sharedInstance;



- (NSArray *) getCompanyList;

- (Company *) getCompanyAtIndex:(NSInteger)index;

- (void) deleteCompanyAtIndex:(NSInteger)index;

- (Company *) getCompanyByName:(NSString *)name;

- (void) moveCompanyFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;


- (NSArray *) getProductsByCompany:(NSString *)companyName;

- (Product *) getProductAtIndex:(NSInteger)index forCompanyName:(NSString *)companyName;

- (void) removeProductAtIndex:(NSInteger)index forCompanyName:(NSString *)companyName;

- (void) moveProductFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex forCompanyName:(NSString *)companyName;

@end
