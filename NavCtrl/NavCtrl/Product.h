//
//  Product.h
//  NavCtrl
//
//  Created by Imran on 11/30/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Company;

@interface Product : NSObject

@property (nonatomic, retain) NSURL *managedObjectURI;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *url;
@property (nonatomic) NSUInteger listOrder;

- (instancetype) initWithName:(NSString *)name URL:(NSString *)url;
- (instancetype) initWithName:(NSString *)name URL:(NSString *)url listOrder:(NSUInteger)listOrder;

@end
