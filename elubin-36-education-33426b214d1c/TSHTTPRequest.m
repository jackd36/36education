//
//  TSHTTPRequest.m
//  MC HW
//
//  Created by Eric Lubin on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "ELAppDelegate.h"
#import "TSHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "SVProgressHUD.h"
#import "SVModalWebViewController.h"
#import "InvalidSSLOverride.h"
NSString * const API_REALM = @"mobile.freudigman.com";
@interface TSHTTPRequest()
@property (nonatomic,strong) UIView *errorView;
+(NSURLCredential*)authenticationCredentials;
@end

@implementation TSHTTPRequest

//static BOOL overrideSSLFailure = NO;

@synthesize useSVProgressHUD,progressMaskType,progressLoadingText,progressSuccessText,progressFailureText,responseStringAsErrorMessage,showAlertMessages,errorView;
+(id)requestWithPathComponent:(NSString*)pathComponent{
    return [[[self alloc] initWithPathComponent:pathComponent] autorelease];
}

//+ (BOOL)extractIdentity:(SecIdentityRef *)outIdentity andTrust:(SecTrustRef*)outTrust fromPKCS12Data:(NSData *)inPKCS12Data
//{
//	OSStatus securityError = errSecSuccess;
//	
//	NSDictionary *optionsDictionary = [NSDictionary dictionaryWithObject:@"" forKey:(id)kSecImportExportPassphrase];
//	
//	CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
//	securityError = SecPKCS12Import((CFDataRef)inPKCS12Data,(CFDictionaryRef)optionsDictionary,&items);
//	
//	if (securityError == 0) { 
//		CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex (items, 0);
//		const void *tempIdentity = NULL;
//		tempIdentity = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemIdentity);
//		*outIdentity = (SecIdentityRef)tempIdentity;
//		const void *tempTrust = NULL;
//		tempTrust = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemTrust);
//		*outTrust = (SecTrustRef)tempTrust;
//	} else {
//		NSLog(@"Failed with error code %d",(int)securityError);
//		return NO;
//	}
//	return YES;
//}
-(id)initWithPathComponent:(NSString*)pathComponent{
    NSString *urlPath = [[self class] urlFromPathComponent:pathComponent];
    NSLog(@"url=%@",urlPath);
    if(self = [self initWithURL:[NSURL URLWithString:urlPath]]){
        self.useKeychainPersistence = YES;
        self.useSessionPersistence = YES;
        self.shouldPresentAuthenticationDialog = YES;
        self.authenticationScheme = (NSString *)kCFHTTPAuthenticationSchemeBasic;
        if(!DEBUG)
            self.validatesSecureCertificate = NO;
        else{
            InvalidSSLOverride *override = [InvalidSSLOverride sharedSSLManager];
            self.validatesSecureCertificate = !override.shouldOverrideSSLFailure;
        }
        
        
//        SecIdentityRef identity = NULL;
//        SecTrustRef trust = NULL;
//        NSData *PKCS12Data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"certificate" ofType:@"p12"]];
//        [[self class] extractIdentity:&identity andTrust:&trust fromPKCS12Data:PKCS12Data];
//        
//        [self setClientCertificateIdentity:identity];
        showAlertMessages = YES;
        
        //self.useCookiePersistence = NO;
        //self.authenticationScheme = (NSString *)kCFHTTPAuthenticationSchemeBasic;
        self.shouldPresentCredentialsBeforeChallenge = NO; //will require one extra web request on each application start, but is MUCH more secure given the session will retain the login info anyway
        
        progressMaskType = SVProgressHUDMaskTypeNone;
        self.timeOutSeconds = 60;
        self.responseStringAsErrorMessage = YES;
        //ASIAskServerIfModifiedCachePolicy | 
        
        self.cachePolicy = ASIAskServerIfModifiedCachePolicy;
        self.secondsToCache=86400*7;
        self.cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
        
        
        
    }
    
    return self;
}


