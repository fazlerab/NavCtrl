//
//  CompanyDAO.m
//  NavCtrl
//
//  Created by Fazle Rab on 11/2/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CompanyDAO.h"
#import "Company.h"
#import "Product.h"
#import <sqlite3.h>
#import "DBSqliteCompanyDAO.h"

@interface CompanyDAO() {
    NSURLSession *_session;
}
@property (nonatomic, retain) NSMutableArray<Company *> *companies;
@property (nonatomic, retain) NSMutableDictionary *stockQuotes;

@end

@implementation CompanyDAO
+ (CompanyDAO *) sharedInstance {
    static CompanyDAO *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DBSqliteCompanyDAO alloc] init];
    });
    
    return sharedInstance;
}

/* ------------------------------------------------------------------------------ */
- (instancetype) init {
    self = [super init];
    if (self) {
        _companies = [[NSMutableArray alloc] init];
        _stockQuotes = [[NSMutableDictionary alloc] init];
    }
    return self;
}


// Company methods
- (void) loadCompanyList:(void (^)(void))completionBlock {
    [self loadData];
    completionBlock();
}

- (void) addCompany:(Company *)company completionBlock:(void (^)(void))completionBlock {
    [self.companies addObject:company];
    completionBlock();
}

- (void) updateCompany:(Company *)company completionBlock:(void (^)(void))completionBlock {
    for (int i = 0; i < self.companies.count; i++) {
        Company *c = [self.companies objectAtIndex:i];
        if ([c isEqual:company]) {
            [self.companies replaceObjectAtIndex:i withObject:company];
            break;
        }
    }
    completionBlock();
}

- (NSArray<Company *> *) getCompanyList {
    return self.companies;
}

- (void) setCompanyList:(NSArray<Company *> *)companies {
    [self.companies setArray:companies];
}

- (Company *) getCompanyAtIndex:(NSInteger)index {
    return [self.companies objectAtIndex:index];
}

- (void) deleteCompanyAtIndex:(NSInteger)index {
    [self.stockQuotes removeObjectForKey: [self getCompanyAtIndex:index].stockSymbol];
    
    [self.companies removeObjectAtIndex:index];
    for (NSUInteger i = index; i < self.companies.count; i++) {
        [self.companies objectAtIndex:i].listOrder--;
    }
}

- (void) moveCompanyFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    if (fromIndex == toIndex) return;
    
    Company *toCompany = [self getCompanyAtIndex:toIndex];
    NSUInteger toListOrder = toCompany.listOrder;
    
    if (toIndex < fromIndex) {
        for (NSUInteger i = toIndex; i < fromIndex; i++) {
            [self.companies objectAtIndex:i].listOrder++;
        }
    } else {
        for (NSUInteger i = fromIndex + 1; i <= toIndex; i++) {
            [self.companies objectAtIndex:i].listOrder--;
        }
    }
    
    Company *fromCompany = [[self getCompanyAtIndex:fromIndex] retain];
    fromCompany.listOrder = toListOrder;
    
    [self.companies removeObjectAtIndex:fromIndex];
    [self.companies insertObject:fromCompany atIndex:toIndex];
    
    [fromCompany release];
}

- (Company *) getCompanyByName:(NSString *)name {
    Company *c = nil;
    
    for (c in self.companies) {
        if ( [c.name isEqualToString:name] ) {
            break;
        }
    }
    
    return c;
}


/* -------------------------------------------------------------------------------- */
// Product methods

- (void) loadProductsForCompany:(NSString *)companyName completionBlock:(void(^)(void))completionBlock {
    // Only used by subclasses.
}

- (void) addProduct:(Product *)product forCompanyName:(NSString *)companyName completionBlock:(void(^)(void))completionBlock {
    Company *c = [self getCompanyByName:companyName];
    [c addProduct:product];
    completionBlock();
}

- (void) updateProduct:(Product *)product forCompanyName:(NSString *)companyName completionBlock:(void (^)(void))completionBlock {
    Company *c = [self getCompanyByName:companyName];
    [c updateProduct:product];
    completionBlock();
}

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
    for(NSUInteger i = index; i < c.products.count; i++) {
        c.products[i].listOrder--;
    }
}

- (void) moveProductFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex forCompanyName:(NSString *)companyName {
    Company *c = [self getCompanyByName:companyName];
    [c moveProductFromIndex:fromIndex toIndex:toIndex];
}


/* -------------------------------------------------------------------------------------------- */

