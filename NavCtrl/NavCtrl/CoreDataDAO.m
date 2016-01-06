//
//  CoreDataDAO.m
//  NavCtrl
//
//  Created by Imran on 11/30/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "AFNetworking.h"
#import "CoreDataDAO.h"
#import "Company.h"
#import "Product.h"

static BOOL const PrePopulateStore = NO;

static NSString *const CompanyEntity = @"Company";
static NSString *const ProductEntity = @"Product";

static NSString *const NameAttribute        = @"name";
static NSString *const IconAttribute        = @"icon";
static NSString *const StockSymbolAttribute = @"stockSymbol";
static NSString *const ListOrderAttribute   = @"listOrder";
static NSString *const URLAttribute         = @"url";
static NSString *const ProductsAttribute    = @"products";
static NSString *const CompanyAttribute     = @"company";


@interface CoreDataDAO()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end

@implementation CoreDataDAO

- (instancetype) init {
    self = [super init];
    if (self) {
        [self initializeCoreData];
    }
    return self;
}

// MARK: CoreData methods
/*
 * Setup CoreData
 */
- (void) initializeCoreData {
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NavCtrlModel" withExtension:@"momd"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentURL =  [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [documentURL URLByAppendingPathComponent:@"navctrl.sqlite"];
    
    NSLog(@"storeURL: %@", storeURL);
    
    NSManagedObjectModel *mom = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] retain];
    NSAssert(mom != nil, @"Error initializing Managed Object Model");
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [moc setPersistentStoreCoordinator:psc];
    
    moc.undoManager = [[NSUndoManager alloc] init];
    
    [self setManagedObjectContext:moc];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSPersistentStoreCoordinator *psc = [[self managedObjectContext] persistentStoreCoordinator];
        
        NSError *error = nil;
        NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType
                                                     configuration:nil
                                                               URL:storeURL
                                                           options:nil
                                                             error:&error];
        NSAssert(store != nil, @"Error initializing PersistentStoreCoordinator: %@\n%@",
                 [error localizedDescription], [error userInfo]);
        
        if (PrePopulateStore) {
            [self prePopulateStore];
        }
//    });
}

/*
 * Populate CoreData Store if it is first time being created.
 */
- (void) prePopulateStore {
    [super loadCompanyList:nil];
    
    NSArray<Company *> *companyList = [super getCompanyList];
    
    for (Company *company in companyList) {
        NSManagedObject *companyMO = [self createManagedObjectFromCompany:company];
        
        NSArray<Product *> *products = company.products;
        for (Product *product in products) {
            [self createManagedObjectFromProduct:product forCompanyManagedObject:companyMO];
        }
    }
    
    NSError *error = nil;
    if ( ![self.managedObjectContext save:&error] ) {
        NSLog(@"populateStore: Error saving: %@\n%@", error.localizedDescription, error.userInfo);
    }
}

/*
 * Create Company ManagedObject
 */
- (NSManagedObject *) createManagedObjectFromCompany:(Company *) company {
    NSManagedObject *companyMO = [NSEntityDescription insertNewObjectForEntityForName: CompanyEntity
                                                               inManagedObjectContext: self.managedObjectContext];
    [companyMO setValue:company.name forKey:NameAttribute];
    [companyMO setValue:company.icon forKey:IconAttribute];
    [companyMO setValue:company.stockSymbol forKey:StockSymbolAttribute];
    [companyMO setValue:[NSNumber numberWithUnsignedInteger:company.listOrder] forKey:ListOrderAttribute];
    
    return companyMO;
}

/*
 * Create Product ManagedObject
 */
