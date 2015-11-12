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
        _name = [name copy];
        _icon = [icon copy];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)decoder {
    NSString *name = [decoder decodeObjectForKey:@"name"];
    NSString *icon  = [decoder decodeObjectForKey:@"icon"];
    
    self =  [self initWithName:name icon:icon];
    if (self) {
        self.stockSymbol = [decoder decodeObjectForKey:@"stockSymbol"];
        self.products = [decoder decodeObjectForKey:@"products"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.icon  forKey:@"icon"];
    [encoder encodeObject:self.stockSymbol forKey:@"stockSymbol"];
    [encoder encodeObject:self.products forKey:@"products"];
}

- (void) setProducts:(NSArray *)products {
    _products = [[NSMutableArray alloc] initWithArray:[products copy]];
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

- (void) updateProduct:(Product *)product {
    if (_products) {
        for(int i = 0; i < _products.count; i++) {
            Product *p = [_products objectAtIndex:i];
            if ([p isEqual:product]) {
                [_products replaceObjectAtIndex:i withObject:product];
            }
        }
    }
}

- (void)moveProductFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    if (_products) {
        [_products exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[Company: name=%@, icon=%@]", self.name, self.icon];
}

@end