// Fetches stock quotes of all the Compamy at once
- (void) fetchStockQuotes: (void(^)(void))fetchDidFinish {
    if (!self.companies || self.companies.count == 0) return;
    
    // Build a string of stock symbols by concatenating symbol from each company with '+' in between.
    NSMutableString *symbols = [[NSMutableString alloc] init];
    [self.companies enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Company *company = (Company *)obj;
        
        if (company.stockSymbol && ![company.stockSymbol isEqualToString:@""]) {
            if (symbols.length == 0) {
                [symbols appendString:company.stockSymbol];
            } else {
                [symbols appendString:@"+"];
                [symbols appendString:company.stockSymbol];
            }
        }
    }];
    
    
    // Fetch stock quotes from finance.yahoo.com
    NSString *URLString = [NSString stringWithFormat:@"http://finance.yahoo.com/d/quotes.csv?s=%@&f=sal1", symbols];
    [symbols release];
    
    //NSLog(@"URLString: %@", URLString);
    NSURL *URL = [NSURL URLWithString:URLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        // Execute the dataTask block in the main thread, so that updateActionBlock can be used to update the gui.
        _session = [NSURLSession sessionWithConfiguration:config
                                                 delegate:nil
                                            delegateQueue:[NSOperationQueue mainQueue]];
    }
    
    // Parses the recieved data from yahoo and stores in a dictionary
    NSURLSessionDataTask *dataTask = [_session dataTaskWithRequest:request completionHandler:
        ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (!error && [response.MIMEType isEqualToString:@"text/plain"]) {
                NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                //NSLog(@"data: %@", dataStr);
                
                NSArray *csvList = [dataStr componentsSeparatedByString:@"\n"];
                [dataStr release];
                
                NSArray *values;
                NSString *symbol, *price;
                
                for (NSString *csv in csvList) {
                    //NSLog(@"csv: %@", csv);
                    if ([csv isEqualToString:@""]) continue;
                    
                    values = [csv componentsSeparatedByString:@","];
                    //NSLog(@"values: [%@, %@, %@]", values[0], values[1], values[2]);
                    
                    symbol = [values[0] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    price = [values[1] isEqualToString:@"N/A"] ? values[2] : values[1] ;
                    
                    [self.stockQuotes setObject:price forKey:symbol];
                }
                
                // Let the caller know that fetch has finished and stockQuotes have been updated.
                if (fetchDidFinish) fetchDidFinish();
            } else {
                NSLog(@"CompanyDAO.fetchStockQuotes - Error: %@",
                      error ? error.localizedDescription: response.MIMEType);
            }
            //NSLog(@"fetchStockQuotes: Is in mainQueue: %@", [NSThread isMainThread] ? @"YES" : @"NO");
        }];
    [dataTask resume];
}

- (NSString *) getStockQuoteForSymbol:(NSString *)symbol {
    return [self.stockQuotes objectForKey:symbol];
}


/* ----------------------------------------------------------------------------------------------- */

- (void) loadData {
    @autoreleasepool {
        Company *company;
        
        company = [[[Company alloc] initWithName:@"Apple mobile devices" icon:@"apple.png"] autorelease];
        company.stockSymbol = @"AAPL";
        [company addProduct:[[[Product alloc] initWithName:@"iPad Air 2" andURL:@"https://www.apple.com/ipad-air-2/"] autorelease]];
        [company addProduct:[[[Product alloc] initWithName:@"Watch"      andURL:@"https://www.apple.com/watch/"] autorelease]];
        [company addProduct:[[[Product alloc] initWithName:@"iPhone 6S"  andURL:@"https://www.apple.com/iphone-6s/"] autorelease]];
        [self.companies addObject:company];
        
        
        company = [[[Company alloc] initWithName:@"Samsung mobile devices" icon:@"samsung.png"] autorelease];
        company.stockSymbol = @"SSNLF";
        [company addProduct:[[[Product alloc] initWithName:@"Galaxy S6"   andURL:@"http://www.samsung.com/us/mobile/cell-phones/SM-G928VZDAVZW"] autorelease]];
        [company addProduct:[[[Product alloc] initWithName:@"Galaxy Note" andURL:@"http://www.samsung.com/us/mobile/cell-phones/SM-N920TZKATMB"] autorelease]];
        [company addProduct:[[[Product alloc] initWithName:@"Galaxy Tab"  andURL:@"http://www.samsung.com/us/mobile/galaxy-tab/SM-T810NZWEXAR"] autorelease]];
        [self.companies addObject:company];
        
        
        company = [[[Company alloc] initWithName:@"Motorola mobile devices" icon:@"motorola.png"] autorelease];
        company.stockSymbol = @"MSI";
        [company addProduct:[[[Product alloc] initWithName:@"Moto X" andURL:@"https://www.motorola.com/us/products/moto-x-pure-edition"] autorelease]];
        [company addProduct:[[[Product alloc] initWithName:@"Moto G" andURL:@"https://www.motorola.com/us/products/moto-g"] autorelease]];
        [company addProduct:[[[Product alloc] initWithName:@"Moto E" andURL:@"https://www.motorola.com/us/smartphones/moto-e-2nd-gen/moto-e-2nd-gen.html"] autorelease]];
        [self.companies addObject:company];

        
        company = [[[Company alloc] initWithName:@"LG mobile devices" icon:@"lg.jpg"] autorelease];
        company.stockSymbol = @"066570.KS";
        [company addProduct:[[[Product alloc] initWithName:@"Nexus 5X"     andURL:@"https://www.google.com/nexus/5x/"] autorelease]];
        [company addProduct:[[[Product alloc] initWithName:@"G4"           andURL:@"http://www.lg.com/us/mobile-phones/g4"] autorelease]];
        [company addProduct:[[[Product alloc] initWithName:@"G Pad X 10.1" andURL:@"http://www.lg.com/us/tablets/lg-V930-g-pad-x-10.1"] autorelease]];
        [self.companies addObject:company];
    }
}

- (void) dealloc {
    _session = nil;
    [_companies release];
    [_stockQuotes release];
    [super dealloc];
}
@end