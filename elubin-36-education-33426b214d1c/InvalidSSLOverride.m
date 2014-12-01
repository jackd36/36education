//
//  InvalidSSLOverride.m
//  MC HW
//
//  Created by Eric Lubin on 5/3/13.
//
//

#import "InvalidSSLOverride.h"

@interface InvalidSSLOverride()
@end

@implementation InvalidSSLOverride{
    BOOL shouldOverrideSSL;
    BOOL activeAlertViewPresent;
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    activeAlertViewPresent = NO;
    if(buttonIndex == 1){
        shouldOverrideSSL = YES;
    }
}







-(BOOL)shouldOverrideSSLFailure{
    return shouldOverrideSSL;
}

+(id)sharedSSLManager{
    static InvalidSSLOverride *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
         sharedInstance = [[InvalidSSLOverride alloc] init];
    });
    return sharedInstance;
}

- (void)startAlertWithRequest:(TSHTTPRequest*)request{
    @synchronized(self){
        if(!shouldOverrideSSL){
            if(!activeAlertViewPresent){
                activeAlertViewPresent = YES;
                ///SSL error
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Verify Server Identity" message:[NSString stringWithFormat:@"36 Education cannot verify the identity of  \"%@\". Would you like to continue anyway?",[request.url host]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
                [alertView show];
            }
            
        }
    }
}
@end
