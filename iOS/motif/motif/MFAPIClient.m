//
//  MFAuthentication.m
//  motif
//
//  Created by Si Te Feng on 4/4/15.
//  Copyright (c) 2015 Si Te Feng. All rights reserved.
//

#import "MFAPIClient.h"

#import <AFNetworking/AFNetworking.h>

static NSString *const MFNewUserAndAccountPOSTURL = @"https://api.context.io/lite/connect_tokens";
static NSString *const MFOAuthProvidersPOSTURL = @"https://api.context.io/2.0/oauth_providers";

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
    [self setupOAuthProvider];
    
    NSDictionary *parameters = @{@"callback_url": @"www.google.com"};
    [self.manager POST:MFNewUserAndAccountPOSTURL parameters:parameters success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        
        NSLog(@"success");
        NSLog(@"response: %@", responseObject);
        
        if ([self.delegate respondsToSelector:@selector(apiClient:registerCompletedWithSuccess:responseObject:error:)]) {
            [self.delegate apiClient:self registerCompletedWithSuccess:YES responseObject:responseObject error:nil];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"failed");
        
        if ([self.delegate respondsToSelector:@selector(apiClient:registerCompletedWithSuccess:responseObject:error:)]) {
            [self.delegate apiClient:self registerCompletedWithSuccess:NO responseObject:nil error:error];
        }
    }];
    
}













@end
