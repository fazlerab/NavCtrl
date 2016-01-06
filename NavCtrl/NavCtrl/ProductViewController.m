//
//  ProductViewController.m
//  NavCtrl
//
//  Created by Aditya Narayan on 10/22/13.
//  Copyright (c) 2013 Aditya Narayan. All rights reserved.
//

#import "ProductViewController.h"
#import "ProductWebViewController.h"
#import "ProductDetailViewController.h"
#import "Company.h"
#import "Product.h"
#import "NavCtrlDAO.h"

@interface ProductViewController ()

@property (nonatomic, retain) ProductWebViewController *webViewController;
@property (nonatomic, retain) ProductDetailViewController *detailViewController;
@property (nonatomic, retain) UINavigationController *detailViewNavController;

@property (nonatomic, retain) UIBarButtonItem *undoButton;
@property (nonatomic, retain) UIBarButtonItem *redoButton;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
 
    UIBarButtonItem *addProductButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(handleAddButton:)];
    self.navigationItem.rightBarButtonItems = @[addProductButtonItem, self.editButtonItem];
    
    self.undoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(handleUndo:)];
    self.redoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRedo target:self action:@selector(handleRedo:)];
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.navigationItem.leftBarButtonItems = @[self.undoButton, self.redoButton];
    
    [addProductButtonItem release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NavCtrlDAO sharedInstance] loadProductsForCompany:self.company completionBlock:^{
        [self refreshView];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshView {
    [self.tableView reloadData];
    [self enableUndoRedoButtons];
}

- (void) enableUndoRedoButtons {
    self.undoButton.enabled = [[NavCtrlDAO sharedInstance] canUndoProduct];
    self.redoButton.enabled = [[NavCtrlDAO sharedInstance] canRedoProduct];
}

- (UITableViewCell *) configureCell: (UITableViewCell *)cell ForObject: (id)object AtIndex: (NSUInteger)index {
    Product *product = (Product *)object;
    cell.textLabel.text = product.name;
    
    UIImage *image = [UIImage imageNamed:self.company.icon];
    if (!image) { image = [UIImage imageNamed:@"Sunflower.gif"]; }
    [[cell imageView] setImage:image];
    
    // Show disclosure and detail acssory buttons
    // Only show disclosure if URL present
    if (product.url && product.url.length > 0) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    [cell setEditingAccessoryType:UITableViewCellAccessoryDetailButton];
    
    return cell;
}

- (void) openWebViewForSelectedObject: (id)object  {
    Product *product = (Product *)object;
    
    if (!self.webViewController) {
        _webViewController = [[ProductWebViewController alloc] init];
    }
    self.webViewController.title = product.name;
    self.webViewController.URL = product.url;
    
    // Push the view controller.
    // Only allow navigation to detail view when URL present
    if (product.url && product.url.length > 0) {
        [self.navigationController pushViewController:self.webViewController animated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView: (UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[[NavCtrlDAO sharedInstance] getProductsByCompany:self.company] count];
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell...
    Product *product = [[NavCtrlDAO sharedInstance] getProductAtIndex:indexPath.row forCompany:self.company];
    
    return [self configureCell:cell ForObject:product AtIndex:indexPath.row];
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [[NavCtrlDAO sharedInstance] removeProductAtIndex:indexPath.row forCompany:self.company];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self enableUndoRedoButtons];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


// Override to support rearranging the table view.
- (void)  tableView: (UITableView *)tableView moveRowAtIndexPath: (NSIndexPath *)fromIndexPath toIndexPath: (NSIndexPath *)toIndexPath {
    
    if (fromIndexPath.row == toIndexPath.row) return;
    
    [[NavCtrlDAO sharedInstance] moveProductFromIndex: fromIndexPath.row
                                              toIndex: toIndexPath.row
                                           forCompany: self.company
                                      completionBlock: ^{[self refreshView];}];
}


// Override to support conditional rearranging of the table view.
- (BOOL) tableView: (UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


#pragma mark - Table view delegate
// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.

    // Pass the selected object to the new view controller.
    id object = [[NavCtrlDAO sharedInstance] getProductAtIndex:indexPath.row forCompany:self.company];
    [self openWebViewForSelectedObject:object];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self createDetailViewController];
    
    Product *product = [[NavCtrlDAO sharedInstance] getProductAtIndex:indexPath.row forCompany:self.company];
    
    self.detailViewController.product = product;
    self.detailViewController.company = self.company;
    self.detailViewController.completionHandler = ^{
        [self refreshView];
    };
    
    [self showDetailViewController:self.detailViewController.navigationController sender:self];
}

- (void) handleUndo: (UIBarButtonItem *)sender {
    [[NavCtrlDAO sharedInstance] undoProductForCompany:self.company CompletionBlock:^{
        [self refreshView];
    }];
}

-(void) handleRedo: (UIBarButtonItem *)sender {
    [[NavCtrlDAO sharedInstance] redoProductForCompany:self.company CompletionBlock:^{
        [self refreshView];
    }];
}

- (void) handleAddButton:(UIBarButtonItem *)sender {
    [self createDetailViewController];
    
    self.detailViewController.product = nil;
    self.detailViewController.company = self.company;
    self.detailViewController.completionHandler = ^{
        [self refreshView];
    };
    
    [self showDetailViewController:self.detailViewController.navigationController sender:self];
}

- (void) createDetailViewController {
    if (!self.detailViewController) {
        _detailViewController = [[ProductDetailViewController alloc] initWithNibName:@"ProductDetailViewController" bundle:nil];
        
        _detailViewNavController = [[UINavigationController alloc] initWithRootViewController:self.detailViewController];
        
        [self.detailViewNavController setModalPresentationStyle:UIModalPresentationFormSheet];
    }
}

- (void) dealloc {
    [_webViewController release];
    [_detailViewController release];
    [_detailViewNavController release];
    [_company release];
    [_undoButton release];
    [_redoButton release];

    [super dealloc];
}

@end
