//
//  CompanyCollectionViewController.m
//  NavCtrl
//
//  Created by Imran on 12/14/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import "CompanyCollectionViewController.h"
#import "NavCtrlDAO.h"
#import "Company.h"
#import "NCCollectionViewCell.h"
#import "ProductCollectionViewController.h"
#import "CompanyDetailViewController.h"

@interface CompanyCollectionViewController () <NCCollectionViewCellActionDelegate>

@property (nonatomic, retain) UIBarButtonItem *addButtonItem;
@property (nonatomic, retain) UIBarButtonItem *undoButton;
@property (nonatomic, retain) UIBarButtonItem *redoButton;

@property (nonatomic, retain) ProductCollectionViewController *productViewController;
@property (nonatomic, retain) CompanyDetailViewController *detailViewController;
@property (nonatomic, retain) UINavigationController *detailNavController;

@property (nonatomic, retain) UILongPressGestureRecognizer *lpGestureRecognizer;

@end

@implementation CompanyCollectionViewController

static NSString * const reuseIdentifier = @"NCCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Mobile Companies";
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    [self.collectionView setBackgroundColor: [UIColor lightGrayColor]];
    
    // Register cell classes
    UINib *ncCellNib = [UINib nibWithNibName:@"NCCollectionViewCell" bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:ncCellNib forCellWithReuseIdentifier:reuseIdentifier];
    
    [self setupCollectionViewLayout];
    [self setupNavigationButtons];
    
    self.lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self.collectionView addGestureRecognizer:self.lpGestureRecognizer];

    
    // Do any additional setup after loading the view.
    [[NavCtrlDAO sharedInstance] loadCompanyList:^{
        [[NavCtrlDAO sharedInstance] fetchStockQuotes:^{
            [self.collectionView reloadData];
            [self enableUndoRedoButtons];
        }];
    }];
}

- (void) setupCollectionViewLayout {
    CGSize viewSize = [self.view bounds].size;
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)[self collectionViewLayout];
    
    CGSize currentItemSize = flowLayout.itemSize;
    flowLayout.itemSize = CGSizeMake(viewSize.width/2 - 1, currentItemSize.height);
    flowLayout.minimumLineSpacing = 1.5f;
    flowLayout.minimumInteritemSpacing = 1.0f;
}

- (void) setupNavigationButtons {
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *companies = [[NavCtrlDAO sharedInstance] getCompanyList];
    return [companies count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NCCollectionViewCell *cell = (NCCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    Company *company = [[NavCtrlDAO sharedInstance] getCompanyAtIndex:indexPath.item];
    cell.titleLabel.text = company.name;
    
    UIImage *image = [UIImage imageNamed:company.icon];
    if (!image) { image = [UIImage imageNamed:@"Sunflower.gif"]; }
    [[cell imageView] setImage:image];
    
    NSString *stockPrice = [[NavCtrlDAO sharedInstance] getStockQuoteForSymbol:company.stockSymbol];
    cell.subTitleLabel.text = (!stockPrice || [stockPrice isEqualToString:@""])
        ? @""
        : [NSString stringWithFormat:@"%@: %@", company.stockSymbol, stockPrice];
    
    cell.editing = self.isEditing;
    cell.actionButtonDelegate = self;
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
 // Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return !self.isEditing;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self showProductsForCompanyAtIndex: indexPath.item];
}

-(BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.item == destinationIndexPath.item) return;
    [[NavCtrlDAO sharedInstance] moveCompanyFromIndex: sourceIndexPath.item
                                              toIndex: destinationIndexPath.item
                                      completionBlock: ^{
                                          [self.collectionView reloadData];
                                          [self enableUndoRedoButtons];
                                      }];
}

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return No;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    NSLog(@"collectionView perfomAction: %@", sender);
}
*/

- (void) showProductsForCompanyAtIndex:(NSUInteger)index {
    if (!self.productViewController) {
         ProductCollectionViewController *productViewController  = [[ProductCollectionViewController alloc] initWithNibName:@"ProductCollectionViewController" bundle:[NSBundle mainBundle]];
        
        self.productViewController = productViewController;
        [productViewController release];
    }
    
    self.productViewController.company = [[NavCtrlDAO sharedInstance] getCompanyAtIndex:index];
    [self.navigationController pushViewController:self.productViewController animated:YES];
}

- (void) showCompanyDetailView:(Company *)company {
    if (!self.detailViewController) {
        CompanyDetailViewController *detailViewController = [[CompanyDetailViewController alloc] initWithNibName:@"CompanyDetailViewController" bundle:[NSBundle mainBundle]];
        
        UINavigationController *detailNavController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
        [detailNavController setModalPresentationStyle: UIModalPresentationFormSheet];
        
        self.detailNavController = detailNavController;
        self.detailViewController = detailViewController;
        
        [detailViewController release];
        [detailNavController release];
    }
    
    self.detailViewController.company = company;
    self.detailViewController.completionHandler = ^{
        [[NavCtrlDAO sharedInstance] fetchStockQuotes:^{
            [self.collectionView reloadData];
            [self enableUndoRedoButtons];
        }];
    };
    
    [self.detailViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    [self showDetailViewController:self.detailViewController.navigationController sender:self];
}

- (void) handleAdd {
    [self showCompanyDetailView:nil];
}

- (void) handleUndo {
    [[NavCtrlDAO sharedInstance] undoCompany:^{
        [self.collectionView reloadData];
        [self enableUndoRedoButtons];
    }];
}

- (void) handleRedo {
    [[NavCtrlDAO sharedInstance] redoCompany:^{
        [self.collectionView reloadData];
        [self enableUndoRedoButtons];
    }];
}

- (void) handleDetail:(NCCollectionViewCell *)sender {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
    Company *company = [[NavCtrlDAO sharedInstance] getCompanyAtIndex:indexPath.item];
    
    [self showCompanyDetailView:company];
}

- (void) handleDelete:(NCCollectionViewCell *)sender {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
    
    [[NavCtrlDAO sharedInstance] deleteCompanyAtIndex:indexPath.item];
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
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

- (void) dealloc {
    [_addButtonItem release];
    [_undoButton release];
    [_redoButton release];
    [_productViewController release];
    [_detailViewController release];
    [_detailNavController release];
    [_lpGestureRecognizer release];
    [super dealloc];;
}

@end
