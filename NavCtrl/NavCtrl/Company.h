//
//  Company.h
//  NavCtrl
//
//  Created by Imran on 10/28/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Product;

@interface Company : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *icon;
@property (nonatomic, retain) NSArray *products;

// Designated Initializer
- (instancetype) initWithName:(NSString *)name icon:(NSString *)icon NS_DESIGNATED_INITIALIZER;

- (void)addProduct:(Product *)product;
- (void)removeProductAtIndex:(NSUInteger)index;
- (void)moveProductFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)updateProduct:(Product *)product;

@end
