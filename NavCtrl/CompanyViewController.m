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
#import "NavCtrlDAO.h"
#import "Company.h"
#import "Product.h"

@interface CompanyViewController ()

@property (nonatomic, retain) UIBarButtonItem *addButtonItem;
@property (nonatomic, retain) NewCompanyViewController *detailCompanyViewController;
@property (nonatomic, retain) UINavigationController *detailViewNavController;

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
    
    [[NavCtrlDAO sharedInstance] loadCompanyList:^{
        [self.tableView reloadData];
        [self refreshStockQuotes];
    }];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshStockQuotes];
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
    return [[[NavCtrlDAO sharedInstance] getCompanyList] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    // Show disclosure and detail acssory buttons
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setEditingAccessoryType:UITableViewCellAccessoryDetailButton];

    Company *company = [[NavCtrlDAO sharedInstance] getCompanyAtIndex:indexPath.row];
        
    // Set company name
    cell.textLabel.text = company.name;
    
    // Set company logo
    UIImage *image = [UIImage imageNamed:company.icon];
    if (!image) {
        image = [UIImage imageNamed:@"Sunflower.gif"];
    }
    [[cell imageView] setImage:image];
    
    // Set stock price
    NSString *stockPrice = [[NavCtrlDAO sharedInstance] getStockQuoteForSymbol:company.stockSymbol];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Stock Price: %@\t\tTicker Symbol: %@",
                                 stockPrice ? stockPrice : @"?", company.stockSymbol];
    
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
        [[NavCtrlDAO sharedInstance] deleteCompanyAtIndex:indexPath.row];
        
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
    [[NavCtrlDAO sharedInstance] moveCompanyFromIndex:fromIndexPath.row toIndex:toIndexPath.row];
    
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
    Company *company = [[NavCtrlDAO sharedInstance] getCompanyAtIndex:indexPath.row];
    [self openViewForSelectedObject:company];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self createDetailComanyViewController];
    
    Company *company = [[NavCtrlDAO sharedInstance] getCompanyAtIndex:indexPath.row];
    self.detailCompanyViewController.company = company;
    self.detailCompanyViewController.completionHandler = ^{
        [self.tableView reloadData];
        [self refreshStockQuotes];
    };
    
    [self showDetailViewController:self.detailCompanyViewController.navigationController sender:self];
}

- (void) createDetailComanyViewController {
    if (!self.detailCompanyViewController) {
        _detailCompanyViewController = [[NewCompanyViewController alloc] initWithNibName:@"NewCompanyViewController" bundle:nil];
        _detailViewNavController = [[UINavigationController alloc] initWithRootViewController:self.detailCompanyViewController];
        self.detailViewNavController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
}

- (void) handleAddCompany:(UIBarButtonItem *)sender {
    [self createDetailComanyViewController];
    self.detailCompanyViewController.company = nil;
    
    self.detailCompanyViewController.completionHandler = ^{
        [self.tableView reloadData];
        [self refreshStockQuotes];
    };
    
    [self showDetailViewController:self.detailCompanyViewController.navigationController sender:self];
}

- (void) openViewForSelectedObject: (id)object  {
    Company *company = (Company *) object;
    self.productViewController.company = company;
    self.productViewController.title = company.name;
    [self.navigationController pushViewController:self.productViewController animated:YES];
}

/*
- (void) addCompany:(Company *)company {
    //NSLog(@"addCompany: %@", company);
    [[NavCtrlDAO sharedInstance] addCompany:company completionBlock:^{
        [self.tableView reloadData];
        [self refreshStockQuotes];
    }];
}

- (void) updateCompany:(Company *)company {
    //NSLog(@"udateCompany");
    [[NavCtrlDAO sharedInstance] updateCompany:company completionBlock:^{
        [self.tableView reloadData];
        [self refreshStockQuotes];
    }];
}
*/

- (void) refreshStockQuotes {
    [[NavCtrlDAO sharedInstance] fetchStockQuotes:^{
        [self.tableView reloadData];
    }];
}

- (void)dealloc {
    [_addButtonItem release];
    [_productViewController release];
    [_detailCompanyViewController release];
    [_detailViewNavController release];
    [super dealloc];
}


@end
