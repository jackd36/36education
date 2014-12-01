//
//  TSTestAbstractBase.m
//  MC HW
//
//  Created by Eric Lubin on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSTestAbstractBase.h"
#import "TSQuestion.h"
@implementation TSTestAbstractBase
@synthesize sectionName,questions,numChoices,testID,assignmentID,contentType,unassignedTime,totalTimeSpentThusFar,correct_answers,objectID,timedTest,testInfo;

-(id)init{
    if(self = [super init]){
        timedTest = YES;
    }
    return self;
}
- (void)dealloc
{
    [testInfo release];
    [correct_answers release];
    [sectionName release];
    [questions release];
    [testID release];
    
    [super dealloc];
}
-(NSInteger)initialNumbering{
    return 0;
}
-(void)setNumberOfQuestions:(NSInteger)num{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:num];
    for(int x =0; x < num;x++){
        [array addObject:[[[TSQuestion alloc] init] autorelease]];
    }
    self.questions = array;
}
-(BOOL)isTutorBased{
    return correct_answers != nil;
}


//-(void)setAnswers:(NSArray*)answers afterTimeLimit:(NSArray*)timeLimit{
//    if ([answers count] != [questions count] || ([timeLimit count] != [questions count] && [timeLimit count] != 0)){
//        [NSException raise:@"Array Mismatch" format:@"Length of Test does not match either length of the answers array or length of timelimit arrays"];
//    }
//    [answers enumerateObjectsUsingBlock:^(NSNumber *object, NSUInteger idx, BOOL *stop){
//        TSQuestion *q = [questions objectAtIndex:idx];
//        q.choice = [object intValue];
//        NSNumber *afterTimeLimit = [timeLimit objectAtIndex:idx];
//        q.uploadedAfterTimeLimit = [afterTimeLimit boolValue];
//    }];
//
//}

-(void)setAnswers:(NSArray *)answers{
    if ([answers count] != [questions count]){
        [NSException raise:@"Array Mismatch" format:@"Length of Test does not match either length of the answers array or length of timelimit arrays"];
    }
    [answers enumerateObjectsUsingBlock:^(NSDictionary *object, NSUInteger idx, BOOL *stop){
        TSQuestion *q = [questions objectAtIndex:idx];
        
        q.choice = [[object objectForKey:@"choice"] intValue];
        
        q.uploadedAfterTimeLimit = [[object objectForKey:@"over_time_limit"] boolValue];
        q.questionNumber = [[object objectForKey:@"question_number"] integerValue];
        
        
    }];
}
-(NSInteger)questionNumberForIndex:(NSInteger)i{
    TSQuestion *question =[self.questions objectAtIndex:i];
    
    return question.questionNumber;
}
-(NSIndexPath*)indexPathOfQuestionObject:(TSQuestion*)question{
    NSInteger index = [questions indexOfObject:question];
   return [self indexPathOfQuestion:index];
}
-(NSIndexPath*)indexPathOfQuestionNumber:(NSInteger)number{
    __block TSQuestion *question = nil;
    [questions enumerateObjectsUsingBlock:^(TSQuestion *obj, NSUInteger idx, BOOL *stop) {
        if(obj.questionNumber == number){
            question = obj;
            *stop = YES;
        }
    }];
    return [self indexPathOfQuestionObject:question];
}

-(NSIndexPath*)indexPathOfQuestion:(NSInteger)questionIndex{
    return nil;
}

-(TSQuestion*)questionAtIndexPath:(NSIndexPath*)indexPath{
    return [self.questions objectAtIndex:[self questionIndexForIndexPath:indexPath]];
}
-(NSInteger)questionIndexForIndexPath:(NSIndexPath*)indexPath{
    return 0;
}
-(NSString*)titleForSection:(NSInteger)section{
    return nil;
}
-(NSInteger)numberOfSections{
    return 0;
}
-(NSInteger)numberOfRowsInSection:(NSInteger)section{
    return 0;
}
-(NSInteger)numberOfRows{
    return 0;
}
-(NSInteger)lengthOfTest{
    return 0;
}
-(NSDictionary*)dictionaryRepresentation{
    return nil;
}
-(NSInteger)unansweredQuestions{
    NSInteger unanswered = 0;
    for(TSQuestion *question in self.questions){
        if(question.choice == Choice_None)
            unanswered++;
    }
    return unanswered;
}
@end
