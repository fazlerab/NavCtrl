//
//  ProductCollectionViewController.m
//  NavCtrl
//
//  Created by Imran on 12/15/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import "ProductCollectionViewController.h"
#import "NavCtrlDAO.h"
#import "Product.h"
#import "NCCollectionViewCell.h"
#import "NCCollectionViewCellActionDelegate.h"
#import "ProductWebViewController.h"
#import "ProductDetailViewController.h"

@interface ProductCollectionViewController () <NCCollectionViewCellActionDelegate>

@property (nonatomic, retain) UIBarButtonItem *addButtonItem;
@property (nonatomic, retain) UIBarButtonItem *undoButton;
@property (nonatomic, retain) UIBarButtonItem *redoButton;

@property (nonatomic, retain) ProductWebViewController *webViewController;
@property (nonatomic, retain) ProductDetailViewController *detailViewController;
@property (nonatomic, retain) UINavigationController *detailNavController;
@property (nonatomic, retain) UILongPressGestureRecognizer *lpGestureRecognizer;
@end

@implementation ProductCollectionViewController

static NSString * const reuseIdentifier = @"NCCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    [self.collectionView setBackgroundColor: [UIColor lightGrayColor]];
    
    // Register cell classes
    UINib *ncCellNib = [UINib nibWithNibName:@"NCCollectionViewCell" bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:ncCellNib forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    [self setupLayout];
    [self setupNavigationView];
    
    self.lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self.collectionView addGestureRecognizer:self.lpGestureRecognizer];
}

- (void) viewWillAppear:(BOOL)animated {
    self.title = self.company.name;
    
    [[NavCtrlDAO sharedInstance] loadProductsForCompany:self.company completionBlock:^{
        [self.collectionView reloadData];
        [self enableUndoRedoButtons];
    }];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setupLayout {
    CGSize viewSize = [self.view bounds].size;
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)[self collectionViewLayout];
    
    CGSize currentItemSize = flowLayout.itemSize;
    flowLayout.itemSize = CGSizeMake(viewSize.width/2 - 1, currentItemSize.height);
    flowLayout.minimumLineSpacing = 1.5f;
    flowLayout.minimumInteritemSpacing = 1.0f;
}

- (void) setupNavigationView {
    self.addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                       target:self
                                                                       action:@selector(handleAdd)];
    
    self.undoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo
                                                                    target:self
                                                                    action:@selector(handleUndo)];
    
    self.redoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRedo
                                                                    target:self
                                                                    action:@selector(handleRedo)];
    
    self.navigationItem.rightBarButtonItems = @[self.addButtonItem, self.editButtonItem];
    
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.navigationItem.leftBarButtonItems = @[self.undoButton, self.redoButton];
}

- (void) enableUndoRedoButtons {
    self.undoButton.enabled = [[NavCtrlDAO sharedInstance] canUndoCompany];
    self.redoButton.enabled = [[NavCtrlDAO sharedInstance] canRedoCompany];
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self showCellEditingButtons:editing];
}

- (void) showCellEditingButtons:(BOOL) editing {
    NSArray<UICollectionViewCell *> *visibleCells = (NSArray<UICollectionViewCell *> *)[self.collectionView visibleCells];
    for (UICollectionViewCell *cell in visibleCells) {
        NCCollectionViewCell *ncCell = (NCCollectionViewCell *) cell;
        ncCell.editing = editing;
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *products = [[NavCtrlDAO sharedInstance] getProductsByCompany:self.company];
    return [products count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NCCollectionViewCell *cell = (NCCollectionViewCell  *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    Product *product = [[NavCtrlDAO sharedInstance] getProductAtIndex:indexPath.item forCompany:self.company];
    cell.titleLabel.text = product.name;
    
    UIImage *image = [UIImage imageNamed:self.company.icon];
    if (!image) { image = [UIImage imageNamed:@"Sunflower.gif"]; }
    [[cell imageView] setImage:image];
    
    cell.editing = self.isEditing;
    cell.actionButtonDelegate = self;

    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return !self.editing;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
    Product *product = [[NavCtrlDAO sharedInstance] getProductAtIndex:indexPath.item forCompany:self.company];
    [self showWebViewForProduct:product];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.item == destinationIndexPath.item) return;
    [[NavCtrlDAO sharedInstance] moveProductFromIndex: sourceIndexPath.item
                                              toIndex: destinationIndexPath.item
                                           forCompany: self.company completionBlock:^ {
                                               [self.collectionView reloadData];
                                               [self enableUndoRedoButtons];
                                           }];
}

/*
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
 }
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

- (void) showWebViewForProduct:(Product *)product {
    if (!self.webViewController) {
        ProductWebViewController *webViewController = [[ProductWebViewController alloc] init];
        self.webViewController = webViewController;
        [webViewController release];
    }
    
    self.webViewController.title = product.name;
    self.webViewController.URL = product.url;
    [self.navigationController pushViewController:self.webViewController animated:YES];
}

- (void) showDetailViewForProduct:(Product *)product {
    if (!self.detailViewController) {
        ProductDetailViewController *detailViewController = [[ProductDetailViewController alloc] initWithNibName:@"ProductDetailViewController" bundle:[NSBundle mainBundle]];
        
        UINavigationController *detailNavController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
        [detailNavController setModalPresentationStyle: UIModalPresentationFormSheet];
        [detailNavController setModalTransitionStyle: UIModalTransitionStyleCoverVertical];
        
        self.detailViewController = detailViewController;
        self.detailNavController = detailNavController;
        [detailViewController release];
        [detailNavController release];
    }
    
    self.detailViewController.company = self.company;
    self.detailViewController.product = product;
    self.detailViewController.completionHandler = ^{
        [self.collectionView reloadData];
        [self enableUndoRedoButtons];
    };
    
    [self showDetailViewController:self.detailViewController.navigationController sender:self];
}

- (void) handleDetail:(NCCollectionViewCell *)sender {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
    Product *product = [[NavCtrlDAO sharedInstance] getProductAtIndex:indexPath.item forCompany:self.company];
    [self showDetailViewForProduct:product];
}

- (void) handleDelete:(NCCollectionViewCell *)sender {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
    [[NavCtrlDAO sharedInstance] removeProductAtIndex:indexPath.item forCompany:self.company];
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    [self enableUndoRedoButtons];
}

- (void) handleAdd {
    [self showDetailViewForProduct:nil];
}

- (void) handleUndo {
    [[NavCtrlDAO sharedInstance] undoProductForCompany:self.company
                                       CompletionBlock:^{
                                           [self.collectionView reloadData];
                                           [self enableUndoRedoButtons];
                                       }];
}

- (void) handleRedo {
    [[NavCtrlDAO sharedInstance] redoProductForCompany:self.company
                                       CompletionBlock:^{
                                           [self.collectionView reloadData];
                                           [self enableUndoRedoButtons];
                                       }];
}

- (void) handleLongPressGesture:(UILongPressGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.collectionView];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint: location];
        
        [self.collectionView beginInteractiveMovementForItemAtIndexPath: indexPath];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        [self.collectionView updateInteractiveMovementTargetPosition:location];
    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.collectionView endInteractiveMovement];
    }
    else if (gesture.state == UIGestureRecognizerStateCancelled) {
        [self.collectionView cancelInteractiveMovement];
    }
}


- (void)dealloc {
    [_company dealloc];
    [_webViewController dealloc];
    [_detailViewController dealloc];
    [_lpGestureRecognizer dealloc];
    [super dealloc];
}

@end
