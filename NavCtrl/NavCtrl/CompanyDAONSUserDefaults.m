//
//  CompanyDAONSUserDefaultsImpl.m
//  NavCtrl
//
//  Created by Fazle Rab on 11/10/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import "CompanyDAONSUserDefaults.h"

NSString * const NAV_CTRL_COMPANY_DATA = @"NavCtrl-CompanyData";


@implementation CompanyDAONSUserDefaults

- (instancetype) init {
    return [super init];
}

- (NSArray *) loadData {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"%@-%@: userDefaults=%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [userDefaults dictionaryRepresentation]);

    NSData *companyData = [userDefaults objectForKey:NAV_CTRL_COMPANY_DATA];
    
    NSArray *companyList = nil;
    if (companyData) {
         companyList = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:companyData];
    }
    
    if (!companyList || [companyList count] == 0) {
        companyList = [super loadData];
    }
    
    return companyList;
}

- (void) saveData {
    NSLog(@"%@.%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    
    NSArray *companyList = [super getCompanyList];
    NSData *companyData = [NSKeyedArchiver archivedDataWithRootObject:companyList];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:companyData forKey:NAV_CTRL_COMPANY_DATA];
}

@end
