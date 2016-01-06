//
//  CompanyDAO.m
//  NavCtrl
//
//  Created by Fazle Rab on 11/2/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NavCtrlDAO.h"
#import "CoreDataDAO.h"
#import "Company.h"
#import "Product.h"


@interface NavCtrlDAO()
{
    NSMutableDictionary *_stockQuotes;
}
@property (nonatomic, retain) NSMutableArray<Company *> *companies;
@property (nonatomic, retain) NSURLSession *session;

@end

@implementation NavCtrlDAO
+ (NavCtrlDAO *) sharedInstance {
    static NavCtrlDAO *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CoreDataDAO alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _companies = [[NSMutableArray alloc] init];
        _stockQuotes = [[NSMutableDictionary alloc] init];
    }
    return self;
}

// MARK: Company methods
- (void) loadCompanyList:(void (^)(void))completionBlock {
    [self loadData];
    if (completionBlock) completionBlock();
}

- (void) deleteCompanyAtIndex:(NSInteger)index {
    [_stockQuotes removeObjectForKey: [self getCompanyAtIndex:index].stockSymbol];
    
    [self.companies removeObjectAtIndex:index];
    for (NSUInteger i = index; i < self.companies.count; i++) {
        [self.companies objectAtIndex:i].listOrder--;
    }
}

- (void) addCompany:(Company *)company completionBlock:(void (^)(void))completionBlock {
    [self.companies addObject:company];
    if (completionBlock) completionBlock();
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

- (void) moveCompanyFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex completionBlock:(void(^)(void))completion {
    if (fromIndex == toIndex) return;
    
    Company *companyAtToIndex = [self getCompanyAtIndex:toIndex];
    NSUInteger toListOrder = companyAtToIndex.listOrder;
    
    if (toIndex < fromIndex) {
        for (NSUInteger i = toIndex; i < fromIndex; i++) {
            [self.companies objectAtIndex:i].listOrder++;
        }
    } else {
        for (NSUInteger i = fromIndex + 1; i <= toIndex; i++) {
            [self.companies objectAtIndex:i].listOrder--;
        }
    }
    
    Company *companyAtFromIndex = [[self getCompanyAtIndex:fromIndex] retain];
    companyAtFromIndex.listOrder = toListOrder;
    
    [self.companies removeObjectAtIndex:fromIndex];
    [self.companies insertObject:companyAtFromIndex atIndex:toIndex];
    
    [companyAtFromIndex release];
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


- (Company *) getCompanyByName:(NSString *)name {
    Company *c = nil;
    
    for (c in self.companies) {
        if ( [c.name isEqualToString:name] ) {
            break;
        }
    }
    
    return c;
}

- (void) undoCompany: (void(^)(void))completion { }

- (void) redoCompany:(void(^)(void))completion { }

- (BOOL) canUndoCompany { return NO; }

- (BOOL) canRedoCompany { return NO; }


// MARK: Product methods
- (void) loadProductsForCompany:(Company *)company completionBlock:(void(^)(void))completionBlock { }

- (void) removeProductAtIndex:(NSInteger)index forCompany:(Company *)company {
    [company removeProductAtIndex:index];
}

- (void) moveProductFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex forCompany:(Company *)company completionBlock:(void(^)(void))completionBlock {
    [company moveProductFromIndex:fromIndex toIndex:toIndex];
    if (completionBlock) completionBlock();
}

- (void) addProduct:(Product *)product forCompany:(Company *)company completionBlock:(void(^)(void))completionBlock {
    [company addProduct:product];
    completionBlock();
}

- (void) updateProduct:(Product *)product forCompany:(Company *)company completionBlock:(void (^)(void))completionBlock { }

- (NSArray *) getProductsByCompany:(Company *)company {
    return company.products;
}

- (Product *) getProductAtIndex:(NSInteger)index forCompany:(Company *)company {
    return [company.products objectAtIndex:index];
}

- (void) undoProductForCompany: (Company *)company CompletionBlock: (void(^)(void))completion { }

- (void) redoProductForCompany: (Company *)company CompletionBlock: (void(^)(void))completion { }

- (BOOL) canUndoProduct { return NO; }

- (BOOL) canRedoProduct { return NO; }


/* -------------------------------------------------------------------------------------------- */
// MARK: Fetch Stock Quotes Methods

- (NSString *) allStockSymbols {
    NSMutableString *symbols = nil;
    
    if (self.companies && self.companies.count > 0) {
    
        // Build a string of stock symbols by concatenating symbol from each company with '+' in between.
        symbols = [[NSMutableString alloc] init];
        
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
    
        [symbols autorelease];
    }
    
    return symbols;
}

/* 
 * Fetches stock quotes of all the Compamy at once
 *
 * Yahoo Parameters: s=Ticker Symbol, l=Last Trade Price with Time
 */
- (void) fetchStockQuotes: (void(^)(void))fetchDidFinish {
    
    NSString *symbols = [self allStockSymbols];
    if (!symbols) return;
    
    // Fetch stock quotes from finance.yahoo.com
    NSString *URLString = [NSString stringWithFormat:@"http://finance.yahoo.com/d/quotes.csv?s=%@&f=sl", symbols];
    
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
                NSDictionary *stockQuotes = [self parseCSVData:data];
                [self setStockQuotes:stockQuotes];
                
                // Let the caller know that fetch has finished and stockQuotes have been updated.
                if (fetchDidFinish) fetchDidFinish();
            } else {
                NSLog(@"fetchStockQuotes - Error: %@",
                      error ? error.localizedDescription: response.MIMEType);
            }
            //NSLog(@"fetchStockQuotes: Is in mainQueue: %@", [NSThread isMainThread] ? @"YES" : @"NO");
        }];
    
    [dataTask resume];
}

