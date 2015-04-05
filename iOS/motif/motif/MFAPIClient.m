//
//  MFAuthentication.m
//  motif
//
//  Created by Si Te Feng on 4/4/15.
//  Copyright (c) 2015 Si Te Feng. All rights reserved.
//

#import "MFAPIClient.h"

#import <AFNetworking/AFNetworking.h>

#import <MPOAuth.h>


static NSString *const MFParamConsumerKey = @"consumer_key";
static NSString *const MFParamConsumerSecret = @"consumer_secret";
static NSString *const MFParamCallbackUrl = @"callback_url";

static NSString *const MFConsumerKey = @"uqt7o22b";
static NSString *const MFConsumerSecret = @"k948tJki1A1pvAn0";

static NSString *const MFUsername = @"fengsite@hotmail.com";
static NSString *const MFPassword = @"Site940909";

static NSString *const MFBaseURL = @"https://api.context.io";
static NSString *const MFNewUserAndAccountPOSTURL = @"/lite/connect_tokens";
static NSString *const MFOAuthProvidersPOSTURL = @"/2.0/oauth_providers";

static NSString *const MFCredentialIdentifier = @"MFCredentialIdentifier";

@interface MFAPIClient()

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

@property (nonatomic, strong) NSString *consumerKey;
@property (nonatomic, strong) NSString *consumerSecret;

@end

@implementation MFAPIClient

- (instancetype)init {
    if (self = [super init]) {
        _manager = [AFHTTPRequestOperationManager manager];
    }
    return self;
}



- (void)registerNewUserAndAccount {
    
    NSDictionary *credentials = @{kMPOAuthCredentialConsumerKey:MFConsumerKey,
                                  kMPOAuthCredentialConsumerSecret:MFConsumerSecret
                                  };
    
    NSURL *newAccountURL = [NSURL URLWithString:MFNewUserAndAccountPOSTURL];
    NSURL *baseURL = [NSURL URLWithString:MFBaseURL];
    
    MPOAuthAPI *oauthAPI = [[MPOAuthAPI alloc] initWithCredentials:credentials
                                      authenticationURL:newAccountURL
                                             andBaseURL:baseURL];
    
    NSDictionary *connectTokenParam = @{MFParamCallbackUrl: @"motif://"};
    NSArray *parameters = @[connectTokenParam];
    
    [oauthAPI performPOSTMethod:MFNewUserAndAccountPOSTURL atURL:baseURL withParameters:parameters withTarget:oauthAPI andAction:@selector(postMethodPerformed:receivingData:)];
    
    
}


- (void)postMethodPerformed:(MPOAuthAPIRequestLoader *)loader receivingData:(NSData *)data {
    
    NSLog(@"performed: %@", loader);
    
}





@end
