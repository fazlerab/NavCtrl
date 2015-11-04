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

// Designated Initializer
- (instancetype) initWithName:(NSString *)name andURL:(NSString *)URL {
    self = [super init];
    if (self) {
        _name = [name copy];
        _URL = [URL copy];
    }
    return self;
}


@end
