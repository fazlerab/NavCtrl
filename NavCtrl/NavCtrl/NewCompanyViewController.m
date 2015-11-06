//
//  NewCompanyViewController.m
//  NavCtrl
//
//  Created by Imran on 11/2/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import "NewCompanyViewController.h"
#import "CompanyViewController.h"
#import "Company.h"

@interface NewCompanyViewController () <UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UITextField *companyNameTextField;
@property (retain, nonatomic) IBOutlet UITextField *companyLogoTextField;
@property (retain, nonatomic) IBOutlet UITextField *tickerSymbolTextField;

@end

@implementation NewCompanyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(handleCancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(handleSave)];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

- (void) viewWillAppear:(BOOL)animated {
    if (self.company) {
        self.title = self.company.name;
        [self.companyNameTextField setText:self.company.name];
        [self.companyLogoTextField setText:self.company.icon];
        [self.tickerSymbolTextField setText:self.company.stockSymbol];
    } else {
        self.title = @"New Company";
        [self.companyNameTextField setText:@""];
        [self.companyLogoTextField setText:@""];
        [self.tickerSymbolTextField setText:@""];
    }
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) handleCancel {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) handleSave {
    NSCharacterSet *spaceCharSet = [NSCharacterSet characterSetWithCharactersInString:@" "];

    // Set company name
    NSString *companyName = [self.companyNameTextField text];
    companyName = [companyName stringByTrimmingCharactersInSet:spaceCharSet];
    
    // validate missing product name, popup alert if company name is empty
    if ([companyName isEqualToString:@""]) {
        UIAlertController *alert = [UIAlertController  alertControllerWithTitle:@"Missing Company Name"
                                                                        message:@"Please enter a company name"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *alertAction) {
                                                                  [self.companyNameTextField becomeFirstResponder];
                                                              }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    // Set company ticker symbol
    NSString *symbol = [self.tickerSymbolTextField text];
    symbol = [symbol stringByTrimmingCharactersInSet:spaceCharSet];
    symbol = [symbol uppercaseString];
    
    // Set company logo
    NSString *companyLogo = [self.companyLogoTextField text];
    companyLogo = [companyLogo stringByTrimmingCharactersInSet:
                  [NSCharacterSet characterSetWithCharactersInString:@" "]];
    
    // Update or create new company
    if (self.company) {
        self.company.name = companyName;
        self.company.icon = companyLogo;
        self.company.stockSymbol = symbol;
        
        [self.presentingViewController.childViewControllers.lastObject updateCompany:self.company];
    } else {
        self.company = [[Company alloc] initWithName:companyName icon:companyLogo];
        self.company.stockSymbol = symbol;
        [self.presentingViewController.childViewControllers.lastObject addCompany:self.company];
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    [_companyNameTextField release];
    [_companyLogoTextField release];
    [_tickerSymbolTextField release];
    [_tickerSymbolTextField release];
    [self.company release];
    [super dealloc];
}

@end
