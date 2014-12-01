//
//  NSArray+Grouping.h
//  MC HW
//
//  Created by Eric Lubin on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
NSString extern * const NSARRAY_GROUPING_OBJECTS_STRING;
NSString extern * const NSARRAY_GROUPING_SECTION_TITLE_STRING;
@interface NSArray (Grouping)
-(NSMutableArray*)groupUsingBlock:(NSString* (^)(id object)) block;
-(NSMutableArray*)groupUsingKey:(NSString*)key;
-(NSMutableArray*)groupUsingKeys:(NSString*)key1,...NS_REQUIRES_NIL_TERMINATION;
-(NSMutableArray*)ungroupArray;
-(NSMutableArray*)groupByTakingSubElementAtIndex:(NSInteger)index withKey:(NSString*)key titleReplacement:(NSString*)titleKey;

@end