+(NSString*)urlFromPathComponent:(NSString*)pathComponent{
    return [RootURL stringByAppendingString:pathComponent];
}
-(BOOL)didLoadFromWeb{
    return !self.didUseCachedResponse || self.responseStatusMessage != nil;
}
- (void)dealloc
{
    [errorView release];
    [progressFailureText release];
    [progressLoadingText release];
    [progressSuccessText release];
    [_notSuccessBlock release];
    [super dealloc];
}
-(void)requestStarted{
    if([self useSVProgressHUD])// note the network indicator is handled by ASIHTTPRequest super class automatically
        [SVProgressHUD showWithStatus:progressLoadingText maskType:progressMaskType];

    [super requestStarted];
}


-(void)requestFinished{

    dispatch_async(dispatch_get_main_queue(), ^{
        //ENSURE MAIN THREAD!
        int statusCode = [self responseStatusCode];
        //NSLog(@"%d",statusCode);
        if(statusCode >= 400){
            
            if([self useSVProgressHUD]){

                if(responseStringAsErrorMessage && ![[self responseString] isEqualToString:@""] && (statusCode != 500 || !SHOW_WEB_BASED_500) && [self.responseString rangeOfString:@"<!DOCTYPE"].location == NSNotFound)//ensures not an html/apache response
                    [SVProgressHUD showErrorWithStatus:[self responseString]];
                else if(progressFailureText != nil && (statusCode == 400 || statusCode == 403))
                    [SVProgressHUD showErrorWithStatus:progressFailureText];
                else
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"HTTP %d",statusCode]];

            }
            else if(statusCode != 500 || !SHOW_WEB_BASED_500){
                if(showAlertMessages){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"HTTP %d",statusCode] message:@"An unknown server error occured" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];

                    [alert show];
                    [alert release];
                }
            }
            
            [self valueForKey:@"reportFailure"];
            //if(runCompletionBlockOnFailure)
                //[super requestFinished];
            if(statusCode == 500 && SHOW_WEB_BASED_500){
                
    // 
//                NSString *tempDir = NSTemporaryDirectory();
//                NSString *filePath = [tempDir stringByAppendingPathComponent:@"error.html"];
//                
//                NSString *data = [[NSString alloc] initWithData:[self responseData] encoding:self.responseEncoding];
//                
//                [data writeToFile:filePath atomically:YES encoding:self.responseEncoding error:NULL];
//                [data release];

//                double delayInSeconds = 2.0;
//                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //NSStringEncoding
                SVModalWebViewController *webController = [[SVModalWebViewController alloc] initWithData:self.responseData textEncodingName:@"UTF-8"];
                webController.modalPresentationStyle = UIModalPresentationFormSheet;
                
                
                
                ELAppDelegate *del = (ELAppDelegate*)[UIApplication sharedApplication].delegate;
                [del.topMostModalViewController presentViewController:webController animated:YES completion:nil];
                [webController release];
                //});
                
//
            }
            if(_notSuccessBlock){
                _notSuccessBlock();
            }
        }
        else {
            
            [super requestFinished];
            
            if([self useSVProgressHUD]){
                if(progressSuccessText != nil)
                    [SVProgressHUD showSuccessWithStatus:progressSuccessText];
                else 
                    [SVProgressHUD dismiss];
            }
        }
    });
    // [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
-(void)dismissDebugWindow{
    [errorView removeFromSuperview];
}


