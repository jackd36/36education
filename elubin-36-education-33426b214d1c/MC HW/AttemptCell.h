//
//  AttemptCell.h
//  MC HW
//
//  Created by Eric Lubin on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AttemptCell <NSObject>
-(void)setObject:(NSDictionary*)passage;
@optional
-(void)setObject:(NSDictionary*)section isAttempt:(BOOL)isAttempt;
@end
