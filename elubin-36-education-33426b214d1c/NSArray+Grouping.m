//
//  NSArray+Grouping.m
//  MC HW
//
//  Created by Eric Lubin on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSArray+Grouping.h"
NSString * const NSARRAY_GROUPING_OBJECTS_STRING = @"objects";
NSString * const NSARRAY_GROUPING_SECTION_TITLE_STRING = @"group_name";

@implementation NSArray (Grouping)


-(NSMutableArray*)groupUsingComplexBlock:(NSDictionary* (^)(id object)) block{
    //the block is now a dictionary of keys/values!
    NSMutableArray *groupedArray = nil;
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray *keyOrder = [[NSMutableArray alloc] init];
    if(dictionary != nil){
        for (id item in self){
            //id key = block(item);//old
            NSDictionary *key_dict = block(item);
            if (key_dict != nil){
                NSMutableArray *array = [dictionary objectForKey:key_dict];
                if(array == nil){
                    
                    //[keyOrder addObject:<#(id)#>]
                    [keyOrder addObject:key_dict];
                    array = [NSMutableArray arrayWithObject:item];
                    if(array != nil){
                        [dictionary setObject:array forKey:key_dict];
                    }
                }
                else{
                    [array addObject:item];
                }
                
            }
        }
        groupedArray = [[NSMutableArray alloc] initWithCapacity:[keyOrder count]];
        for(NSDictionary *key_dict in keyOrder){
            
            NSMutableDictionary *new_dict = [[NSMutableDictionary alloc] initWithCapacity:[key_dict count]+1];
            [new_dict setObject:[dictionary objectForKey:key_dict] forKey:NSARRAY_GROUPING_OBJECTS_STRING];
            [new_dict addEntriesFromDictionary:key_dict];
            
            [groupedArray addObject:new_dict];
            [new_dict release];
        }

        
        
    }
    [dictionary release];
    [keyOrder release];
    return [groupedArray autorelease];
    
}
-(NSMutableArray*)groupUsingBlock:(NSString* (^)(id old_object)) block{
    return [self groupUsingComplexBlock:^NSDictionary *(id object){
        
        return [NSDictionary dictionaryWithObject:block(object) forKey:NSARRAY_GROUPING_SECTION_TITLE_STRING];
    }];
}


-(NSMutableArray*)groupUsingKey:(NSString*)key{
    return [self groupUsingBlock:^NSString *(id object) {
        return [object valueForKey:key];
    }];
}


-(NSMutableArray*)groupUsingKeys:(NSString *)key1, ...{
    //a variation on groupUsingKey where multiple keys are used to group instead;
    va_list args;
    va_start(args, key1);
    NSMutableArray *keys = [NSMutableArray array];
    for( NSString *arg = key1; arg != nil; arg = va_arg(args, NSString*))
    {
        [keys addObject:arg];
    }
    va_end(args);
        
        
    return [self groupUsingComplexBlock:^NSDictionary*(id object) {
        return [object dictionaryWithValuesForKeys:keys];
    }];
}

-(NSMutableArray*)ungroupArray{
    NSMutableArray *array = [NSMutableArray array];
    for(NSDictionary *dict in self){
        NSArray *subArray = [dict valueForKey:NSARRAY_GROUPING_OBJECTS_STRING];
        [array addObjectsFromArray:subArray];
    }
    return array;
}
-(NSMutableArray*)groupByTakingSubElementAtIndex:(NSInteger)index withKey:(NSString*)key titleReplacement:(NSString*)titleKey{
    NSMutableArray *outArray = [NSMutableArray arrayWithCapacity:[self count]];
    for(NSDictionary *dict in self){
        NSString *oldTitle = [dict valueForKey:titleKey];
        NSArray  *item = [dict valueForKey:key];
        if(index < [item count]){
            NSDictionary *replacement = [[item objectAtIndex:index] mutableCopy];
            [replacement setValue:oldTitle forKey:titleKey];
            [outArray addObject:replacement];
            [replacement release];
        }
    }
    return outArray;
}

@end
