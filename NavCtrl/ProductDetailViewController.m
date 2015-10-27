//
//  ProductDetailViewController.m
//  NavCtrl
//
//  Created by Imran on 10/26/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import "ProductDetailViewController.h"

@interface ProductDetailViewController () <UIWebViewDelegate>

@end

@implementation ProductDetailViewController

- (void) setURL:(NSURL *)URL {
    _URL = URL;
    if (_URL) {
        NSURLRequest *req = [NSURLRequest requestWithURL:_URL];
        [(UIWebView *)self.view loadRequest:req];
    }
}

- (void)loadView {
    UIWebView *webView = [[UIWebView alloc] init];
    [webView setDelegate:self];;
    [webView setScalesPageToFit:YES];
    [super setView:webView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// MARK: UIWebViewDelegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"shouldStartLoadWithRequest: url=%@", request.URL.absoluteString);
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webViewDidStartLoad:");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad:");
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error {
    NSLog(@"didFailLoadWithError: %@", error.localizedDescription);
}

- (void) dealloc {
    ((UIWebView *)self.view).delegate = nil;
    [super dealloc];
}

@end