- (NSManagedObject *) createManagedObjectFromProduct:(Product *)product forCompanyManagedObject:(NSManagedObject *)companyMO {
    NSManagedObject *productMO = [NSEntityDescription insertNewObjectForEntityForName: ProductEntity
                                                               inManagedObjectContext: self.managedObjectContext];
    [productMO setValue:product.name forKey:NameAttribute];
    [productMO setValue:product.url  forKey:URLAttribute];
    [productMO setValue:[NSNumber numberWithUnsignedInteger:product.listOrder] forKey:ListOrderAttribute];
    [productMO setValue:companyMO forKey:CompanyAttribute];
    
    return productMO;
}

/*
 * Construct Product from its ManagedObject
 */
- (Product *) productFromManagedObject:(NSManagedObject *)managedObject {
    Product *product = [[Product alloc] init];
    
    product.managedObjectURI = [[managedObject objectID] URIRepresentation];
    product.name = [managedObject valueForKey:NameAttribute];
    product.url  = [managedObject valueForKey:URLAttribute];
    product.listOrder =[(NSNumber *)[managedObject valueForKey:ListOrderAttribute] longLongValue];
    
    return product;
}

/*
 * Construct Company from its ManagedObject
 */
- (Company *) companyFromManagedObject:(NSManagedObject *)managedObject {
    Company *company = [[Company alloc] init];

    company.managedObjectURI = [[managedObject objectID] URIRepresentation];
    company.name = [managedObject valueForKey:NameAttribute];
    company.icon = [managedObject valueForKey:IconAttribute];
    company.stockSymbol = [managedObject valueForKey:StockSymbolAttribute];
    company.listOrder = [(NSNumber *)[managedObject valueForKey:ListOrderAttribute] longLongValue];
    
    /*
    NSSet *productMOSet = [managedObject valueForKey:ProductsAttribute];
    NSArray *productMOList = [productMOSet sortedArrayUsingDescriptors:@[self.sortByListOrder]];
    NSMutableArray<Product *> *products = [[NSMutableArray alloc] init];
    
    for(NSManagedObject *productMO in productMOList) {
        [products addObject: [self productFromManagedObject:productMO]];
    }
    
    [company setProducts:products];
     */
    
    return company;
}

/*
 * Get the ManagedObject from URI
 */
- (NSManagedObject *) managedObjectFromURI:(NSURL *)URI {
    NSPersistentStoreCoordinator *psc = [self.managedObjectContext persistentStoreCoordinator];
    NSManagedObjectID *managedObjecID = [psc managedObjectIDForURIRepresentation:URI];
    return [self.managedObjectContext objectWithID:managedObjecID];
}

/*
 * Fetch ManagedObject for given entity and predicate
 */
- (NSArray *) fetchManagedObjectForEntity:(NSString *)entityName predicate:(NSPredicate *)predicate {
    NSEntityDescription *entity = [NSEntityDescription entityForName: entityName
                                              inManagedObjectContext: [self managedObjectContext]];
    
    NSSortDescriptor *sortByListOrder = [NSSortDescriptor sortDescriptorWithKey:ListOrderAttribute ascending:YES];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];
    [request setSortDescriptors:@[sortByListOrder]];

    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (!results) {
        NSLog(@"Error fetching Companies: %@\n%@", error.localizedDescription, error.userInfo);
        return nil;
    }

    return results;
}

/*
 * Save any changes in the managed object context
 */
- (BOOL) save {
    if (![self.managedObjectContext hasChanges]) {
        NSLog(@"ManagedObjectContest hasNoChanges");
        return YES;
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error saving: %@\n%@", error.localizedDescription, error.userInfo);
        return NO;
    }
    
    return YES;
}


// MARK: Company methods
/*
 * Fetch all the Companies in Managed Object Store
 */
- (void) loadCompanyList:(void (^)(void))completionBlock {
    NSArray *managedObjects = [self fetchManagedObjectForEntity:CompanyEntity predicate:nil];
    NSAssert(managedObjects != nil, @"Error: Failed to load 'Company' managed objects");
    
    NSMutableArray<Company *> *companyList = [[NSMutableArray alloc] init];
    for(NSManagedObject *companyMO in managedObjects) {
        [companyList addObject: [self companyFromManagedObject:companyMO]];
    }
    
    [super setCompanyList:companyList];
    
    completionBlock();
}

