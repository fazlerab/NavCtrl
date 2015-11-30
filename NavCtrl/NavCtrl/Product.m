//
//  Product.m
//  NavCtrl
//
//  Created by Imran on 10/28/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import "Product.h"

@implementation Product

- (instancetype) init {
    return [self initWithName:@"" andURL:@""];
}

- (instancetype) initWithName:(NSString *)name andURL:(NSString *)URL {
    return [self initWithId:0 name:name URL:URL companyId:0 listOrder:0];
}

// Designated Initializer
- (instancetype) initWithId:(NSUInteger)id name:(NSString *)name URL:(NSString *)URL companyId:(NSUInteger)companyId listOrder:(NSUInteger)listOrder {
    self = [super init];
    if (self) {
        _id = id;
        _name = [name copy];
        _URL = [URL copy];
        _companyId = companyId;
        _listOrder = listOrder;
    }
    return self;
   
}

- (void) dealloc {
    [_name release];
    [_URL release];
    [super dealloc];
}

@end
