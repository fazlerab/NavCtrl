//
//  Product.h
//  NavCtrl
//
//  Created by Imran on 11/30/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Company;

NS_ASSUME_NONNULL_BEGIN

@interface Product : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+ (NSString *) entityName;

@end

NS_ASSUME_NONNULL_END

#import "Product+CoreDataProperties.h"
