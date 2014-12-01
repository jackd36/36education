//
//  TSTest.m
//  MC HW
//
//  Created by Eric Lubin on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSTest.h"
#import "TSSection.h"
@implementation TSTest
@synthesize testID,sections,assignmentID,contentType;
- (void)dealloc {
    [testID release];
    [sections release];
    [super dealloc];
}
-(NSDictionary*)dictionaryRepresentation{
    return [NSDictionary dictionaryWithObjectsAndKeys:self.testID,@"testID",[sections valueForKey:@"dictionaryRepresentation"],@"sections",[NSNumber numberWithInteger:contentType],@"content_type",nil];
}
-(BOOL)complete{
    NSInteger numComplete = 0;
    for(TSSection *section in sections){
        if(section.complete)
            numComplete++;
    }
    
    return numComplete == [sections count];
}
-(BOOL)started{
    NSInteger numComplete = 0;
    for(TSSection *section in sections){
        if(section.complete || section.started)
            numComplete++;
    }
    
    return numComplete > 0;
}
@end
