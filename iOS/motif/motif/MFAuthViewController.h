//
//  CIOAuthViewController.h
//  Context.IO iOS Example App
//
//  Created by Kevin Lord on 1/16/13.
//  Copyright (c) 2013 Context.IO. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MFAPIClient.h"

@protocol CIOAuthViewController <NSObject>
- (void)userCompletedLogin;
- (void)userCancelledLogin;
@end

@interface MFAuthViewController : UIViewController <MFAPIClientDelegate>


@end