-(void)failWithError:(NSError *)theError{
    [super failWithError:theError];
    
        
    NSError *underLyingError = theError.userInfo[NSUnderlyingErrorKey];
    if ([underLyingError code] <= -9800 && [underLyingError code] >= -9818) {
        if(DEBUG){
            InvalidSSLOverride *override = [InvalidSSLOverride sharedSSLManager];
            [override startAlertWithRequest:self];
        }
        [SVProgressHUD dismiss];
    
    }
    else{
        InvalidSSLOverride *override = [InvalidSSLOverride sharedSSLManager];
        [override startAlertWithRequest:self];
        
        [SVProgressHUD dismiss];
        return;
        NSLog(@"%@",[theError description]);
        
        //show alert instance variable
        if(!shouldContinueWhenAppEntersBackground && showAlertMessages){
            if([self useSVProgressHUD])
                [SVProgressHUD showErrorWithStatus:@"Connection error"];
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"An unknown error occured. Please restart your device and try again in a little bit. We apologize for the inconvenience." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
        }
        else {
            
            [self performSelector:@selector(dismissLoadingWithError:) withObject:@"An unknown error occured" afterDelay:0.5];
            
        }
        
        
        if(_notSuccessBlock){
            _notSuccessBlock();
        }
    }
    //else
        //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    
}
-(void)dismissLoadingWithError:(NSString*)errorMessage{
    [SVProgressHUD showErrorWithStatus:errorMessage];
}
+(void)removeCachedItemWithPath:(NSString*)path{
    id <ASICacheDelegate> cache = [self defaultCache];
    
    [cache removeCachedDataForURL:[NSURL URLWithString:[self urlFromPathComponent:path]]];
}
+(void)logout{
    [self clearSession];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LAST_LOGGED_IN_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSURL *url = [NSURL URLWithString:RootURL];
    NSURLProtectionSpace *protectionSpace = [[[NSURLProtectionSpace alloc] initWithHost:[url host] 
                                                                                   port:[[url port] intValue] 
                                                                               protocol:[url scheme] 
                                                                                  realm:API_REALM
                                                                   authenticationMethod:NSURLAuthenticationMethodDefault] autorelease];
    NSURLCredential *credential;
    while ((credential = [[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace:protectionSpace])) {
        [[NSURLCredentialStorage sharedCredentialStorage] removeCredential:credential forProtectionSpace:protectionSpace];
    }
}
+(NSURLCredential*)authenticationCredentials{

    NSURL *urlObject = [NSURL URLWithString:RootURL];
    NSURLCredential *cred= [self savedCredentialsForHost:[urlObject host] port:[[urlObject port] intValue] protocol:[urlObject scheme] realm:API_REALM];
    
    return cred;
}

-(void)saveAuthenticationCredentials{
    
    NSURLCredential *authenticationCredentials = [NSURLCredential credentialWithUser:self.username password:self.password persistence:NSURLCredentialPersistencePermanent];
	
	if (authenticationCredentials) {
		[ASIHTTPRequest saveCredentials:authenticationCredentials forHost:[[self url] host] port:[[[self url] port] intValue] protocol:[[self url] scheme] realm:API_REALM];
        //NSLog(@"%@",self.authenticationRealm);
	}
}
+(void)removeKeychainCredentials{
    NSURL *url = [NSURL URLWithString:RootURL];
    [self removeCredentialsForHost:[url host] port:[[url port] intValue] protocol:[url scheme]  realm:API_REALM];
    
    
    //[self removeAuthenticationCredentialsFromSessionStore:<#(NSDictionary *)#>
}
-(void)clearSessionCredentials{
    [[self class] removeAuthenticationCredentialsFromSessionStore:self.requestCredentials];
}
+(BOOL)isLoggedIn{
    return [self password] != nil;
}

+ (NSString *)username {
    
    NSURLCredential *authenticationCredentials = [self authenticationCredentials];
    if (authenticationCredentials)
        return [authenticationCredentials user];
    else
        return nil;
}

+(NSString*)password{
    NSURLCredential *authenticationCredentials = [self authenticationCredentials];
    if (authenticationCredentials)
        return [authenticationCredentials password];
    else
        return nil;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    TSHTTPRequest *newRequest = [super copyWithZone:zone];
    newRequest.progressLoadingText = self.progressLoadingText;
    newRequest.useSVProgressHUD = self.useSVProgressHUD;
    newRequest.progressSuccessText = self.progressSuccessText;
    newRequest.progressFailureText = self.progressFailureText;
    newRequest.responseStringAsErrorMessage = self.responseStringAsErrorMessage;
    newRequest.showAlertMessages = self.showAlertMessages;
    newRequest.notSuccessBlock = self.notSuccessBlock;
    newRequest.progressMaskType = self.progressMaskType;

	return newRequest;
}
@end
