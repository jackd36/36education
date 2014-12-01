//
//  AppStartViewController.m
//  MC HW
//
//  Created by Eric Lubin on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppStartViewController.h"

#import "TutorActionsViewController.h"
#import "ViewAssignmentViewController.h"
#import "ELAppDelegate.h"
#import "GenericTestUploadHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "ChangePasswordViewController.h"
#import "UnuploadedTestsViewController.h"
#import "LeftViewControllerContainerSVC.h"
#import "DefaultViewControlleriPadSplitViewController.h"
@interface AppStartViewController()
-(IBAction)authUser;
@end
@implementation AppStartViewController
@synthesize username,password,animatedNavBar;

-(id)init{
    if(self = [self initWithNibName:@"AppStartViewController" bundle:nil]){
        animatedNavBar = YES;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        else
            self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super initWithCoder:aDecoder]){
        animatedNavBar = YES;
    }
    
    return self;
}
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        animatedNavBar = YES;
//        // Custom initialization
//    }
//    return self;
//}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
-(void)presentFallbackUploaderIfNeeded{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger uid;
    if([[defaults dictionaryRepresentation] valueForKey:LAST_LOGGED_IN_KEY] == nil){
        uid = NSNotFound;
    }
    else {
        uid = [defaults integerForKey:LAST_LOGGED_IN_KEY];
        
    }
    
    NSArray *existing = [GenericTestUploadHTTPRequest allUnuploadedTestsForUser:uid];
    if([existing count] >0){
        self.animatedNavBar = NO;
        UnuploadedTestsViewController *vc2 = [[UnuploadedTestsViewController alloc] initWithUID:uid];
        UINavigationController *nc2 = [[UINavigationController alloc] initWithRootViewController:vc2];
        nc2.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:nc2 animated:YES completion:^{self.animatedNavBar =YES;}];
        //[vc2 release];
        //[nc2 release];
    }
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self presentFallbackUploaderIfNeeded];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    
    if(DEBUG){
        UILabel *debugLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        debugLabel.text = @"DEBUG";
        debugLabel.textColor = [UIColor redColor];
        [debugLabel sizeToFit];
        [self.view addSubview:debugLabel];
        //[debugLabel release];
        debugLabel.center = CGPointMake(self.view.bounds.size.width/2,self.view.bounds.size.height-50);
    }
    [super viewDidLoad];
    
    //self.view.backgroundColor = [UIColor blackColor];
    
    
    

    username.text = [TSHTTPRequest username];
        username.delegate = self;
        password.text = [TSHTTPRequest password];
        password.delegate = self;
    
//    self.tableView.backgroundView = nil;
//    self.tableView.backgroundColor = nil;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:THIRTY_SIX_DID_CHANGE_PASSWORD object:nil];
    // Do any additional setup after loading the view from its nib.
}

