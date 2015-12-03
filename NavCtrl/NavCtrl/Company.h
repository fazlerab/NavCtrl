//
//  Company.h
//  NavCtrl
//
//  Created by Imran on 11/30/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product;

NS_ASSUME_NONNULL_BEGIN

@interface Company : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+ (NSString *) entityName;

- (void)addProduct:(Product *)product;
- (void)removeProduct:(Product *)product;

@end

NS_ASSUME_NONNULL_END

#import "Company+CoreDataProperties.h"
