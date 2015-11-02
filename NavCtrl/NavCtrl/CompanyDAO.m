//
//  CompanyDAO.m
//  NavCtrl
//
//  Created by Imran on 11/2/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CompanyDAO.h"
#import "Company.h"
#import "Product.h"

@interface CompanyDAO()
{
    NSMutableArray *_companyList;
}
@end

@implementation CompanyDAO
+ (CompanyDAO *) sharedInstance {
    static CompanyDAO *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initPrivate];
    });
    
    return sharedInstance;
}
/* -------------------------------------------------------- */

- (instancetype) init {
    [NSException raise:@"Singleton"
                format:@"Use +[CompanyDAO sharedInstance"];
    return nil;
}

- (instancetype) initPrivate {
    self = [super init];
    if (self) {
        _companyList = [[NSMutableArray alloc] init];
        [self buildCompanyData];
    }
    return self;
}

/* ------------------------------------------------------------------------------ */

- (NSArray *) getCompanyList {
    return _companyList;
}

- (Company *) getCompanyAtIndex:(NSInteger)index {
    return [_companyList objectAtIndex:index];
}

- (void) deleteCompanyAtIndex:(NSInteger)index {
    [_companyList removeObjectAtIndex:index];
}

- (void) moveCompanyFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    [_companyList exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
}

- (Company *) getCompanyByName:(NSString *)name {
    Company *c = nil;
    
    for (c in _companyList) {
        if ( [c.name isEqualToString:name] ) {
            break;
        }
    }
    
    return c;
}


/* ------------------------------------------------------------------------- */

- (NSArray *) getProductsByCompany:(NSString *)companyName {
    Company *c = [self getCompanyByName:companyName];
    return c.products;
}

- (Product *) getProductAtIndex:(NSInteger)index forCompanyName:(NSString *)companyName {
    NSArray *productList = [self getProductsByCompany:companyName];
    return [productList objectAtIndex:index];
}

- (void) removeProductAtIndex:(NSInteger)index forCompanyName:(NSString *)companyName {
    Company *c = [self getCompanyByName:companyName];
    [c removeProductAtIndex:index];
}

- (void) moveProductFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex forCompanyName:(NSString *)companyName {
    Company *c = [self getCompanyByName:companyName];
    [c moveProductFromIndex:fromIndex toIndex:toIndex];
}


/* ----------------------------------------------------------------------------------------------- */
- (void) buildCompanyData {
    Company *company;
    
    company = [[Company alloc] initWithName:@"Apple mobile devices" icon:@"apple.png"];
    [company addProduct:[[Product alloc] initWithName:@"iPad Air 2" andURL:@"https://www.apple.com/ipad-air-2/"]];
    [company addProduct:[[Product alloc] initWithName:@"Watch"      andURL:@"https://www.apple.com/watch/"]];
    [company addProduct:[[Product alloc] initWithName:@"iPhone 6S"  andURL:@"https://www.apple.com/iphone-6s/"]];
    [_companyList addObject:company];
    
    company = [[Company alloc] initWithName:@"Samsung mobile devices" icon:@"samsung.png"];
    [company addProduct:[[Product alloc] initWithName:@"Galaxy S6"   andURL:@"http://www.samsung.com/us/mobile/cell-phones/SM-G928VZDAVZW"]];
    [company addProduct:[[Product alloc] initWithName:@"Galaxy Note" andURL:@"http://www.samsung.com/us/mobile/cell-phones/SM-N920TZKATMB"]];
    [company addProduct:[[Product alloc] initWithName:@"Galaxy Tab"  andURL:@"http://www.samsung.com/us/mobile/galaxy-tab/SM-T810NZWEXAR"]];
    [_companyList addObject:company];
    
    company = [[Company alloc] initWithName:@"Motorola mobile devices" icon:@"motorola.png"];
    [company addProduct:[[Product alloc] initWithName:@"Moto X" andURL:@"https://www.motorola.com/us/products/moto-x-pure-edition"]];
    [company addProduct:[[Product alloc] initWithName:@"Moto G" andURL:@"https://www.motorola.com/us/products/moto-g"]];
    [company addProduct:[[Product alloc] initWithName:@"Moto E" andURL:@"https://www.motorola.com/us/smartphones/moto-e-2nd-gen/moto-e-2nd-gen.html"]];
    [_companyList addObject:company];
    
    company = [[Company alloc] initWithName:@"LG mobile devices" icon:@"lg.jpg"];
    [company addProduct:[[Product alloc] initWithName:@"Nexus 5X"     andURL:@"https://www.google.com/nexus/5x/"]];
    [company addProduct:[[Product alloc] initWithName:@"G4"           andURL:@"http://www.lg.com/us/mobile-phones/g4"]];
    [company addProduct:[[Product alloc] initWithName:@"G Pad X 10.1" andURL:@"http://www.lg.com/us/tablets/lg-V930-g-pad-x-10.1"]];
    [_companyList addObject:company];
}
@end