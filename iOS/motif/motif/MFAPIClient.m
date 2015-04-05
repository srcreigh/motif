//
//  MFAuthentication.m
//  motif
//
//  Created by Si Te Feng on 4/4/15.
//  Copyright (c) 2015 Si Te Feng. All rights reserved.
//

#import "MFAPIClient.h"

#import <AFNetworking/AFNetworking.h>

#import "TDOAuth.h"


static NSString *const MFParamConsumerKey = @"consumer_key";
static NSString *const MFParamConsumerSecret = @"consumer_secret";
static NSString *const MFParamCallbackUrl = @"callback_url";

static NSString *const MFConsumerKey = @"uqt7o22b";
static NSString *const MFConsumerSecret = @"k948tJki1A1pvAn0";

static NSString *const MFUsername = @"fengsite@hotmail.com";
static NSString *const MFPassword = @"Site940909";

static NSString *const MFBaseURL = @"api.context.io";
static NSString *const MFNewUserAndAccountPOSTURL = @"/lite/connect_tokens";
static NSString *const MFOAuthProvidersPOSTURL = @"/2.0/oauth_providers";

static NSString *const MFCredentialIdentifier = @"MFCredentialIdentifier";

@interface MFAPIClient()

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

@property (nonatomic, strong) NSString *consumerKey;
@property (nonatomic, strong) NSString *consumerSecret;

@end


@implementation MFAPIClient

+ (instancetype)sharedClient {
    
    static MFAPIClient *client = nil;
    
    @synchronized(self) {
        if (!client) {
            client = [[MFAPIClient alloc] init];
        }
    }
    
    return client;
}


- (instancetype)init {
    if (self = [super init]) {
        _manager = [AFHTTPRequestOperationManager manager];
    }
    return self;
}


- (void)registerNewUserAndAccount {
    
    NSDictionary *connectTokenParam = @{MFParamCallbackUrl: @"motif://", MFParamConsumerKey: MFConsumerKey, MFParamConsumerSecret: MFConsumerSecret};
    
    NSURLRequest *request = [TDOAuth URLConnectRequestForPath:MFNewUserAndAccountPOSTURL POSTParameters:connectTokenParam host:MFBaseURL consumerKey:MFConsumerKey consumerSecret:MFConsumerSecret];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        BOOL success = YES;
        if (connectionError) {
            NSLog(@"Error send: %@", connectionError.localizedDescription);
            success = NO;
        }
        
        if (!connectionError && data) {
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data
                                                                         options:0 error:nil];
            
            self.tokenKey = [responseDict objectForKey:@"token"];
            NSLog(@"tokenKey: %@", self.tokenKey);
            
            NSString *redirectURLString = [responseDict objectForKey:@"browser_redirect_url"];
            NSURL *redirectURL = [NSURL URLWithString:redirectURLString];
            
            [self.delegate apiClient:self registerCompletedWithSuccess:success redirectURL:redirectURL error:connectionError];
            
        }
    }];
}








@end
