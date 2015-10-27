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

    _detailViewController = [[ProductDetailViewController alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if ([self.title isEqualToString:@"Apple mobile devices"]) {
        self.products = @[@"iPad Air 2", @"Watch",@"iPhone 6S"];
        self.URLs = @[@"https://www.apple.com/ipad-air-2/",
                      @"https://www.apple.com/watch/",
                      @"https://www.apple.com/iphone-6s/"];
        
    } else if ([self.title isEqualToString:@"Samsung mobile devices"]){
        self.products = @[@"Galaxy S6", @"Galaxy Note", @"Galaxy Tab"];
        self.URLs = @[@"http://www.samsung.com/us/mobile/cell-phones/SM-G928VZDAVZW",
                      @"http://www.samsung.com/us/mobile/cell-phones/SM-N920TZKATMB",
                      @"http://www.samsung.com/us/mobile/galaxy-tab/SM-T810NZWEXAR"];
        
    } else if ([self.title isEqualToString:@"Motorola mobile devices"]) {
        self.products = @[@"Moto X", @"Moto G", @"Moto E"];
        self.URLs = @[@"https://www.motorola.com/us/products/moto-x-pure-edition",
                      @"https://www.motorola.com/us/products/moto-g",
                      @"https://www.motorola.com/us/smartphones/moto-e-2nd-gen/moto-e-2nd-gen.html"];
        
    } else {
        self.products = @[@"Nexus 5X", @"G4", @"G Pad X 10.1"];
        self.URLs = @[@"https://www.google.com/nexus/5x/",
                      @"http://www.lg.com/us/mobile-phones/g4",
                      @"http://www.lg.com/us/tablets/lg-V930-g-pad-x-10.1"];
    }
    
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
    cell.textLabel.text = [self.products objectAtIndex:[indexPath row]];
    
    cell.imageView.image = [UIImage imageNamed:self.icon];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.

    // Pass the selected object to the new view controller.
    self.detailViewController.title = self.products[indexPath.row];
    self.detailViewController.URL = [NSURL URLWithString:[self.URLs objectAtIndex:[indexPath row]]];
    
    // Push the view controller.
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

@end
