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

- (void) loadCompanyList:(void(^)(void))completionBlock;

- (void) addCompany:(Company *)company completionBlock:(void(^)(void))completionBlock;

- (void) updateCompany:(Company *)company completionBlock:(void(^)(void))completionBlock;

- (NSArray<Company *> *) getCompanyList;

- (void) setCompanyList:(NSArray<Company *> *)companyList;

- (Company *) getCompanyAtIndex:(NSInteger)index;

- (void) deleteCompanyAtIndex:(NSInteger)index;

- (Company *) getCompanyByName:(NSString *)name;

- (void) moveCompanyFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;


- (void) loadProductsForCompany:(NSString *)companyName completionBlock:(void(^)(void))completionBlock;

- (void) addProduct:(Product *)product forCompanyName:(NSString *)companyName completionBlock:(void(^)(void))completionBlock;

- (void) updateProduct:(Product *)product forCompanyName:(NSString *)companyName completionBlock:(void(^)(void))completionBlock;

- (NSArray *) getProductsByCompany:(NSString *)companyName;

- (Product *) getProductAtIndex:(NSInteger)index forCompanyName:(NSString *)companyName;

- (void) removeProductAtIndex:(NSInteger)index forCompanyName:(NSString *)companyName;

- (void) moveProductFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex forCompanyName:(NSString *)companyName;

- (void) fetchStockQuotes:(void(^)(void))fetchDidFinish;

- (NSString *) getStockQuoteForSymbol:(NSString *)symbol;

@end
