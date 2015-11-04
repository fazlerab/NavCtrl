//
//  CompanyViewController.m
//  NavCtrl
//
//  Created by Aditya Narayan on 10/22/13.
//  Copyright (c) 2013 Aditya Narayan. All rights reserved.
//

#import "CompanyViewController.h"
#import "ProductViewController.h"
#import "NewCompanyViewController.h"
#import "CompanyDAO.h"
#import "Company.h"
#import "Product.h"

@interface CompanyViewController ()

@property (nonatomic, retain) UIBarButtonItem *addButtonItem;
@property (nonatomic, retain) NewCompanyViewController *detailCompanyViewController;

@end

@implementation CompanyViewController

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

    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
 
    self.addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                   target:self
                                                                   action:@selector(handleAddCompany:)];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItems = @[self.addButtonItem, self.editButtonItem];
    
    self.title = @"Mobile device makers";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[CompanyDAO sharedInstance] getCompanyList] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    // Show disclosure and detail acssory buttons
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setEditingAccessoryType:UITableViewCellAccessoryDetailButton];

    Company *company = [[CompanyDAO sharedInstance] getCompanyAtIndex:indexPath.row];
    cell.textLabel.text = company.name;
    UIImage *image = [UIImage imageNamed:company.icon];
    if (!image) {
        image = [UIImage imageNamed:@"Sunflower.gif"];
    }
    [[cell imageView] setImage:image];
    
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
        [[CompanyDAO sharedInstance] deleteCompanyAtIndex:indexPath.row];
        
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
    [[CompanyDAO sharedInstance] moveCompanyFromIndex:fromIndexPath.row toIndex:toIndexPath.row];
    
//    Company *company = [[self.companyList objectAtIndex:fromIndexPath.row] retain];
//    [self.companyList removeObjectAtIndex:fromIndexPath.row];
//    [self.companyList insertObject:company atIndex:toIndexPath.row];
//    [company release];
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
    Company *company = [[CompanyDAO sharedInstance] getCompanyAtIndex:indexPath.row];
    self.productViewController.title = company.name;
    [self.navigationController pushViewController:self.productViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"accessoryButtonTappedForRowWithIndexPath");
    [self createDetailComanyViewController];
    Company *company = [[CompanyDAO sharedInstance] getCompanyAtIndex:indexPath.row];
    self.detailCompanyViewController.company = company;
    [self showDetailViewController:self.detailCompanyViewController.navigationController sender:self];
}

- (void) createDetailComanyViewController {
    if (!self.detailCompanyViewController) {
        self.detailCompanyViewController = [[NewCompanyViewController alloc] initWithNibName:@"NewCompanyViewController" bundle:nil];
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.detailCompanyViewController];
        
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
}

- (void) handleAddCompany:(UIBarButtonItem *)sender {
    NSLog(@"handleAddCompany");
    [self createDetailComanyViewController];
    self.detailCompanyViewController.company = nil;
    [self showDetailViewController:self.detailCompanyViewController.navigationController sender:self];
    
}

- (void) addCompany:(Company *)company {
    NSLog(@"addCompany: %@", company);
    [[CompanyDAO sharedInstance] addCompany:company];
    [self.tableView reloadData];
}

- (void) updateCompany:(Company *)company {
    NSLog(@"udateCompany");
    [[CompanyDAO sharedInstance] updateCompany:company];
    [self.tableView reloadData];
}

- (void)dealloc {
    [self.addButtonItem release];
    [self.productViewController release];
    [super dealloc];
}


@end
