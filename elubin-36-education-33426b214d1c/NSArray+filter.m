//
//  NSArray+filter.m
//  MC HW
//
//  Created by Eric Lubin on 12/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSArray+filter.h"

@implementation NSArray (filter)
-(NSArray*)filterObjectsByKey:(NSString*)key{
    NSMutableSet *tempValues = [[NSMutableSet alloc] init];
    NSMutableArray *ret = [NSMutableArray array];
    
    for(id obj in self){
        if(![tempValues containsObject:[obj valueForKey:key]]){
            [tempValues addObject:[obj valueForKey:key]];
            [ret addObject:obj];
        }
    }
    [tempValues release];
    return ret;
    
}
@end
