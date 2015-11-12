//
//  CompanyDAOSaveToFile.m
//  NavCtrl
//
//  Created by Imran on 11/10/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import "CompanyDAOFileArchive.h"


@implementation CompanyDAOFileArchive

- (instancetype) init {
    return [super init];
}

- (NSArray *) loadData {
    NSArray *companyList = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithFile:[self archivePath]];
    NSLog(@"%@-%@: companyList=%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), companyList);
    
    if (!companyList || [companyList count] == 0) {
        companyList = [super loadData];
    }
    
    return companyList;
}

- (void) saveData {
    NSLog(@"%@.%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    
    NSArray *companyList = [super getCompanyList];
    [NSKeyedArchiver archiveRootObject:companyList toFile:[self archivePath]];
}

- (NSString *) archivePath {
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [directories firstObject];
    return [documentDir stringByAppendingPathComponent:@"NavCtrl.archive"];
}

@end