/*
 * Delete a Company and update the listOrder of the following Companies
 */
- (void) deleteCompanyAtIndex:(NSInteger)index {
    Company *company = [super getCompanyAtIndex:index];
    NSURL *URI = company.managedObjectURI;
    NSUInteger listOrder = company.listOrder;
    
    [super deleteCompanyAtIndex:index];
    [self.managedObjectContext deleteObject:[self managedObjectFromURI:URI]];
    
    NSNumber *listOrderNum = [NSNumber numberWithUnsignedInteger:listOrder];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K > %@", ListOrderAttribute, listOrderNum];
    
    NSArray *companyMOList = [self fetchManagedObjectForEntity:CompanyEntity predicate:predicate];
    
    for(NSManagedObject *companyMO in companyMOList) {
        [companyMO setValue:[NSNumber numberWithUnsignedInteger:listOrder++]
                                                         forKey:ListOrderAttribute];
    }
    
    [self save];
}

/*
 * Add a Company to local store and to managed object store
 */
- (void) addCompany:(Company *)company completionBlock:(void (^)(void))completionBlock {
    company.listOrder = [[super getCompanyList] count];
    NSManagedObject *companyMO = [self createManagedObjectFromCompany:company];
    
    if ([self save]) {
        company.managedObjectURI = companyMO.objectID.URIRepresentation;
        [super addCompany:company completionBlock:completionBlock];
    }
}

/*
 * Update Company in local store and managed object store
 */
- (void) updateCompany:(Company *)company completionBlock:(void (^)(void))completionBlock {
    NSManagedObject *companyMO = [self managedObjectFromURI:company.managedObjectURI];
    
    [companyMO setValue:company.name forKey:NameAttribute];
    [companyMO setValue:company.icon forKey:IconAttribute];
    [companyMO setValue:company.stockSymbol forKey:StockSymbolAttribute];
    
    if ([self save]) {
        [super updateCompany:company completionBlock:completionBlock];
    }
}

/*
 * Change Company's listOrder
 */
- (void) moveCompanyFromIndex: (NSInteger)fromIndex
                      toIndex: (NSInteger)toIndex
              completionBlock: (void(^)(void))completionBlock  {
    if (toIndex == fromIndex) return;
    
    [super moveCompanyFromIndex:fromIndex toIndex:toIndex completionBlock:nil];
    
    NSUInteger lowerIndex = (toIndex < fromIndex) ? toIndex : fromIndex;
    NSUInteger upperIndex = (toIndex < fromIndex) ? fromIndex : toIndex;
    
    for (NSUInteger i = lowerIndex; i <= upperIndex; i++) {
        Company *company = [super getCompanyAtIndex:i];
        NSManagedObject *companyMO = [self managedObjectFromURI:company.managedObjectURI];
        
        [companyMO setValue:[NSNumber numberWithUnsignedInteger:company.listOrder]
                     forKey:ListOrderAttribute];
    }
    
    if ([self save]) completionBlock();
}


- (void) undoCompany: (void(^)(void))completion {
    [self.managedObjectContext undo];
    if ([self save]) {
        [self loadCompanyList:completion];
    }
}

- (void) redoCompany:(void(^)(void))completion {
    [self.managedObjectContext redo];
    if ([self save]) {
        [self loadCompanyList:completion];
    }
}

- (BOOL) canUndoCompany {
    return [[self.managedObjectContext undoManager] canUndo];
}

- (BOOL) canRedoCompany {
    return [[self.managedObjectContext undoManager] canRedo];
}


// MARK: Product methods
/*
 * Load all products for the given Company from the Managed Object Store
 */
