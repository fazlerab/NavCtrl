//
//  Company.m
//  NavCtrl
//
//  Created by Imran on 11/30/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import "Company.h"
#import "Product.h"

@implementation Company

// Insert code here to add functionality to your managed object subclass
+ (NSString *) entityName {
    return @"Company";
}

- (void)addProduct:(Product *)product {
    [self addProductsObject:product];
}

- (void)removeProduct:(Product *)product {
    [self removeProductsObject:product];
}

@end
