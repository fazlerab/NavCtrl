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

@interface NavCtrlDAO : NSObject

+ (NavCtrlDAO *) sharedInstance;

@property (nonatomic, retain) NSDictionary *stockQuotes;

// MARK: Company methods
- (void) loadCompanyList:(void(^)(void))completionBlock;

- (void) deleteCompanyAtIndex:(NSInteger)index;

- (void) addCompany:(Company *)company completionBlock:(void(^)(void))completionBlock;

- (void) updateCompany:(Company *)company completionBlock:(void(^)(void))completionBlock;

- (void) moveCompanyFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex completionBlock:(void(^)(void))completion;

- (NSArray<Company *> *) getCompanyList;
- (void) setCompanyList:(NSArray<Company *> *)companyList;

- (Company *) getCompanyAtIndex:(NSInteger)index;

- (Company *) getCompanyByName:(NSString *)name;

- (void) undoCompany: (void(^)(void))completion;
- (void) redoCompany:(void(^)(void))completion;

- (BOOL) canUndoCompany;
- (BOOL) canRedoCompany;


// MARK: Product methods
- (void) loadProductsForCompany:(Company *)company completionBlock:(void(^)(void))completionBlock;

- (void) removeProductAtIndex:(NSInteger)index forCompany:(Company*)company;

- (void) moveProductFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex forCompany:(Company *)company completionBlock:(void(^)(void))completion;

- (void) addProduct:(Product *)product forCompany:(Company *)company completionBlock:(void(^)(void))completionBlock;

- (void) updateProduct:(Product *)product forCompany:(Company *)company completionBlock:(void(^)(void))completionBlock;

- (NSArray *) getProductsByCompany:(Company *)company;

- (Product *) getProductAtIndex:(NSInteger)index forCompany:(Company *)company;

- (void) undoProductForCompany: (Company *)company CompletionBlock: (void(^)(void))completion;
- (void) redoProductForCompany: (Company *)company CompletionBlock: (void(^)(void))completion;

- (BOOL) canUndoProduct;
- (BOOL) canRedoProduct;


// MARK: Fetch Stock Quotes methods
- (void) fetchStockQuotes:(void(^)(void))fetchDidFinish;
- (NSString *) getStockQuoteForSymbol:(NSString *)symbol;
- (NSDictionary *)stockQuotes;
- (void)setStockQuotes:(NSDictionary *)stockQuotes;

@end