-(void)receivedNotification:(NSNotification*)notif{
    if([notif.name isEqualToString:THIRTY_SIX_DID_CHANGE_PASSWORD]){
        password.text = nil;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    [self dismissKeyboard];
}
-(IBAction)dismissKeyboard{
    [username resignFirstResponder];
    [password resignFirstResponder];
}
- (void)dealloc {

    //[username release];
    //[password release];
    //[super dealloc];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    
//    if(animatedNavBar)
//        [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.view.window.backgroundColor = [UIColor whiteColor];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    if(animatedNavBar)
//        [self.navigationController setNavigationBarHidden:NO animated:animated];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.view.window.backgroundColor = kDefaultTableViewBackgroundColor;
}
-(BOOL)textFieldShouldReturn:(UITextField*)textField{
    if(textField == username)
        [password becomeFirstResponder];
    else if(textField == password){
        [self authUser];
    }
    return YES;
}



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 75) ? NO : YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
//-(NSUInteger)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskPortrait;
//}
//-(BOOL)shouldAutorotate{
//    return YES;
//}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}
//- (void)shakeView:(UIView*)view
//{
//	CGRect r = view.frame;
//	r.origin.x = r.origin.x - r.origin.x * 0.1;
//	
//	CGContextRef context = UIGraphicsGetCurrentContext();
//	[UIView beginAnimations:nil context:context];
//	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//	[UIView setAnimationDuration:.1f];
//	[UIView setAnimationRepeatCount:5];
//	[UIView setAnimationRepeatAutoreverses:NO];
//	[view setFrame:r];
//	
//	[UIView commitAnimations];
//}
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(indexPath.row == 0){
//        [username becomeFirstResponder];
//    }
//    else if(indexPath.row == 1){
//        [password becomeFirstResponder];
//    }
//}
//
//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return 1;
//}
//
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return 2;
//}
//
//-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//   
//    if(indexPath.row == 0){
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Email" forIndexPath:indexPath];
//        username = (UITextField*)[cell viewWithTag:33];
//        username.text = [TSHTTPRequest username];
//        username.delegate = self;
//        return cell;
//    }
//    else{ 
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Password" forIndexPath:indexPath];
//        password = (UITextField*)[cell viewWithTag:33];
//        password.text = [TSHTTPRequest password];
//        password.delegate = self;
//        return cell;
//    }
//    
//}

-(IBAction)forgotPassword:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Reset" message:@"Enter your e-mail, and we'll send instructions to reset your password." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Reset", nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *tf = [alert textFieldAtIndex:0];
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    tf.placeholder = @"my_email@gmail.com";
    tf.text = self.username.text;
    tf.delegate = self;
    [alert show];
    //[alert release];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *email = [alertView textFieldAtIndex:0].text;

    if(buttonIndex == 1 && [[email stringByReplacingOccurrencesOfString:@" " withString:@""] length] > 0){
        TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:@"password_reset/"];
        [request addPostValue:email forKey:@"email"];
        request.useSVProgressHUD = YES;
        request.responseStringAsErrorMessage = YES;
        //request.requestContainer = self;
        request.progressMaskType = SVProgressHUDMaskTypeClear;
        request.cachePolicy = ASIDoNotReadFromCacheCachePolicy | ASIDoNotWriteToCacheCachePolicy;
        request.progressSuccessText = @"Recover password email successfully sent.";
        [request startAsynchronous];
    }
}

-(IBAction)authUser{
//    [self shakeView:self.password];
//    return;
    //
    
    if(username.text == nil)
        username.text = @"";
    if(password.text == nil)
        password.text = @"";

    
    
    __block TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:@"auth/"];
    __weak TSHTTPRequest *weakRequest = request;
    request.cachePolicy = ASIDoNotReadFromCacheCachePolicy | ASIDoNotWriteToCacheCachePolicy;
    //request.requestContainer = self;
    request.useSVProgressHUD = YES;
    request.username = username.text;
    request.password = password.text;
    //request.authenticationScheme
    request.progressMaskType = SVProgressHUDMaskTypeClear;
    //[request addBasicAuthenticationHeaderWithUsername:username.text andPassword:password.text];
    request.shouldPresentCredentialsBeforeChallenge = YES;
    request.progressLoadingText = @"Logging in";
    request.progressSuccessText = @"Logged in";
    
    
    request.progressFailureText = @"Authentication error: Username/password incorrect.";