- (void) loadProductsForCompany:(Company *)company completionBlock:(void (^)(void))completionBlock {
    NSManagedObject *companyMO = [self managedObjectFromURI:company.managedObjectURI];
    NSSet *productMOSet = [companyMO valueForKey:ProductsAttribute];
    
    NSMutableArray *productList = [NSMutableArray arrayWithCapacity:productMOSet.count];
    
    for(NSManagedObject *productMO in productMOSet) {
        Product *product = [self productFromManagedObject:productMO];
        [productList addObject:product];
    }
    
    NSSortDescriptor *sortByListOrder = [NSSortDescriptor sortDescriptorWithKey:ListOrderAttribute ascending:YES];

    [productList sortUsingDescriptors:@[sortByListOrder]];
    [company setProducts:productList];
    
    if (completionBlock) completionBlock();
}

/*
 * Delete a Product from a given Company
 */
- (void) removeProductAtIndex:(NSInteger)index forCompany:(Company *)company {
    Product *product = [company productAtIndex:index];
    NSURL *productURI = product.managedObjectURI;
    NSUInteger listOrder = product.listOrder;
    
    [company removeProductAtIndex:index];
    [self.managedObjectContext deleteObject:[self managedObjectFromURI:productURI]];
    
    NSNumber *listOrderNum = [NSNumber numberWithUnsignedInteger:listOrder];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K > %@", ListOrderAttribute, listOrderNum];
    
    NSArray *productMOList = [self fetchManagedObjectForEntity:ProductEntity predicate:predicate];
    for (NSManagedObject *productMO in productMOList) {
        [productMO setValue: [NSNumber numberWithUnsignedInteger:listOrder++]
                     forKey: ListOrderAttribute];
    }
    
    [self save];
}

/*
 * Update Product's listOrder between the given index
 */
- (void) moveProductFromIndex: (NSInteger)fromIndex
                      toIndex: (NSInteger)toIndex
                   forCompany: (Company *)company
              completionBlock: (void(^)(void))completionBlock {
    
    if (fromIndex == toIndex) return;
    
    [company moveProductFromIndex:fromIndex toIndex:toIndex];
    
    NSUInteger lowerIndex = (toIndex < fromIndex) ? toIndex : fromIndex;
    NSUInteger upperIndex = (toIndex < fromIndex) ? fromIndex : toIndex;
    
    for (NSUInteger i = lowerIndex; i <= upperIndex; i++) {
        Product *product = [company productAtIndex:i];
        NSManagedObject *productMO = [self managedObjectFromURI:product.managedObjectURI];
        
        [productMO setValue: [NSNumber numberWithUnsignedInteger:product.listOrder]
                     forKey: ListOrderAttribute];
    }
    
    if ([self save]) completionBlock();
}

/*
 * Add a Product for a given Company to the local store and Managed Object store
 */
- (void) addProduct:(Product *)product forCompany:(Company *)company completionBlock:(void (^)(void))completionBlock {
    [company addProduct:product];
    
    NSManagedObject *companyMO = [self managedObjectFromURI:company.managedObjectURI];
    NSManagedObject *productMO = [self createManagedObjectFromProduct:product forCompanyManagedObject:companyMO];
    
    if ([self save]) {
        product.managedObjectURI = productMO.objectID.URIRepresentation;
        completionBlock();
    }
}

/*
 * Update Product for a given Company in the Managed Object store
 */
- (void) updateProduct:(Product *)product forCompany:(Company *)company completionBlock:(void (^)(void))completionBlock {
    NSManagedObject *productMO = [self managedObjectFromURI:product.managedObjectURI];
    
    [productMO setValue:product.name forKey:NameAttribute];
    [productMO setValue:product.url forKey:URLAttribute];
    
    if ([self save]) {
        completionBlock();
    }
}


 - (NSArray *) getProductsByCompany:(Company *)company {
     if (!company.products) {
         [self loadProductsForCompany:company completionBlock:nil];
     }
     return company.products;
}
 
 - (Product *) getProductAtIndex:(NSInteger)index forCompany:(Company *)company {
     return [company.products objectAtIndex:index];
 }


