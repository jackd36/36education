//
//  ELAppDelegate.m
//  MC HW
//
//  Created by Eric Lubin on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ELAppDelegate.h"
#import "AppStartViewController.h"
#import "ASIDownloadCache.h"
#import "GenericTestUploadHTTPRequest.h"
#import "NewBuildOfApp.h"
#import "UpdateAppViewController.h"


@interface ELAppDelegate()
@property (nonatomic,strong) NewBuildOfApp *latestBuild;
@end


@implementation ELAppDelegate

@synthesize window = _window;
@synthesize activeUser;
- (void)dealloc
{
    [_latestBuild release];
    [activeUser release];
    [super dealloc];
}
static ELAppDelegate *instance;
-(id)init{
    if(self = [super init]){
        instance = self;
    }
    return self;
}

+(id)sharedDelegate{
    return instance;
}

-(void)configureAppearance{
    
    if(!IS_IOS_7)
        [[UITableView appearance] setBackgroundColor:kDefaultTableViewBackgroundColor];
    
    [[UIToolbar appearance] setTintColor:kDefaultToolbarColor];
    [[UINavigationBar appearance] setTintColor:kDefaultToolbarColor];
    
}

-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        return UIInterfaceOrientationMaskAll;
    }
    else
        return _supportediPhoneOrientations;
    
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _supportediPhoneOrientations = UIInterfaceOrientationMaskPortrait;
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")){
        application.statusBarStyle = UIStatusBarStyleBlackOpaque;
    }
    if(!IS_IOS_7) {
        kDefaultToolbarColor = [RGBCOLOR(89, 132, 184) retain];
        kDefaultTableViewBackgroundColor = [RGBCOLOR(228,230,235) retain];
    } else {
        kDefaultToolbarColor = [RGBCOLOR(0, 91, 255) retain];
        kDefaultTableViewBackgroundColor  = [RGBCOLOR(235, 235, 241) retain];
    }


    [self configureAppearance];
    [ASIHTTPRequest setDefaultCache:[ASIDownloadCache sharedCache]];
    //[[ASIDownloadCache sharedCache] setShouldRespectCacheControlHeaders:NO];
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
//    // Override point for customization after application launch.
//    
//    
    self.window.backgroundColor = [UIColor whiteColor];
    
    //[NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"America/New_York"]];
    
    
    
    
    AppStartViewController *vc = [[AppStartViewController alloc] init];
//    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
//    [vc release];
    //vc.view.backgroundColor = [UIColor clearColor];
    //[nc setNavigationBarHidden:YES];
    
    
    //nc.navigationBar.tintColor = kDefaultToolbarColor;
    //nc.toolbar.tintColor = kDefaultToolbarColor;
    //nc.toolbar.hidden = NO;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        UISplitViewController *splitView = [[UISplitViewController alloc] init];
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.1"))
            splitView.presentsWithGesture = NO;
        splitView.viewControllers = @[[[[UIViewController alloc] init] autorelease],[[[UIViewController alloc] init] autorelease]];
        //splitView.view.backgroundColor = [UIColor clearColor];
        self.window.rootViewController = splitView;
        //vc.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    else{
        self.window.rootViewController = [[[UINavigationController alloc] init] autorelease];
    }
        
    
    
    //[nc release];
   
    
    
    
    [self.window makeKeyAndVisible];
    [self.window.rootViewController presentViewController:vc animated:NO completion:nil];
     [vc release];
    
    return YES;
}


-(void)checkForUpdates{
    [self checkForUpdates:NO];
}

//This method checks for app updates
-(void)checkForUpdates:(BOOL)showNoneAvailable{
    
    if(![TSHTTPRequest isLoggedIn])
        return;
    
    if(!showNoneAvailable){
        //we are updating in the background, only update if we havne't already checked in the last 24 hours
        NSDate *lastUpdated = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_updated"];
        if([[NSDate date] timeIntervalSinceReferenceDate] - [lastUpdated timeIntervalSinceReferenceDate] <= 86400)
            return;
        
    }
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *url =[SERVER_ADDRESS stringByAppendingFormat:@"bundle_id/%@/",infoDict[@"CFBundleIdentifier"]];
    
    __block TSHTTPRequest *request = [TSHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    request.cachePolicy = ASIDoNotReadFromCacheCachePolicy | ASIDoNotWriteToCacheCachePolicy;
    //request.secondsToCache = 86400; //we only want to check for updates once every day
    request.useSVProgressHUD = NO;
    request.completionBlock = ^{
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"last_updated"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSDictionary *dict = [[request responseData] JSONValue];
        
        NSString *buildDateString = infoDict[@"CFBuildDate"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"\"EEE MMM  d HH:mm:ss yyyy\"";
        NSDate *timestamp = [formatter dateFromString:buildDateString];
        
        NSInteger buildDate = [timestamp timeIntervalSince1970];
        
        
        
        NSInteger newVersionBuildDate = [dict[@"date_modified"] integerValue];
        if(newVersionBuildDate > buildDate){
            NewBuildOfApp *app = [[NewBuildOfApp alloc] init];
            [app setValuesForKeysWithDictionary:dict[@"app_info"]];
            self.latestBuild = app;
            [app release];
            //TODO: NEW VERSION VIEW
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Version" message:@"There is a new version of the app available." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Download", nil];
            [alert show];
            [alert release];
            
            //alert user there is a new version of the app out
        }
        else if(showNoneAvailable){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"None found" message:@"The latest version of 36 Education is already installed on this device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        
        
        
        
    };
    
    [request startAsynchronous];
    
}


-(UIViewController*)topMostModalViewController{
    UIViewController *modal = self.window.rootViewController;
    while(modal.presentedViewController != nil)
        modal = modal.presentedViewController;
    
    return modal;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        UpdateAppViewController *updateVC = [[UpdateAppViewController alloc] init];
        updateVC.app =_latestBuild;
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:updateVC];
        nc.modalPresentationStyle = UIModalPresentationFormSheet;
        updateVC.modalPresentationStyle = UIModalPresentationFormSheet;
        UIViewController *target = self.window.rootViewController;
        if(target.modalViewController != nil)
            target = target.modalViewController;
        [target presentViewController:nc animated:YES completion:nil];
        [nc release];
        [updateVC release];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self checkForUpdates];
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
