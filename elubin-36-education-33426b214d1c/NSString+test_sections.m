//
//  NSString+test_sections.m
//  MC HW
//
//  Created by Eric Lubin on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+test_sections.h"

@implementation NSString (test_sections)
-(NSString*)abbreviatedTestSection{
    if([self isEqualToString:@"Reading"])
        return @"Rdng";
    else if ([self isEqualToString:@"Science"])
        return @"Sci";
    else if ([self isEqualToString:@"English"])
        return @"Eng";
    return self;
}
@end
