//
//  MFSignInViewController.m
//  motif
//
//  Created by Si Te Feng on 4/5/15.
//  Copyright (c) 2015 Si Te Feng. All rights reserved.
//

#import "MFWebViewController.h"

@interface MFWebViewController ()

@property (nonatomic, strong) NSURL *url;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation MFWebViewController

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        _url = url;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Sign In";
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];

    [self.webView loadRequest:request];
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

@end
