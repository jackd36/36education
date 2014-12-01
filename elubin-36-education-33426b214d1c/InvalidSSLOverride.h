//
//  InvalidSSLOverride.h
//  MC HW
//
//  Created by Eric Lubin on 5/3/13.
//
//

#import <Foundation/Foundation.h>

@interface InvalidSSLOverride : NSObject <UIAlertViewDelegate>

@property (nonatomic, readonly) BOOL shouldOverrideSSLFailure;



+ (id)sharedSSLManager;
- (void)startAlertWithRequest:(TSHTTPRequest*)request;
@end
