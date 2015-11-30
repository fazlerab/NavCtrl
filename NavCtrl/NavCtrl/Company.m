//
//  Company.m
//  NavCtrl
//
//  Created by Imran on 10/28/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import "Company.h"
#import "Product.h"

@interface Company()

@property (nonatomic, retain) NSMutableArray<Product *> *productList;

@end

@implementation Company

- (instancetype) init {
    return [self initWithName:@"" icon:@""];
}

- (instancetype) initWithName:(NSString *)name icon:(NSString *)icon {
    return [self initWithName:name icon:icon stockSymbol:@""];
}

- (instancetype) initWithName:(NSString *)name icon:(NSString *)icon stockSymbol:(NSString *)symbol {
    return [self initWithId:0 name:name icon:icon stockSymbol:symbol listOrder:0];
}

// Designated initializer
- (instancetype) initWithId:(NSUInteger)id name:(NSString *)name icon:(NSString *)icon stockSymbol:(NSString *)symbol listOrder:(NSUInteger)listOrder{
    self = [super init];
    if (self) {
        _id = id;
        _name = [name copy];
        _icon = [icon copy];
        _stockSymbol = [symbol copy];
        _listOrder = listOrder;
        _productList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray<Product *> *) products {
    return self.productList;
}

- (void) setProducts:(NSArray<Product *> *)products {
    [self.productList setArray:products];
}

- (void)addProduct:(Product *)product {
    [self.productList addObject:product];
}

- (void)removeProductAtIndex:(NSUInteger)index {
    [self.productList removeObjectAtIndex:index];
    
    for(NSUInteger i = index; i < self.productList.count; i++) {
        self.productList[i].listOrder--;
    }
}

- (void) updateProduct:(Product *)product {
    for(int i = 0; i < self.productList.count; i++) {
        Product *p = [self.productList objectAtIndex:i];
        if (p.id == product.id) {
            [self.productList replaceObjectAtIndex:i withObject:product];
        }
    }
}

- (void)moveProductFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    if (fromIndex == toIndex) return;
    
    Product *toProduct = [self.productList objectAtIndex:toIndex];
    NSUInteger toListOrder = toProduct.listOrder;
    
    if (toIndex < fromIndex) {
        for (NSUInteger i = toIndex; i < fromIndex; i++) {
            [self.productList objectAtIndex:i].listOrder++;
        }
    } else {
        for (NSUInteger i = fromIndex + 1; i <= toIndex; i++) {
            [self.productList objectAtIndex:i].listOrder--;
        }
    }
    
    Product *fromProduct = [[self.productList objectAtIndex:fromIndex] retain];
    fromProduct.listOrder = toListOrder;
    
    [self.productList removeObjectAtIndex:fromIndex];
    [self.productList insertObject:fromProduct atIndex:toIndex];
    
    [fromProduct release];
    
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[Company: name=%@, icon=%@]", self.name, self.icon];
}

- (void) dealloc {
    [_productList release];
    [_name release];
    [_icon release];
    [_stockSymbol release];
    [super dealloc];
}

@end
