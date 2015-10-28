//
//  ProductViewController.m
//  NavCtrl
//
//  Created by Aditya Narayan on 10/22/13.
//  Copyright (c) 2013 Aditya Narayan. All rights reserved.
//

#import "ProductViewController.h"
#import "ProductDetailViewController.h"

@interface ProductViewController ()

@property (nonatomic, retain) NSMutableDictionary *productData;
@property (nonatomic, retain) NSMutableArray *products;
@property (nonatomic, retain) ProductDetailViewController *detailViewController;

@end

@implementation ProductViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self buildProductData];
    _detailViewController = [[ProductDetailViewController alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.products = [self.productData objectForKey:self.title];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.products count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    NSDictionary *product = [self.products objectAtIndex:[indexPath row]];
    cell.textLabel.text = [product objectForKey:@"name"];
    
    cell.imageView.image = [UIImage imageNamed:self.icon];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.products removeObjectAtIndex:[indexPath row]];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (fromIndexPath.row == toIndexPath.row) return;
        
    NSDictionary *product = [[self.products objectAtIndex:[fromIndexPath row]] retain];
    [self.products removeObjectAtIndex:[fromIndexPath row]];
    [self.products insertObject:product atIndex:[toIndexPath row]];
    [product release];
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


#pragma mark - Table view delegate
// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.

    // Pass the selected object to the new view controller.
    self.detailViewController.title = [self.products[indexPath.row] objectForKey:@"name"];
    self.detailViewController.URL = [NSURL URLWithString:[self.products[indexPath.row] objectForKey:@"url"]];
    
    // Push the view controller.
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

- (void) buildProductData {
    if (!self.productData) {
        NSMutableArray *appleProducts = [NSMutableArray arrayWithArray:
             @[@{@"name": @"iPad Air 2", @"url": @"https://www.apple.com/ipad-air-2/"},
               @{@"name": @"Watch",      @"url": @"https://www.apple.com/watch/"},
               @{@"name": @"iPhone 6S",  @"url": @"https://www.apple.com/iphone-6s/"}]];
        
        NSMutableArray *samsungProducts = [NSMutableArray arrayWithArray:
               @[@{@"name": @"Galaxy S6",   @"url": @"http://www.samsung.com/us/mobile/cell-phones/SM-G928VZDAVZW"},
                 @{@"name": @"Galaxy Note", @"url": @"http://www.samsung.com/us/mobile/cell-phones/SM-N920TZKATMB"},
                 @{@"name": @"Galaxy Tab",  @"url": @"http://www.samsung.com/us/mobile/galaxy-tab/SM-T810NZWEXAR"}]];
        
        NSMutableArray *motorolaProducts = [NSMutableArray arrayWithArray:
                @[@{@"name": @"Moto X", @"url": @"https://www.motorola.com/us/products/moto-x-pure-edition"},
                  @{@"name": @"Moto G", @"url": @"https://www.motorola.com/us/products/moto-g"},
                  @{@"name": @"Moto E", @"url": @"https://www.motorola.com/us/smartphones/moto-e-2nd-gen/moto-e-2nd-gen.html"}]];
        
        NSMutableArray *lgProducts = [NSMutableArray arrayWithArray:
              @[@{@"name": @"Nexus 5X",     @"url": @"https://www.google.com/nexus/5x/"},
                @{@"name": @"G4",           @"url": @"http://www.lg.com/us/mobile-phones/g4"},
                @{@"name": @"G Pad X 10.1", @"url": @"http://www.lg.com/us/tablets/lg-V930-g-pad-x-10.1"}]];
        
        NSMutableDictionary *allProducts = [[NSMutableDictionary alloc] init];
        [allProducts setObject:appleProducts    forKey:@"Apple mobile devices"];
        [allProducts setObject:samsungProducts  forKey:@"Samsung mobile devices"];
        [allProducts setObject:motorolaProducts forKey:@"Motorola mobile devices"];
        [allProducts setObject:lgProducts       forKey:@"LG mobile devices"];
        
        self.productData = allProducts;
    }
}
@end
