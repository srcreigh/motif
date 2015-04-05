//
//  MFWelcomeViewController.m
//  motif
//
//  Created by Si Te Feng on 4/5/15.
//  Copyright (c) 2015 Si Te Feng. All rights reserved.
//

#import "MFWelcomeViewController.h"

#import <Parse/Parse.h>
#import <AFNetworking/AFNetworking.h>

@interface MFWelcomeViewController ()

@property (nonatomic, strong) MFAPIClient *apiClient;

@end

@implementation MFWelcomeViewController

- (instancetype)init {
    if (self = [super init]) {
        _apiClient = [MFAPIClient sharedClient];
        _apiClient.delegate = self;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Welcome";
}



- (void)apiClient:(MFAPIClient *)apiClient getUserInfoWithSuccess:(BOOL)success userId:(NSString *)userId {
    if (!success) {
        return;
    }
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setObject:userId forKey:@"user_id"];
    [currentInstallation saveInBackground];
    self.apiClient.userId = userId;
    
    // send stuff to shane
    NSString *userIdURLString = [NSString stringWithFormat:@"http://motif-905.appspot.com/user/%@/on_create", userId];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:userIdURLString]];
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"ERROR: %@", connectionError.localizedDescription);
            return;
        }
        
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"response: %@", responseDict);
        
    }];
    
    
}


@end



//
//AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
//serializer.acceptableContentTypes = [serializer.acceptableContentTypes arrayByAddingObject:@"text/html"];
//
//[manager POST:userIdURLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//    
//} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//    
//    NSLog(@"Failed: %@", error.localizedDescription);
//}];



