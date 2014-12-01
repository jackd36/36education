//
//  TSQuestion.m
//  MC HW
//
//  Created by Eric Lubin on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSQuestion.h"

@implementation TSQuestion
@synthesize choice,timeSpent,uploadedAfterTimeLimit,questionNumber=_questionNumber;
-(id)init{
    if(self = [super init]){
        choice = Choice_None;
        uploadedAfterTimeLimit = NO;
    }
    return self;
}
-(NSDictionary*)dictionaryRepresentation{
    return [self dictionaryWithValuesForKeys:[NSArray arrayWithObjects:@"choice",@"timeSpent",@"uploadedAfterTimeLimit", nil]];
}
-(NSString*)description{
    return [[self dictionaryRepresentation] description];
}
@end