- (void) undoProductForCompany: (Company *)company CompletionBlock: (void(^)(void))completion {
    [self.managedObjectContext undo];
    if ([self save]) {
        [self loadProductsForCompany:company completionBlock:completion];
    }
}

- (void) redoProductForCompany: (Company *)company CompletionBlock: (void(^)(void))completion {
    [self.managedObjectContext redo];
    if ([self save]) {
        [self loadProductsForCompany:company completionBlock:completion];
    }
}

- (BOOL) canUndoProduct {
    return [[self.managedObjectContext undoManager] canUndo];
}

- (BOOL) canRedoProduct {
    return [[self.managedObjectContext undoManager] canRedo];
}


- (NSString *) allStockSymbols {
    NSMutableString *symbols = nil;
    
    NSArray<Company *> *companies = [super getCompanyList];
    if (companies && companies.count > 0) {
        // Build a string of stock symbols by concatenating symbol from each company with '+' in between.
        symbols = [[[NSMutableString alloc] init] autorelease];
        
        [companies enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
    }
    
    return symbols;
}

BOOL isFetching = NO;

- (void) fetchStockQuotes: (void(^)(void))fetchDidFinish {
    if (isFetching) {
        return;
    } else {
        isFetching = YES;
    }
    
    NSString *symbols = [self allStockSymbols];
    if (!symbols) return;
    
    if (!self.sessionManager) {
        AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
        AFCSVResponseSerializer *responseSerializer = [AFCSVResponseSerializer serializer];
        [sessionManager setResponseSerializer:responseSerializer];
        self.sessionManager = sessionManager;
    }
    
    NSDictionary *parameters = @{@"s":symbols, @"f":@"sl1d1t1"};
    NSURLSessionDataTask *task = [self.sessionManager GET:@"http://finance.yahoo.com/d/quotes.csv"
                                              parameters:parameters
                                                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                                    
                                                     NSDictionary *stockQuotes = (NSDictionary *)responseObject;
                                                     [super setStockQuotes:stockQuotes];
                                                     
                                                     isFetching = NO;
                                                     if (fetchDidFinish) fetchDidFinish();
                                                 }
                                                 failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                     isFetching = NO;
                                                     NSLog(@"Error: %@\n%@", error.localizedDescription, error.userInfo);
                                                 }];
    [task resume];
}

@end


@implementation AFCSVResponseSerializer

+ (instancetype)serializer {
    AFCSVResponseSerializer *serializer = [[self alloc] init];
    return serializer;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [super setAcceptableContentTypes:[NSSet setWithObjects:@"text/plain", nil]];
    }
    return self;
}

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError * _Nullable *)error  {
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if (!error) return nil;
    }
    
    id responseObject = nil;
    
    NSString *csvString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray<NSString *> *csvList = [csvString componentsSeparatedByString:@"\n"];
    NSMutableDictionary *stockQuoteDict = [NSMutableDictionary dictionaryWithCapacity:[csvList count]];

    [csvString release];

    for (NSString *csv in csvList) {
        if ([csv isEqualToString:@""]) continue;
        
        NSArray<NSString *> *values = [csv componentsSeparatedByString:@","];
        NSString *symbol = [values[0] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSString *price = [values[1] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSString *date = [values[2] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSString *time = [values[3] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        NSString *lastTrade = [NSString stringWithFormat:@"%@ %@ %@",
                               [price isEqualToString:@"N/A"] ? @"" : price,
                               [date isEqualToString:@"N/A"] ? @"" : date,
                               [time isEqualToString:@"N/A"] ? @"" : time];
        
        [stockQuoteDict setObject:lastTrade forKey:symbol];
    }
    
    responseObject = stockQuoteDict;

    return responseObject;
}
@end
