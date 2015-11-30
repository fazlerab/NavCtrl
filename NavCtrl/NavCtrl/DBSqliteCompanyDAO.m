//
//  DBSqliteCompanyDAO.m
//  NavCtrl
//
//  Created by Imran on 11/18/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import <sqlite3.h>
#import "DBSqliteCompanyDAO.h"
#import "Company.h"
#import "Product.h"


@interface DBSqliteCompanyDAO ()

@property (nonatomic) dispatch_queue_t dispatchQueue;
@property (nonatomic, retain) NSString *databasePath;

@end

@implementation DBSqliteCompanyDAO

- (dispatch_queue_t) dispatchQueue {
    if (!_dispatchQueue) {
        _dispatchQueue = dispatch_queue_create("navctrlQ", NULL);
        dispatch_retain(_dispatchQueue);
    }
    return _dispatchQueue;
}

/*
 * Initializes Database.  Copies database file from app bundle to user's documents directory,
 * if it does not exist.  Creates database tables if they do not exist.
 */
- (void) createDatabase {
    if (self.databasePath) return;
    
    NSString *databaseFile = @"navctrl.db";
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *destinationPath = [documentPath stringByAppendingPathComponent:databaseFile];
    
    NSLog(@"destinationPath: %@", destinationPath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Check if database file exist in user's documents directory.
    // If not, copy database file from resource bundle to user's doucments directory.
    if (![fileManager fileExistsAtPath:destinationPath]) {
        NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseFile];
        NSLog(@"sourcePath: %@", sourcePath);
        
        NSError *error = nil;
        [fileManager copyItemAtPath:sourcePath toPath:destinationPath error:&error];
        
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
            return;
        }
    }
    
    self.databasePath = destinationPath;
    
    // Create tables if they don't exist
    NSString *query1 = @"CREATE TABLE IF NOT EXISTS company ("
                            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                            "list_order INTEGER NOT NULL, "
                            "name TEXT NOT NULL UNIQUE, "
                            "icon TEXT, "
                            "stock_symbol TEXT)";

    NSString *query2 = @"CREATE TABLE IF NOT EXISTS product ("
                            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                            "list_order INTEGER NOT NULL, "
                            "name TEXT NOT NULL UNIQUE, "
                            "URL TEXT, "
                            "company_id INTEGER, "
                            "FOREIGN KEY(company_id) REFERENCES company(id))";
    
    
    dispatch_async(self.dispatchQueue, ^{
        [self queryDatabaseWithSQLs:@[query1, query2] rowProcessorBlock:nil];
    });

}


/*
 * Logs any database error and closes the database connection
 */
- (void) logDBError:(sqlite3 *)database errorCode:(int)code  {
    NSString *errmsg = [NSString stringWithUTF8String: sqlite3_errmsg(database)];
    sqlite3_close_v2(database);
    
    NSLog(@"-- Database Error: %@", errmsg);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc] initWithTitle: @"Database Error"
                                    message: errmsg
                                   delegate: nil
                          cancelButtonTitle: @"OK"
                          otherButtonTitles: nil]
         show];
    });

}


/*
 * Central place to process all database call. This method is called in asynchronous queue, so that it does not 
 * block the main queue.
 *
 * Arguments:
 * - sqlStmts: list of sql statments to execute.
 * - rowProcessorBlock: A block to process rows returned by SQL excecution on SELECT.
 */
