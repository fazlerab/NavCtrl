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

@end

@implementation NewCompanyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(handleCancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(handleSave)];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
    [self.companyNameTextField setDelegate:self];
    [self.companyLogoTextField setDelegate:self];
}

- (void) viewWillAppear:(BOOL)animated {
    if (self.company) {
        self.title = self.company.name;
        [self.companyNameTextField setText:self.company.name];
        [self.companyLogoTextField setText:self.company.icon];
        
    } else {
        self.title = @"New Company";
        [self.companyNameTextField setText:@""];
        [self.companyLogoTextField setText:@""];
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
    NSString *companyName = [self.companyNameTextField text];
    companyName = [companyName stringByTrimmingCharactersInSet:
                   [NSCharacterSet characterSetWithCharactersInString:@" "]];
    
    // validate missing product name
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

    NSString *companyLogo = [self.companyLogoTextField text];
    companyLogo = [companyLogo stringByTrimmingCharactersInSet:
                  [NSCharacterSet characterSetWithCharactersInString:@" "]];
    
    if (self.company) {
        self.company.name = companyName;
        self.company.icon = companyLogo;
        [self.presentingViewController.childViewControllers.lastObject updateCompany:self.company];
    } else {
        self.company = [[Company alloc] initWithName:companyName icon:companyLogo];
        [self.presentingViewController.childViewControllers.lastObject addCompany:self.company];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    [_companyNameTextField release];
    [_companyLogoTextField release];
    [self.company release];
    [super dealloc];
}

@end
