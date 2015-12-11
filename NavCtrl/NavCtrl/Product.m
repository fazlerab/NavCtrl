//
//  Product.m
//  NavCtrl
//
//  Created by Imran on 11/30/15.
//  Copyright © 2015 Fazle Rab. All rights reserved.
//

#import "Product.h"
#import "Company.h"

@implementation Product

- (instancetype) initWithName:(NSString *)name URL:(NSString *)url {
    return [self initWithName:name URL:url listOrder:0];
}

- (instancetype) initWithName:(NSString *)name URL:(NSString *)url listOrder:(NSUInteger)listOrder {
    self = [super init];
    if (self) {
        _name = name;
        _url = url;
        _listOrder = listOrder;
    }
    return self;
}

@end