- (BOOL) queryDatabaseWithSQLs: (NSArray<NSString *> *) sqlStmts
             rowProcessorBlock:(void(^)(sqlite3_stmt *ppStmt)) processRow {
    
    [self createDatabase];
    //NSLog(@"queryDataWithSQLs: %@", sqlStmts);
    
    int result;
    sqlite3 *database;
    sqlite3_stmt *preparedStmt;

    // Open database connection
    result = sqlite3_open_v2([[self databasePath] UTF8String], &database, SQLITE_OPEN_READWRITE, NULL);
    if (result != SQLITE_OK) {
        [self logDBError:database errorCode:result];
        return NO;
    }
    
    // Prepare and execute each SQL statment
    for (NSString *stmt in sqlStmts) {
        // Prepare SQL statement
        result = sqlite3_prepare_v2(database, [stmt UTF8String], -1, &preparedStmt, NULL);
        if (result != SQLITE_OK) {
            [self logDBError:database errorCode:result];
            return NO;
        }
    
        // Excute SQL statement
        while ( (result = sqlite3_step(preparedStmt)) == SQLITE_ROW) {
            if (processRow) processRow(preparedStmt);
        }
        
        if (result != SQLITE_DONE) {
            [self logDBError:database errorCode:result];
            return NO;
        }
        
        
        sqlite3_finalize(preparedStmt);
    }

    // Close database connection
    sqlite3_close_v2(database);
    return YES;
}


/*
 * Loads the company list
 */
- (void) loadCompanyList: (void (^)(void))completionBlock {
    NSString *query = @"SELECT id, name, icon, stock_symbol, list_order "
                            "FROM company ORDER BY list_order ASC";
    
    dispatch_async(self.dispatchQueue, ^{
        NSMutableArray<Company *> *companies = [[NSMutableArray alloc] init];
        
        [self queryDatabaseWithSQLs: @[query]
                  rowProcessorBlock: ^(sqlite3_stmt *ppStmt) {
                      Company *company = [[Company alloc] initWithId: sqlite3_column_int(ppStmt, 0)
                                                                name: [NSString stringWithUTF8String: (const char *)sqlite3_column_text(ppStmt, 1)]
                                                                icon: [NSString stringWithUTF8String: (const char *)sqlite3_column_text(ppStmt, 2)]
                                                         stockSymbol: [NSString stringWithUTF8String: (const char *)sqlite3_column_text(ppStmt, 3)]
                                                           listOrder: sqlite3_column_int(ppStmt, 4)];
                      [companies addObject:company];
                      [company release];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [super setCompanyList:companies];
            [companies release];
            completionBlock();
        });
    });
}


- (void) moveCompanyFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    if (fromIndex == toIndex) return;
    
    Company *fromCompany = [super getCompanyAtIndex:fromIndex];
    Company *toCompany = [super getCompanyAtIndex:toIndex];
    
    // Queries to switch listOrder to the two companies
    NSString *query1 = nil;
    if (toIndex < fromIndex) {
        query1 = [NSString stringWithFormat:
                  @"UPDATE company SET list_order = list_order + 1 "
                    "WHERE list_order >= %lu AND list_order < %lu",
                  (unsigned long)toCompany.listOrder, (unsigned long)fromCompany.listOrder];
    } else {
        query1 = [NSString stringWithFormat:
                  @"UPDATE company SET list_order = list_order - 1 "
                    "WHERE list_order > %lu AND list_order <= %lu",
                  (unsigned long)fromCompany.listOrder, (unsigned long)toCompany.listOrder];
    }

    NSString *query2 = [NSString stringWithFormat:
                        @"UPDATE company SET list_order = %lu WHERE id = %lu",
                        (unsigned long)toCompany.listOrder, (unsigned long)fromCompany.id];
    
    dispatch_async(self.dispatchQueue, ^{
        BOOL success = [self queryDatabaseWithSQLs:@[query1, query2] rowProcessorBlock:nil];
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [super moveCompanyFromIndex:fromIndex toIndex:toIndex];
            });
        }
    });
}


- (void) deleteCompanyAtIndex:(NSInteger)index  {
    Company *company = [[self getCompanyAtIndex:index] retain];
    [super deleteCompanyAtIndex:index];
    
    // Query to delete the given company
    NSString *query1 = [NSString stringWithFormat:
                        @"DELETE FROM company WHERE id=%lu", (unsigned long)company.id];
    // Query to delete products of the given company
    NSString *query2 = [NSString stringWithFormat:
                        @"DELETE FROM product WHERE company_id=%lu", (unsigned long)company.id];
    // Query to update the list numbers
    NSString *query3 = [NSString stringWithFormat:
                        @"UPDATE company SET list_order = list_order - 1 WHERE list_order > %lu", (unsigned long)index];
    
    dispatch_async(self.dispatchQueue, ^{
        [self queryDatabaseWithSQLs:@[query1, query2, query3] rowProcessorBlock:nil];
        [company release];
    });
}


