//
//  Company.m
//  NavCtrl
//
//  Created by Imran on 10/28/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import "Company.h"

@interface Company()
{
    NSMutableArray *_products;
}
@end

@implementation Company

- (instancetype) init {
    return [self initWithName:@"" icon:@""];
}

// Designated initializer
- (instancetype) initWithName:(NSString *)name icon:(NSString *)icon {
    self = [super init];
    if (self) {
        _name = name;
        _icon = icon;
    }
    return self;
}

- (void) setProducts:(NSArray *)products {
    _products = [[NSMutableArray alloc] initWithArray:[products copy]];
}

- (NSArray *) getProducts {
    return _products;
}

- (void)addProduct:(Product *)product {
    if (!_products) {
        _products = [[NSMutableArray alloc] init];
    }
    [_products addObject:product];
}

- (void)removeProductAtIndex:(NSUInteger)index {
    if (_products) {
        [_products removeObjectAtIndex:index];
    }
}

- (void)moveProductFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    if (_products) {
        [_products exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
    }
}

@end
