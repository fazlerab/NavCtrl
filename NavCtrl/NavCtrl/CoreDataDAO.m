//
//  CoreDataDAO.m
//  NavCtrl
//
//  Created by Imran on 11/30/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "CoreDataDAO.h"
#import "Company.h"
#import "Product.h"

@interface CoreDataDAO()

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray<Product *> *products;
@end

@implementation CoreDataDAO

- (instancetype) init {
    self = [super init];
    if (self) {
        [self initializeCoreData];
    }
    return self;
}

- (NSURL *)modelURL {
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NavCtrlModel" withExtension:@"momd"];
    return modelURL;
}

- (NSURL *)storeURL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentURL =  [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [documentURL URLByAppendingPathComponent:@"navctrl.sqlite"];
    NSLog(@"storeURL: %@", storeURL);
    return storeURL;
}

- (void) initializeCoreData {
    NSManagedObjectModel *mom = [[[NSManagedObjectModel alloc] initWithContentsOfURL:[self modelURL]] retain];
    NSAssert(mom != nil, @"Error initializing Managed Object Model");
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [moc setPersistentStoreCoordinator:psc];
    
    moc.undoManager = [[NSUndoManager alloc] init];
    
    [self setManagedObjectContext:moc];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        NSPersistentStoreCoordinator *psc = [[self managedObjectContext] persistentStoreCoordinator];
        
        NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType
                                                     configuration:nil
                                                               URL:[self storeURL]
                                                           options:nil
                                                             error:&error];
        [moc release];
        NSAssert(store != nil, @"Error initializing PersistentStoreCoordinator: %@\n%@",
                 [error localizedDescription], [error userInfo]);
    });
}


// MARK: Company methods
- (void) loadCompanyList:(void (^)(void))completionBlock {
    NSEntityDescription *entity = [NSEntityDescription entityForName:[Company entityName]
                                              inManagedObjectContext:[self managedObjectContext]];
    NSSortDescriptor *sortByListOrder = [NSSortDescriptor sortDescriptorWithKey:@"listOrder" ascending:YES];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setSortDescriptors:@[sortByListOrder]];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (!results) {
        NSLog(@"Error fetching Companies: %@\n%@", error.localizedDescription, error.userInfo);
    }
    else {
        [super setCompanyList:results];
        completionBlock();
    }
}

- (void) deleteCompanyAtIndex:(NSInteger)index {
    Company *company = [super getCompanyAtIndex:index];
    [self.managedObjectContext deleteObject:company];
    [super deleteCompanyAtIndex:index];
    [self saveCompany];
}

- (Company *) newCompany {
    Company *company = [NSEntityDescription insertNewObjectForEntityForName: [Company entityName]
                                                     inManagedObjectContext: self.managedObjectContext];
    company.listOrder = [super getCompanyList].count;
    return company;
}

- (void) addCompany:(Company *)company completionBlock:(void (^)(void))completionBlock {
    if ([self saveCompany]) {
        [super addCompany:company completionBlock:completionBlock];
    }
}

- (void) moveCompanyFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex completionBlock:(void(^)(void))completion  {
    [super moveCompanyFromIndex:fromIndex toIndex:toIndex completionBlock:nil];
    if ([self saveCompany]) completion();
}

- (void) updateCompany:(Company *)company completionBlock:(void (^)(void))completionBlock {
    if ([self saveCompany]) {
        [super updateCompany:company completionBlock:completionBlock];
    }
}

- (BOOL) saveCompany {
    if (![self.managedObjectContext hasChanges]) {
        NSLog(@"ManagedObjectContest hasNoChanges");
        return YES;
    }
    
    NSError *error;
    BOOL success = [self.managedObjectContext save:&error];
    
    if (!success) {
        NSLog(@"Error saving: %@\n%@", error.localizedDescription, error.userInfo);
    }
    
    return success;
}

- (void) undoCompany: (void(^)(void))completion {
    [self.managedObjectContext undo];
    if ([self saveCompany]) {
        [self loadCompanyList:completion];
    }
}