- (void) addCompany:(Company *)company completionBlock:(void (^)(void))completionBlock{
    NSString *query1 = [NSString stringWithFormat:
                        @"INSERT INTO company (name, icon, stock_symbol, list_order) "
                         "SELECT '%s', '%s', '%s', IFNULL(MAX(list_order)+1,0) FROM company",
                        [company.name UTF8String], [company.icon UTF8String], [company.stockSymbol UTF8String]];
    
    NSString *query2 = [NSString stringWithFormat:
                        @"SELECT id, list_order FROM company WHERE name='%s'", [company.name UTF8String]];
    
    dispatch_async(self.dispatchQueue, ^{
        BOOL success = [self queryDatabaseWithSQLs: @[query1, query2]
                                 rowProcessorBlock: ^(sqlite3_stmt *ppStmt) {
                                     company.id = sqlite3_column_int(ppStmt, 0);
                                     company.listOrder = sqlite3_column_int(ppStmt, 1);
                                 }];
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [super addCompany:company completionBlock:completionBlock];
            });
        }
    });
}


- (void) updateCompany:(Company *)company completionBlock:(void (^)(void))completionBlock {
    NSString *query = [NSString stringWithFormat:
                       @"UPDATE company SET name='%s', icon='%s', stock_symbol='%s' WHERE id=%lu",
                       [company.name UTF8String], [company.icon UTF8String], [company.stockSymbol UTF8String], (unsigned long)company.id];
    
    BOOL success = [self queryDatabaseWithSQLs:@[query] rowProcessorBlock:nil];
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [super updateCompany:company completionBlock:completionBlock];
        });
    }
}

- (void) loadProductsForCompany:(NSString *)companyName completionBlock:(void(^)(void))completionBlock {
    Company *company = [super getCompanyByName:companyName];
    
    NSString *query = [NSString stringWithFormat:
                       @"SELECT id, name, URL, company_id, list_order "
                          "FROM product WHERE company_id=%lu ORDER BY list_order ASC",
                       (unsigned long)company.id];
    
    dispatch_async(self.dispatchQueue, ^{
        NSMutableArray<Product *> *products = [[NSMutableArray alloc] init];
        
        [self queryDatabaseWithSQLs: @[query]
                  rowProcessorBlock: ^(sqlite3_stmt *ppStmt) {
                      Product *product = [[Product alloc] initWithId: sqlite3_column_int(ppStmt, 0)
                                                                name: [NSString stringWithUTF8String: (const char *)sqlite3_column_text(ppStmt, 1)]
                                                                 URL: [NSString stringWithUTF8String: (const char *)sqlite3_column_text(ppStmt, 2)]
                                                           companyId: sqlite3_column_int(ppStmt, 3)
                                                           listOrder: sqlite3_column_int(ppStmt, 4)];
                      [products addObject:product];
                      [product release];
                  }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [company setProducts:products];
            [products release];
            completionBlock();
        });

        
    });
}


