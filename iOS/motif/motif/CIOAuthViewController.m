//
//  CIOAuthViewController.m
//  Context.IO iOS Example App
//
//  Created by Kevin Lord on 1/16/13.
//  Copyright (c) 2013 Context.IO. All rights reserved.
//

#import "CIOAuthViewController.h"

#import "MFAPIClient.h"

@interface CIOAuthViewController () <MFAPIClientDelegate>

@property (nonatomic, strong) MFAPIClient *apiClient;

@property (nonatomic, assign) NSInteger selectedProviderType;

@property (nonatomic, strong) UIViewController *loginWebViewController;
@property (weak, nonatomic) IBOutlet UITextView *instructionsTextView;

@property (weak, nonatomic) IBOutlet UIButton *gmailButton;
@property (weak, nonatomic) IBOutlet UIButton *yahooButton;
@property (weak, nonatomic) IBOutlet UIButton *aolButton;

@end

@implementation CIOAuthViewController

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
    _apiClient = [[MFAPIClient alloc] init];
    _apiClient.delegate = self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Connect Account", @"");
    
    self.instructionsTextView.backgroundColor = [UIColor clearColor];
    self.instructionsTextView.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0f];
    self.instructionsTextView.textColor = [UIColor colorWithWhite:(103.0f/255.0f) alpha:1.0f];
    self.instructionsTextView.textAlignment = NSTextAlignmentCenter;
    self.instructionsTextView.text = NSLocalizedString(@"Sign in to connect your email account with Message Finder.", @"");
    [self.view addSubview:self.instructionsTextView];
    
    UIImage *providerButtonBgImage = [[UIImage imageNamed:@"button-provider-bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(76.0f, 7.0f, 76.0f, 7.0f)];
    
    self.gmailButton.titleLabel.text = @"";
    self.gmailButton.tag = CIOEmailProviderTypeGmail;
    [self.gmailButton setBackgroundImage:providerButtonBgImage forState:UIControlStateNormal];
    [self.gmailButton setImage:[UIImage imageNamed:@"button-provider-gmail.png"] forState:UIControlStateNormal];
    [self.view addSubview:self.gmailButton];
    
    self.yahooButton.titleLabel.text = @"";
    self.yahooButton.tag = CIOEmailProviderTypeYahoo;
    [self.yahooButton setBackgroundImage:providerButtonBgImage forState:UIControlStateNormal];
    [self.yahooButton setImage:[UIImage imageNamed:@"button-provider-yahoo.png"] forState:UIControlStateNormal];
    [self.view addSubview:self.yahooButton];
    
    self.aolButton.titleLabel.text = @"";
    self.aolButton.tag = CIOEmailProviderTypeAOL;
    [self.aolButton setBackgroundImage:providerButtonBgImage forState:UIControlStateNormal];
    [self.aolButton setImage:[UIImage imageNamed:@"button-provider-aol.png"] forState:UIControlStateNormal];
    [self.view addSubview:self.aolButton];
}


#pragma mark Actions

- (void)cancelButtonPressed {
    [self.delegate userCancelledLogin];
}


- (IBAction)hostButtonPressed:(id)sender {
    
    CIOEmailProviderType providerType = (CIOEmailProviderType)((UIButton *)sender).tag;
    self.selectedProviderType = providerType;
    
    [self.apiClient registerNewUserAndAccount];

}

@end
