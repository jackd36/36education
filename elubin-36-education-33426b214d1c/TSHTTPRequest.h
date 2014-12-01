//
//  TSHTTPRequest.h
//  MC HW
//
//  Created by Eric Lubin on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ASIFormDataRequest.h"
#import "SVProgressHUD.h"

NSString extern * const API_REALM;
@interface TSHTTPRequest : ASIFormDataRequest <NSCopying>// <UIAlertViewDelegate>

-(id)initWithPathComponent:(NSString*)pathComponent;
+(id)requestWithPathComponent:(NSString*)pathComponent;
+(void)logout;
+ (NSString *)username;
+ (NSString*)password;
+(NSString*)urlFromPathComponent:(NSString*)pathComponent;
+(void)removeKeychainCredentials;
-(void)clearSessionCredentials;
-(void)saveAuthenticationCredentials;
+(void)removeCachedItemWithPath:(NSString*)path;
-(BOOL)didLoadFromWeb;//slightly different than didUseCachedResponse, as will return True when receiving a 304
@property (nonatomic) BOOL useSVProgressHUD;
//@property (nonatomic,assign) UIViewController *requestContainer;
@property (nonatomic) SVProgressHUDMaskType progressMaskType;
@property (nonatomic,copy) ASIBasicBlock notSuccessBlock;//called when a status code >= 200 is not received
@property (nonatomic,copy) NSString *progressLoadingText;
@property (nonatomic,copy) NSString *progressSuccessText;
@property (nonatomic,copy) NSString *progressFailureText;
@property (nonatomic) BOOL responseStringAsErrorMessage;
@property (nonatomic) BOOL showAlertMessages;
+(BOOL)isLoggedIn;

@end
