//
//  TSQuestion.h
//  MC HW
//
//  Created by Eric Lubin on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum{
    Choice_None = 0,
    Choice_A = 1,
    Choice_B = 2,
    Choice_C = 3,
    Choice_D = 4,
    Choice_E = 5
} MultipleChoice;
@interface TSQuestion : NSObject
@property (nonatomic) MultipleChoice choice;
@property (nonatomic) NSTimeInterval timeSpent;
@property (nonatomic) BOOL uploadedAfterTimeLimit;
@property (nonatomic) NSInteger questionNumber;

-(NSDictionary*)dictionaryRepresentation;
@end
