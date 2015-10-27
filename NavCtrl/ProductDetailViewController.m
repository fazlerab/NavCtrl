//
//  ProductDetailViewController.m
//  NavCtrl
//
//  Created by Imran on 10/26/15.
//  Copyright © 2015 Aditya Narayan. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "ProductDetailViewController.h"

@interface ProductDetailViewController () <WKNavigationDelegate>

@end

@implementation ProductDetailViewController

- (void) setURL:(NSURL *)URL {
    _URL = URL;
    if (_URL) {
        NSURLRequest *req = [NSURLRequest requestWithURL:_URL];
        [(WKWebView *)self.view loadRequest:req];
    }
}

- (void)loadView {
    WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:[UIScreen mainScreen].bounds
                                            configuration:webViewConfig];
    webView.navigationDelegate = self;
    [super setView:webView];
    
//    UIWebView *webView = [[UIWebView alloc] init];
//    [webView setDelegate:self];;
//    [webView setScalesPageToFit:YES];
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
- (void) dealloc {
    ((WKWebView *)self.view).navigationDelegate = nil;
    [super dealloc];
}

// MARK: UIWebViewDelegate methods
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error {
    NSLog(@"didFailLoadWithError: %@", error.localizedDescription);
}

// MARK: WKNavigationDelegate methods
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"didFailNavigation: %@", error.localizedDescription);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"didFailProvisionalNavigation: %@", error.localizedDescription);
}

@end