- (NSDictionary *) parseCSVData:(NSData *)csvData {
    NSString *csvString = [[NSString alloc] initWithData:csvData encoding:NSUTF8StringEncoding];
    NSLog(@"Data: %@", csvString);
    
    NSArray *csvList = [csvString componentsSeparatedByString:@"\n"];
    [csvString release];
    
    NSArray *values;
    NSString *symbol, *price;
    NSMutableDictionary *stockQuoteDict = [NSMutableDictionary dictionaryWithCapacity:[csvList count]];
    
    for (NSString *csv in csvList) {
        //NSLog(@"csv: %@", csv);
        if ([csv isEqualToString:@""]) continue;
        
        values = [csv componentsSeparatedByString:@","];
        //NSLog(@"values: [%@, %@, %@]", values[0], values[1], values[2]);
        
        symbol = [values[0] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        price = [values[1] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        [stockQuoteDict setObject:price forKey:symbol];
    }
    
    return stockQuoteDict;
}

- (NSString *) getStockQuoteForSymbol:(NSString *)symbol {
    return [self.stockQuotes objectForKey:symbol];
}

- (NSDictionary *)stockQuotes {
    return _stockQuotes;
}

- (void)setStockQuotes:(NSDictionary *)stockQuotes {
    _stockQuotes = [stockQuotes mutableCopy];
}


/* ----------------------------------------------------------------------------------------------- */

- (void) loadData {
    @autoreleasepool {
        NSUInteger i = 0;
        Company *company;
        
        company = [[[Company alloc] initWithName:@"Apple mobile devices" icon:@"apple.png"] autorelease];
        company.stockSymbol = @"AAPL";
        company.listOrder = i++;
        [company addProduct:[[[Product alloc] initWithName:@"iPad Air 2" URL:@"https://www.apple.com/ipad-air-2/"] autorelease]];
        [company addProduct:[[[Product alloc] initWithName:@"Watch"      URL:@"https://www.apple.com/watch/"]      autorelease]];
        [company addProduct:[[[Product alloc] initWithName:@"iPhone 6S"  URL:@"https://www.apple.com/iphone-6s/"]  autorelease]];
        [self.companies addObject:company];
        
        
        company = [[[Company alloc] initWithName:@"Samsung mobile devices" icon:@"samsung.png"] autorelease];
        company.stockSymbol = @"SSNLF";
        company.listOrder = i++;
        [company addProduct:[[[Product alloc] initWithName:@"Galaxy S6"   URL:@"http://www.samsung.com/us/mobile/cell-phones/SM-G928VZDAVZW"] autorelease]];
        [company addProduct:[[[Product alloc] initWithName:@"Galaxy Note" URL:@"http://www.samsung.com/us/mobile/cell-phones/SM-N920TZKATMB"] autorelease]];
        [company addProduct:[[[Product alloc] initWithName:@"Galaxy Tab"  URL:@"http://www.samsung.com/us/mobile/galaxy-tab/SM-T810NZWEXAR"] autorelease]];
        [self.companies addObject:company];
        
        
        company = [[[Company alloc] initWithName:@"Motorola mobile devices" icon:@"motorola.png"] autorelease];
        company.stockSymbol = @"MSI";
        company.listOrder = i++;
        [company addProduct:[[[Product alloc] initWithName:@"Moto X" URL:@"https://www.motorola.com/us/products/moto-x-pure-edition"] autorelease]];
        [company addProduct:[[[Product alloc] initWithName:@"Moto G" URL:@"https://www.motorola.com/us/products/moto-g"] autorelease]];
        [company addProduct:[[[Product alloc] initWithName:@"Moto E" URL:@"https://www.motorola.com/us/smartphones/moto-e-2nd-gen/moto-e-2nd-gen.html"] autorelease]];
        [self.companies addObject:company];

        
        company = [[[Company alloc] initWithName:@"LG mobile devices" icon:@"lg.jpg"] autorelease];
        company.stockSymbol = @"066570.KS";
        company.listOrder = i++;
        [company addProduct:[[[Product alloc] initWithName:@"Nexus 5X"     URL:@"https://www.google.com/nexus/5x/"] autorelease]];
        [company addProduct:[[[Product alloc] initWithName:@"G4"           URL:@"http://www.lg.com/us/mobile-phones/g4"] autorelease]];
        [company addProduct:[[[Product alloc] initWithName:@"G Pad X 10.1" URL:@"http://www.lg.com/us/tablets/lg-V930-g-pad-x-10.1"] autorelease]];
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