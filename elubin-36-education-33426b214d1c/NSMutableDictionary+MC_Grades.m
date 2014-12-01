//
//  NSMutableDictionary+MC_Grades.m
//  MC HW
//
//  Created by Eric Lubin on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSMutableDictionary+MC_Grades.h"

@implementation NSMutableDictionary (MC_Grades)
-(void)addInt:(int)value forContentType:(NSNumber*)ct andObjectID:(NSNumber*)objectID{
    
    NSMutableDictionary *ctDict = [self objectForKey:ct];
    if(ctDict == nil){
        ctDict = [NSMutableDictionary dictionary];
        [self setObject:ctDict forKey:ct];
    }
    
//    NSMutableDictionary *idDict = [ctDict objectForKey:objectID];
//    if(idDict == nil){
//        idDict = [NSMutableDictionary dictionary];
//        [ctDict setObject:idDict forKey:objectID];
//    }
    
    NSNumber *oldValue = [ctDict objectForKey:objectID];
    if(value > [oldValue intValue])
        [ctDict setObject:[NSNumber numberWithInt:value] forKey:objectID];
    
}
@end
