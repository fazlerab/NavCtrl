//
//  Company.m
//  NavCtrl
//
//  Created by Imran on 11/30/15.
//  Copyright © 2015 Fazle Rab. All rights reserved.
//

#import "Company.h"
#import "Product.h"

@interface Company()

@property (nonatomic, retain) NSMutableArray<Product *> *productList;

@end
@implementation Company

- (instancetype) initWithName:(NSString *)name icon:(NSString *)icon stockSymbol:(NSString *)stockSymbol listOrder:(NSUInteger)listOrder {
    self = [super init];
    if (self) {
        _name = name;
        _icon = icon;
        _stockSymbol = stockSymbol;
        _listOrder = listOrder;
        _productList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (instancetype) initWithName:(NSString *)name icon:(NSString *)icon {
    return [self initWithName:name icon:icon stockSymbol:@"" listOrder:0];
}

- (NSArray<Product *> *) products {
    return self.productList;
}

- (void)setProducts:(NSArray<Product *> *)products {
    [self setProductList:[products mutableCopy]];
}

- (void)addProduct:(Product *)product {
    product.listOrder = self.products.count;
    [self.productList addObject:product];
}

- (void)removeProductAtIndex:(NSUInteger)index {
    [self.productList removeObjectAtIndex:index];
    for (NSUInteger i = index; i < self.products.count; i++) {
        self.productList[i].listOrder--;
    }
}

- (Product *)productAtIndex:(NSUInteger)index {
    return [self.productList objectAtIndex:index];
}

- (void)moveProductFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    if (fromIndex == toIndex) return;
    
    Product *productAtToIndex = [self.productList objectAtIndex:toIndex];
    NSUInteger toListOrder = productAtToIndex.listOrder;
    
    if (toIndex < fromIndex) {
        for (NSUInteger i = toIndex; i < fromIndex; i++) {
            [self.productList objectAtIndex:i].listOrder++;
        }
    } else {
        for (NSUInteger i = fromIndex + 1; i <= toIndex; i++) {
            [self.productList objectAtIndex:i].listOrder--;
        }
    }
    
    Product *productAtFromIndex = [[self.productList objectAtIndex:fromIndex] retain];
    productAtFromIndex.listOrder = toListOrder;
    
    [self.productList removeObjectAtIndex:fromIndex];
    [self.productList insertObject:productAtFromIndex atIndex:toIndex];
    
    [productAtFromIndex release];
}

@end