- (void) addProduct:(Product *)product forCompanyName:(NSString *)companyName completionBlock:(void (^)(void))completionBlock{
    Company *company = [super getCompanyByName:companyName];
    product.companyId = company.id;
    
    NSString *query1 = [NSString stringWithFormat:
                        @"INSERT INTO product (name, URL, company_id, list_order) "
                         "SELECT '%s', '%s', %lu, IFNULL(MAX(list_order)+1,0) "
                           "FROM product WHERE company_id=%lu",
                        [product.name UTF8String], [product.URL UTF8String], (unsigned long)product.companyId, (unsigned long)product.companyId];
    NSString *query2 = [NSString stringWithFormat:
                        @"SELECT id, list_order FROM product "
                          "WHERE company_id = %lu AND name = '%s'",
                        (unsigned long)product.companyId, [product.name UTF8String]];
    
    dispatch_async(self.dispatchQueue, ^{
        BOOL success = [self queryDatabaseWithSQLs:@[query1, query2] rowProcessorBlock:^(sqlite3_stmt *ppStmt) {
            product.id = sqlite3_column_int(ppStmt, 0);
            product.listOrder = sqlite3_column_int(ppStmt, 1);
        }];
        
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [super addProduct:product forCompanyName:companyName completionBlock:completionBlock];
            });
        }
        
    });
}


- (void) updateProduct:(Product *)product forCompanyName:(NSString *)companyName completionBlock:(void (^)(void))completionBlock {
    NSString *query = [NSString stringWithFormat:
                       @"UPDATE product SET name='%s', URL='%s' WHERE id=%lu",
                       [product.name UTF8String], [product.URL UTF8String], (unsigned long)product.id];
    
    dispatch_async(self.dispatchQueue, ^{
        BOOL success = [self queryDatabaseWithSQLs:@[query] rowProcessorBlock:nil];
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [super updateProduct:product forCompanyName:companyName completionBlock:completionBlock];
            });
        }
    });
}


- (void) removeProductAtIndex:(NSInteger)index forCompanyName:(NSString *)companyName {
    Product *product = [[super getProductAtIndex:index forCompanyName:companyName] retain];
    [super removeProductAtIndex:index forCompanyName:companyName];
    
    NSString *query1 = [NSString stringWithFormat:
                        @"DELETE FROM product WHERE id=%lu", (unsigned long)product.id];
    NSString *query2 = [NSString stringWithFormat:
                        @"UPDATE product SET list_order = list_order - 1 "
                          "WHERE company_id = %lu AND list_order > %lu",
                        (unsigned long)product.companyId, (unsigned long)product.listOrder];
    
    dispatch_async(self.dispatchQueue, ^{
        [self queryDatabaseWithSQLs:@[query1, query2] rowProcessorBlock:nil];
        [product release];
    });
}


- (void) moveProductFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex forCompanyName:(NSString *)companyName {
    if (fromIndex == toIndex) return;
    
    Product *fromProduct = [super getProductAtIndex:fromIndex forCompanyName:companyName];
    Product *toProduct = [super getProductAtIndex:toIndex forCompanyName:companyName];
    
    NSString *query1;
    if (toIndex < fromIndex) {
        query1 = [NSString stringWithFormat:
                  @"UPDATE product SET list_order = list_order + 1 "
                    "WHERE company_id = %lu AND list_order >= %lu AND list_order < %lu",
                  (unsigned long)fromProduct.companyId, (unsigned long)toProduct.listOrder, (unsigned long)fromProduct.listOrder];
    } else {
        query1 = [NSString stringWithFormat:
                  @"UPDATE product SET list_order = list_order - 1 "
                    "WHERE company_id = %lu AND list_order > %lu AND list_order <= %lu",
                  (unsigned long)fromProduct.companyId, (unsigned long)fromProduct.listOrder, (unsigned long)toProduct.listOrder];
    }
    
    NSString *query2 = [NSString stringWithFormat:@"UPDATE product SET list_order = %lu WHERE id = %lu",
                        (unsigned long)toProduct.listOrder, (unsigned long)fromProduct.id];
    
    dispatch_async(self.dispatchQueue, ^{
        BOOL success = [self queryDatabaseWithSQLs:@[query1, query2] rowProcessorBlock:nil];
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [super moveProductFromIndex:fromIndex toIndex:toIndex forCompanyName:companyName];
            });
        }
    });
}

- (void) dealloc {
    dispatch_release(_dispatchQueue);
    [_databasePath release];
    [super dealloc];
}

@end
