//
//  NewProductViewController.m
//  NavCtrl
//
//  Created by Imran on 11/3/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import "NewProductViewController.h"
#import "ProductViewController.h"
#import "Product.h"

@interface NewProductViewController () <UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UITextField *productNameTextField;
@property (retain, nonatomic) IBOutlet UITextField *productURLTextField;

@end

@implementation NewProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(handleCancel)];
    [self.navigationItem  setLeftBarButtonItem: cancelButtonItem ];
    
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemSave target:self action:@selector(handleSave)];
    [self.navigationItem  setRightBarButtonItem: saveButtonItem];
}
- (void)viewWillAppear:(BOOL)animated {
    if (self.product) {
        self.title = self.product.name;
        [self.productNameTextField setText:self.product.name];
        [self.productURLTextField setText:self.product.URL];
    } else {
        self.title = @"New Product";
        [self.productNameTextField setText:@""];
        [self.productURLTextField setText:@""];
    }
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) handleCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) handleSave {
    // get product name trimmed of space before and after text
    NSString *productName = [self.productNameTextField text];
    productName = [productName stringByTrimmingCharactersInSet:
                   [NSCharacterSet characterSetWithCharactersInString:@" "]];
    
    // validate missing product name
    if ([productName isEqualToString:@""]) {
        UIAlertController *alert = [UIAlertController  alertControllerWithTitle:@"Missing Product Name"
                                                                        message:@"Please enter a product name"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *alertAction) {
                                                                  [self.productNameTextField becomeFirstResponder];
                                                              }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    NSString *productURL = [self.productURLTextField text];
    productURL = [productURL stringByTrimmingCharactersInSet:
                  [NSCharacterSet characterSetWithCharactersInString:@" "]];
    
    if (!self.product) {
        self.product = [[Product alloc] initWithName:productName andURL:productURL];
        [self.presentingViewController.childViewControllers.lastObject addProduct:self.product];
    } else {
        self.product.name = productName;
        self.product.URL = productURL;
        [self.presentingViewController.childViewControllers.lastObject updateProduct:self.product];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    [_productNameTextField release];
    [_productURLTextField release];
    [self.product release];
    [super dealloc];
}
@end
