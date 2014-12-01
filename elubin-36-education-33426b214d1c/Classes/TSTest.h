//
//  TSTest.h
//  MC HW
//
//  Created by Eric Lubin on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSTest : NSObject
@property (nonatomic,copy) NSString *testID;
@property (nonatomic,strong) NSArray *sections; //ordered by numQuestions, descending, then name ascending
@property (nonatomic) NSInteger assignmentID;
@property (nonatomic) NSInteger contentType;

-(NSDictionary*)dictionaryRepresentation;
-(BOOL)complete;

-(BOOL)started;
@end
