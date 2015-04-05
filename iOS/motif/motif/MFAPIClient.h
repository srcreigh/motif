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

- (void)registerNewUserAndAccount;

@end



@protocol MFAPIClientDelegate <NSObject>


@optional
- (void)apiClient:(MFAPIClient *)apiClient registerCompletedWithSuccess:(BOOL)success responseObject:(id)responseObject error:(NSError *)error;

@end