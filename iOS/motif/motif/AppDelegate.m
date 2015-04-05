//
//  AppDelegate.m
//  motif
//
//  Created by Si Te Feng on 4/4/15.
//  Copyright (c) 2015 Si Te Feng. All rights reserved.
//

#import "AppDelegate.h"

#import <Parse/Parse.h>
#import "MFAuthViewController.h"
#import "MFAPIClient.h"
#import "MFWelcomeViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) MFAPIClient *apiClient;
@property (nonatomic, strong) UINavigationController *navController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MFAuthViewController *authViewController = (MFAuthViewController *)[storyboard instantiateInitialViewController];
    self.navController = [[UINavigationController alloc] initWithRootViewController:authViewController];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    
    // Parse Registration
    [Parse setApplicationId:@"4q8F1iczUazaKPIoUY0QXAjJDHxMZv70M7ebnEIr"
                  clientKey:@"AAcSr2ack2RzGPJIHBRkomsjIpNUZEHV6bVSqwk8"];
    
    // Register for Push Notitications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    
    // Push Notification Handling
    NSDictionary *remoteNotificationDictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotificationDictionary) {
        [self handleRemoteNotificationWithDictionary:remoteNotificationDictionary];
    }
    
    return YES;
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    
    [self handleRemoteNotificationWithDictionary:userInfo];
}


- (void)handleRemoteNotificationWithDictionary:(NSDictionary *)userInfo {
    NSLog(@"userInfo: %@", userInfo);
    
    NSString *token = [userInfo objectForKey:@"url"];
    if ([token isKindOfClass:NSString.class]) {
        NSRange range = [token rangeOfString:@"="];
        NSUInteger startLocation = range.location + 1;
        NSString *substring = [token substringFromIndex:startLocation];
        token = substring;
    }
    
    MFAPIClient *apiClient = self.apiClient;
    apiClient.tokenKey = token;
    
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    if (!userInfo || ![aps isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    id alertContent = [aps objectForKey:@"alert"];
    
    if ([alertContent isKindOfClass:[NSString class]]) {
        [self openURLWithString:alertContent];
    } else if ([alertContent isKindOfClass:[NSDictionary class]]) {
        NSString *body = [(NSDictionary *)alertContent objectForKey:@"body"];
        [self openURLWithString:body];
    }
    
    
    id link = [userInfo objectForKey:@"link"];
    if (link && [link isKindOfClass:[NSString class]]) {
        [self openURLWithString:(NSString *)link];
    }

}


- (void)openURLWithString:(NSString *)string {
    NSURL *linkURL = [NSURL URLWithString:string];
    if (linkURL) {
        [[UIApplication sharedApplication] openURL:linkURL];
    }
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    // Open Motif with custom app url scheme
    
    NSLog(@"url: %@", url);
    
    // TODO: assuming the url is always opened from login web view
    self.apiClient = self.apiClient;
    
    MFWelcomeViewController *welcomeVC = [[MFWelcomeViewController alloc] init];
    
    welcomeVC.navigationItem.hidesBackButton = YES;
    [self.navController pushViewController:welcomeVC animated:YES];
    
    [self.apiClient getUserInformationWithToken:self.apiClient.tokenKey];
    
    return YES;
}


- (MFAPIClient *)apiClient {
    if (!_apiClient) {
        _apiClient = [MFAPIClient sharedClient];
    }
    return _apiClient;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.technochimera.motif" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"motif" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"motif.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
