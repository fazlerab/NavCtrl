//
//  Company.h
//  NavCtrl
//
//  Created by Imran on 11/30/15.
//  Copyright © 2015 Fazle Rab. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Product;

@interface Company : NSObject

@property (nonatomic, retain) NSURL *managedObjectURI;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *icon;
@property (nonatomic, retain) NSString *stockSymbol;
@property (nonatomic) NSUInteger listOrder;
@property (nonatomic, retain) NSArray<Product *> *products;

- (instancetype) initWithName:(NSString *)name icon:(NSString *)icon stockSymbol:(NSString *)stockSymbol listOrder:(NSUInteger)listOrder;
- (instancetype) initWithName:(NSString *)name icon:(NSString *)icon;

- (void)addProduct:(Product *)product;
- (void)removeProductAtIndex:(NSUInteger)index;
- (Product *)productAtIndex:(NSUInteger)index;
- (void)moveProductFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
@end