//    request.notSuccessBlock = ^{
//        
//        [self shakeView:self.tableView];
//    };
    request.completionBlock = ^{
        NSDictionary *dict = [[weakRequest responseData] JSONValue];
        NSLog(@"%@",dict);
        [weakRequest saveAuthenticationCredentials];
        
        //[self setUsername:username.text setPassword:password.text];
        
        TSUser *user = [[TSUser alloc] init];
        user.object_id = [[dict valueForKey:@"object_id"] intValue];
        user.firstName = [dict valueForKey:@"first_name"];
        user.lastName = [dict valueForKey:@"last_name"];
        user.email = [dict valueForKey:@"email"];
        user.username = username.text;
        user.students = [dict valueForKey:@"students"];
        //user.locations = dict[@"locations"];
        user.requirePasswordChange = [[dict valueForKey:@"require_pw_change"] boolValue];
        user.password = password.text;
        
        
        id group = [dict valueForKey:@"group"];
        id last_login = [dict valueForKey:@"last_login"];
        if(last_login != [NSNull null])
            user.lastLogin = [NSDate dateWithTimeIntervalSince1970:[last_login doubleValue]];
        user.admin = [[dict valueForKey:@"admin"] boolValue];
        user.staff = user.admin || [dict[@"staff"] boolValue];
        

        if([group isEqualToString:@"students"])
            user.userType = TSUserTypeStudent;
        else if ([group isEqualToString:@"tutors"])
            user.userType = TSUserTypeTutor;
        
        [[ELAppDelegate sharedDelegate] setActiveUser:user];
        [[NSUserDefaults standardUserDefaults] setInteger:user.object_id forKey:LAST_LOGGED_IN_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self reactToUserAuth:user];
        [self presentFallbackUploaderIfNeeded];
        
        
    };
    [request startAsynchronous];
}
//-(void)didFinishUploadingAllPreviousAttempts{
//    ELAppDelegate *delegate = [ELAppDelegate sharedDelegate];
//    [self reactToUserAuth:delegate.activeUser];
//    [SVProgressHUD dismiss];
//}
//-(id)retain{
//    NSLog(@"%d",self.retainCount);
//    
//    return [super retain];
//}
//
//-(oneway void)release{
//    NSLog(@"%d",self.retainCount);
//    [super release];
//}
-(void)reactToUserAuth:(TSUser*)user{
    
    
    UIWindow *window = [self.view window];
    ASIBasicBlock completionBlock = ^{
        if(user.requirePasswordChange){
            
            ChangePasswordViewController *vc = [[ChangePasswordViewController alloc] init];
            vc.initialOldPassword = user.password;
            vc.disableCancelButton = YES;
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
            [window.rootViewController presentViewController:nc animated:YES completion:nil];
            //[vc release];
            //[nc release];
        }
    };
    
    if(user.userType == TSUserTypeStudent){
        ViewAssignmentViewController *vc = [[ViewAssignmentViewController alloc] init];
        vc.student = user;
        //        StudentHomeViewController *vc = [[StudentHomeViewController alloc] initWithNibName:nil bundle:nil];
        //        vc.studentID = [[dict valueForKey:@"id"] integerValue];
        
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
            UISplitViewController  *split = (UISplitViewController*)window.rootViewController;
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
            split.delegate = vc;
            //reloads the delegate methods
            [split willRotateToInterfaceOrientation:split.interfaceOrientation duration:0];
            split.viewControllers = @[[[UINavigationController alloc] init],nc];
            //[nc release];
            
        }
        else{
            UINavigationController *nc = (UINavigationController*)window.rootViewController;
            nc.delegate = nil;
            [nc setViewControllers:@[vc] animated:NO];
            //[nc pushViewController:vc animated:NO];
        }
        
        [self dismissViewControllerAnimated:YES completion:completionBlock];
        //[vc release];
        
        
    }
    else if(user.userType == TSUserTypeTutor){
        
        
        
        
        
        
        
        UIWindow *window = [self.view window];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
            UISplitViewController  *split = (UISplitViewController*)window.rootViewController;
            LeftViewControllerContainerSVC *vc = [[LeftViewControllerContainerSVC alloc] init];
            vc.tutor = user;
            
            //UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
            split.delegate = vc;
            
            //vc.splitViewController = split;
            split.viewControllers = @[vc,[[UINavigationController alloc] initWithRootViewController:[[DefaultViewControlleriPadSplitViewController alloc] init]]];
            //reloads the delegate methods
            [split willRotateToInterfaceOrientation:split.interfaceOrientation duration:0];
            //[vc release];

        }
        else{
            UINavigationController *nc = (UINavigationController*)window.rootViewController;
            TutorActionsViewController *vc = [[TutorActionsViewController alloc] init];
            vc.tutor = user;
            [nc setViewControllers:@[vc] animated:NO];
            //[vc release];
            
            nc.delegate = vc;
            //[nc pushViewController:vc animated:NO];
        }
        
        [self dismissViewControllerAnimated:YES completion:completionBlock];
            //[self presentViewController:nc animated:YES completion:completionBlock];
        
        
        
        
        
        
        //NSLog(@"tutor authenticated.....logging in");
    }
    
    
    [[ELAppDelegate sharedDelegate] checkForUpdates];
    
    
}



@end
