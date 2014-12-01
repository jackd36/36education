//
//  NSNull+null.m
//  MC HW
//
//  Created by Eric Lubin on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSNull+null.h"

@implementation NSNull (null)
-(NSInteger)length{
    NSLog(@"This is where the crashing would have occured");
    return 0;
}
@end
