//
//  Product.h
//  NavCtrl
//
//  Created by Imran on 10/28/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject

@property (nonatomic) NSUInteger id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *URL;
@property (nonatomic) NSUInteger companyId;
@property (nonatomic) NSUInteger listOrder;

- (instancetype) initWithName:(NSString *)name andURL:(NSString *)URL;

// Designated Initializer
- (instancetype) initWithId:(NSUInteger)id name:(NSString *)name URL:(NSString *)URL companyId:(NSUInteger)companyId listOrder:(NSUInteger)listOrder NS_DESIGNATED_INITIALIZER;

@end
