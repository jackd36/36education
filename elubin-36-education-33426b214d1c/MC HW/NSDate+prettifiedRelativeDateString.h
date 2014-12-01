//
//  NSDate+prettifiedRelativeDateString.h
//  MC HW
//
//  Created by Eric Lubin on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (prettifiedRelativeDateString)
-(NSString*)relativeDateString;
-(NSString*)relativeDateStringTime:(BOOL)time;
-(NSString*)dueDateString;
+(NSDate*)today;
@end