- (void) redoCompany:(void(^)(void))completion {
    [self.managedObjectContext redo];
    if ([self saveCompany]) {
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

- (void) loadProductsForCompany:(Company *)company completionBlock:(void (^)(void))completionBlock {
    NSEntityDescription *entity = [NSEntityDescription entityForName: [Product.class entityName]
                                              inManagedObjectContext: self.managedObjectContext];
    
    NSPredicate *ofCompany = [NSPredicate predicateWithFormat:@"company == %@", company];
    NSSortDescriptor *sortByListOrder = [NSSortDescriptor sortDescriptorWithKey:@"listOrder" ascending:YES];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:ofCompany];
    [request setSortDescriptors:@[sortByListOrder]];
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (!result) {
        NSLog(@"Error fetching Product: %@\n%@", error.localizedDescription, error.userInfo);
        return;
    }
    
    if (!_products) _products = [[NSMutableArray alloc] init];
    [self.products setArray:result];
    
    completionBlock();
}

- (NSArray *) getProductsByCompany:(NSString *)companyName {
    return self.products;
}

- (Product *) getProductAtIndex:(NSInteger)index forCompanyName:(NSString *)companyName {
    return [self.products objectAtIndex:index];
}

- (void) removeProductAtIndex:(NSInteger)index forCompanyName:(NSString *)companyName {
    Product *product = [[self.products objectAtIndex:index] retain];
    [self.managedObjectContext deleteObject:product];
    
    [self.products removeObjectAtIndex:index];
    for(NSUInteger i = index; i < self.products.count; i++) {
        self.products[i].listOrder--;
    }
    
    [self saveProduct];
    [product release];
}

- (void) moveProductFromIndex:(NSInteger)fromIndex
                      toIndex:(NSInteger)toIndex
               forCompanyName:(NSString *)companyName
              completionBlock:(void(^)(void))completionBlock {
    
    if (fromIndex == toIndex) return;
    
    Product *toProduct = [self.products objectAtIndex:toIndex];
    NSUInteger toListOrder = toProduct.listOrder;
    
    if (toIndex < fromIndex) {
        for (NSUInteger i = toIndex; i < fromIndex; i++) {
            [self.products objectAtIndex:i].listOrder++;
        }
    } else {
        for (NSUInteger i = fromIndex + 1; i <= toIndex; i++) {
            [self.products objectAtIndex:i].listOrder--;
        }
    }
    
    Product *fromProduct = [[self.products objectAtIndex:fromIndex] retain];
    fromProduct.listOrder = toListOrder;
    
    [self.products removeObjectAtIndex:fromIndex];
    [self.products insertObject:fromProduct atIndex:toIndex];
    
    [fromProduct release];
    
    if ([self saveProduct]) completionBlock();
}

- (Product *) newProductForCompany: (Company *)company {
    Product *product = [NSEntityDescription insertNewObjectForEntityForName:[Product.class entityName] inManagedObjectContext:self.managedObjectContext];
    product.listOrder = self.products.count;
    return product;
}

- (void) addProduct:(Product *)product forCompanyName:(NSString *)companyName completionBlock:(void (^)(void))completionBlock {
    if ([self saveProduct]) {
        [self.products addObject:product];
        completionBlock();
    }
}

- (void) updateProduct:(Product *)product forCompanyName:(NSString *)companyName completionBlock:(void (^)(void))completionBlock {
    if ([self saveProduct]) {
        completionBlock();
    }
}

- (BOOL) saveProduct {
    if (![self.managedObjectContext hasChanges]) {
        NSLog(@"ManagedObjectContest hasNoChanges");
        return YES;
    }
    
    NSError *error;
    BOOL success = [self.managedObjectContext save:&error];
    
    if (!success) {
        NSLog(@"Error saving: %@\n%@", error.localizedDescription, error.userInfo);
    }
    
    return success;
}

- (void) undoProductForCompany: (Company *)company CompletionBlock: (void(^)(void))completion {
    [self.managedObjectContext undo];
    if ([self saveProduct]) {
        [self loadProductsForCompany:company completionBlock:completion];
    }
}

- (void) redoProductForCompany: (Company *)company CompletionBlock: (void(^)(void))completion {
    [self.managedObjectContext redo];
    if ([self saveProduct]) {
        [self loadProductsForCompany:company completionBlock:completion];
    }
}

- (BOOL) canUndoProduct {
    return [[self.managedObjectContext undoManager] canUndo];
}

- (BOOL) canRedoProduct {
    return [[self.managedObjectContext undoManager] canRedo];
}



@end
