//
//  CIOAuthViewController.m
//  Context.IO iOS Example App
//
//  Created by Kevin Lord on 1/16/13.
//  Copyright (c) 2013 Context.IO. All rights reserved.
//

#import "MFAuthViewController.h"

#import "MFAPIClient.h"
#import "MFSignInViewController.h"

@interface MFAuthViewController () <MFAPIClientDelegate>

@property (nonatomic, strong) MFAPIClient *apiClient;

@property (nonatomic, assign) NSInteger selectedProviderType;

@property (nonatomic, strong) UIViewController *loginWebViewController;
@property (weak, nonatomic) IBOutlet UITextView *instructionsTextView;

@property (weak, nonatomic) IBOutlet UIButton *gmailButton;
@property (weak, nonatomic) IBOutlet UIButton *yahooButton;
@property (weak, nonatomic) IBOutlet UIButton *aolButton;

@end

@implementation MFAuthViewController

- (id)init {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    _apiClient = [MFAPIClient sharedClient];
    _apiClient.delegate = self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Connect Account", @"");
    
    self.instructionsTextView.backgroundColor = [UIColor clearColor];
    self.instructionsTextView.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0f];
    self.instructionsTextView.textColor = [UIColor colorWithWhite:(103.0f/255.0f) alpha:1.0f];
    self.instructionsTextView.textAlignment = NSTextAlignmentCenter;
    self.instructionsTextView.text = NSLocalizedString(@"Sign in to connect your email account with Motif.", @"");
    [self.view addSubview:self.instructionsTextView];
    
    UIImage *providerButtonBgImage = [[UIImage imageNamed:@"button-provider-bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(76.0f, 7.0f, 76.0f, 7.0f)];
    
    self.gmailButton.titleLabel.text = @"";
    self.gmailButton.tag = CIOEmailProviderTypeGmail;
    [self.gmailButton setBackgroundImage:providerButtonBgImage forState:UIControlStateNormal];
//    [self.gmailButton setImage:[UIImage imageNamed:@"button-provider-gmail.png"] forState:UIControlStateNormal];
    [self.view addSubview:self.gmailButton];
    
    [self.yahooButton setTitle:@"Sign In" forState:UIControlStateNormal];
    [self.yahooButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.yahooButton.tag = CIOEmailProviderTypeYahoo;
    [self.yahooButton setBackgroundImage:providerButtonBgImage forState:UIControlStateNormal];
//    [self.yahooButton setImage:[UIImage imageNamed:@"button-provider-yahoo.png"] forState:UIControlStateNormal];
    [self.yahooButton setBackgroundImage:[UIImage imageNamed:@"PBOrangeButton"] forState:UIControlStateNormal];
    [self.view addSubview:self.yahooButton];
    
    self.aolButton.titleLabel.text = @"";
    self.aolButton.tag = CIOEmailProviderTypeAOL;
    [self.aolButton setBackgroundImage:providerButtonBgImage forState:UIControlStateNormal];
//    [self.aolButton setImage:[UIImage imageNamed:@"button-provider-aol.png"] forState:UIControlStateNormal];
    [self.view addSubview:self.aolButton];
}


#pragma mark - Button callBacks

- (IBAction)hostButtonPressed:(id)sender {
    
    CIOEmailProviderType providerType = (CIOEmailProviderType)((UIButton *)sender).tag;
    self.selectedProviderType = providerType;
    
    [self.apiClient registerNewUserAndAccount];

}

#pragma mark - 

- (void)apiClient:(MFAPIClient *)apiClient registerCompletedWithSuccess:(BOOL)success redirectURL:(NSURL *)url error:(NSError *)error {
    if (success) {
        [[UIApplication sharedApplication] openURL:url];
    } else {
        NSLog(@"Failed");
    }
}

@end
