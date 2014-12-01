//
//  NSMutableDictionary+MC_Grades.h
//  MC HW
//
//  Created by Eric Lubin on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum{
    IndicatorTypeUnassigned,
    IndicatorTypeAssignedAndUnread,
    IndicatorTypeAssignedAndIncomplete,
    IndicatorTypeComplete
} AssignmentIndicatorType;

@interface NSMutableDictionary (MC_Grades)
-(void)addInt:(int)value forContentType:(NSNumber*)ct andObjectID:(NSNumber*)objectID;
@end
