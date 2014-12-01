//
//  ELAppDelegate.h
//  MC HW
//
//  Created by Eric Lubin on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ELAppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) TSUser *activeUser;

@property (nonatomic) NSUInteger supportediPhoneOrientations;
+(id)sharedDelegate;
-(void)checkForUpdates:(BOOL)showNoneAvailable;
-(void)checkForUpdates;

-(UIViewController*)topMostModalViewController;
@end
