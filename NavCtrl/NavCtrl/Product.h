//
//  Product.h
//  NavCtrl
//
//  Created by Imran on 10/28/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject <NSCoding>

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *URL;

// Designated Initializer
- (instancetype) initWithName:(NSString *)name andURL:(NSString *)URL NS_DESIGNATED_INITIALIZER;

@end
