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
    NSURLSession *_session;
    NSMutableDictionary *_stockQuotes;
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
/* ----------------------------------------------------------------------------- */

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
// Company methods
- (NSArray *) getCompanyList {
    return [_companyList copy];
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

- (void) addCompany:(Company *)company {
    [_companyList addObject:company];
}

- (void) updateCompany:(Company *)company {
    for (int i = 0; i < _companyList.count; i++) {
        Company *c = [_companyList objectAtIndex:i];
        if ([c isEqual:company]) {
            [_companyList replaceObjectAtIndex:i withObject:company];
            break;
        }
    }
}


/* -------------------------------------------------------------------------------- */
// Product methods
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

- (void) addProduct:(Product *)product forCompanyName:(NSString *)companyName {
    Company *c = [self getCompanyByName:companyName];
    [c addProduct:product];
}

- (void) updateProduct:(Product *)product forCompanyName:(NSString *)companyName {
    Company *c = [self getCompanyByName:companyName];
    [c updateProduct:product];
}

/* -------------------------------------------------------------------------------------------- */

// Fetches stock quotes of all the Compamy at once
- (void) fetchStockQuotes: (void(^)(void))fetchDidFinish {
    
    // Build a string of stock symbols by concatenating symbol from each company with '+' in between.
    NSMutableString *symbols = [[NSMutableString alloc] init];
    [_companyList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
                NSLog(@"data: %@", dataStr);
                
                NSArray *csvList = [dataStr componentsSeparatedByString:@"\n"];
                NSArray *values;
                NSString *symbol, *price;
                
                if (!_stockQuotes) _stockQuotes = [[NSMutableDictionary alloc] init];

                for (NSString *csv in csvList) {
                    //NSLog(@"csv: %@", csv);
                    if ([csv isEqualToString:@""]) continue;
                    
                    values = [csv componentsSeparatedByString:@","];
                    //NSLog(@"values: [%@, %@, %@]", values[0], values[1], values[2]);
                    
                    symbol = [values[0] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    price = [values[1] isEqualToString:@"N/A"] ? values[2] : values[1] ;
                    
                    [_stockQuotes setObject:price forKey:symbol];
                }
                
                // Let the caller know that fetch has finished and stockQuotes have been updated.
                if (fetchDidFinish) fetchDidFinish();
            } else {
                NSLog(@"CompanyDAO.fetchStockQuotes - Error: %@",
                      error ? error.localizedDescription: response.MIMEType);
            }
            NSLog(@"fetchStockQuotes: Is in mainQueue: %@", [NSThread isMainThread] ? @"YES" : @"NO");
        }];
    [dataTask resume];
}

- (NSString *) getStockQuoteForSymbol:(NSString *)symbol {
    return [_stockQuotes objectForKey:symbol];
}


/* ----------------------------------------------------------------------------------------------- */

- (void) buildCompanyData {
    Company *company;
    
    company = [[Company alloc] initWithName:@"Apple mobile devices" icon:@"apple.png"];
    company.stockSymbol = @"AAPL";
    [company addProduct:[[Product alloc] initWithName:@"iPad Air 2" andURL:@"https://www.apple.com/ipad-air-2/"]];
    [company addProduct:[[Product alloc] initWithName:@"Watch"      andURL:@"https://www.apple.com/watch/"]];
    [company addProduct:[[Product alloc] initWithName:@"iPhone 6S"  andURL:@"https://www.apple.com/iphone-6s/"]];
    [_companyList addObject:company];
    
    
    company = [[Company alloc] initWithName:@"Samsung mobile devices" icon:@"samsung.png"];
    company.stockSymbol = @"SSNLF";
    [company addProduct:[[Product alloc] initWithName:@"Galaxy S6"   andURL:@"http://www.samsung.com/us/mobile/cell-phones/SM-G928VZDAVZW"]];
    [company addProduct:[[Product alloc] initWithName:@"Galaxy Note" andURL:@"http://www.samsung.com/us/mobile/cell-phones/SM-N920TZKATMB"]];
    [company addProduct:[[Product alloc] initWithName:@"Galaxy Tab"  andURL:@"http://www.samsung.com/us/mobile/galaxy-tab/SM-T810NZWEXAR"]];
    [_companyList addObject:company];
    
    
    company = [[Company alloc] initWithName:@"Motorola mobile devices" icon:@"motorola.png"];
    company.stockSymbol = @"MSI";
    [company addProduct:[[Product alloc] initWithName:@"Moto X" andURL:@"https://www.motorola.com/us/products/moto-x-pure-edition"]];
    [company addProduct:[[Product alloc] initWithName:@"Moto G" andURL:@"https://www.motorola.com/us/products/moto-g"]];
    [company addProduct:[[Product alloc] initWithName:@"Moto E" andURL:@"https://www.motorola.com/us/smartphones/moto-e-2nd-gen/moto-e-2nd-gen.html"]];
    [_companyList addObject:company];
    
    
    company = [[Company alloc] initWithName:@"LG mobile devices" icon:@"lg.jpg"];
    company.stockSymbol = @"066570.KS";
    [company addProduct:[[Product alloc] initWithName:@"Nexus 5X"     andURL:@"https://www.google.com/nexus/5x/"]];
    [company addProduct:[[Product alloc] initWithName:@"G4"           andURL:@"http://www.lg.com/us/mobile-phones/g4"]];
    [company addProduct:[[Product alloc] initWithName:@"G Pad X 10.1" andURL:@"http://www.lg.com/us/tablets/lg-V930-g-pad-x-10.1"]];
    [_companyList addObject:company];
}
@end