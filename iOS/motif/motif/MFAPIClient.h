//
//  MFAuthentication.h
//  motif
//
//  Created by Si Te Feng on 4/4/15.
//  Copyright (c) 2015 Si Te Feng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    CIOEmailProviderTypeGenericIMAP = 0,
    CIOEmailProviderTypeGmail = 1,
    CIOEmailProviderTypeYahoo = 2,
    CIOEmailProviderTypeAOL = 3,
    CIOEmailProviderTypeHotmail = 4,
} CIOEmailProviderType;


@protocol MFAPIClientDelegate;
@interface MFAPIClient : NSObject

@property (nonatomic, weak) id<MFAPIClientDelegate> delegate;

@property (nonatomic, copy) NSString *tokenKey;
@property (nonatomic, copy) NSString *userId;

+ (instancetype)sharedClient;
- (void)registerNewUserAndAccount;
- (void)getUserInformationWithToken:(NSString *)token;

@end




@protocol MFAPIClientDelegate <NSObject>

@optional
- (void)apiClient:(MFAPIClient *)apiClient registerCompletedWithSuccess:(BOOL)success redirectURL:(NSURL *)url error:(NSError *)error;

- (void)apiClient:(MFAPIClient *)apiClient getUserInfoWithSuccess:(BOOL)success userId:(NSString *)userId;

@end

