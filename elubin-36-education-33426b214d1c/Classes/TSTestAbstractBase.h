//
//  TSTestAbstractBase.h
//  MC HW
//
//  Created by Eric Lubin on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSTestTakingModel.h"
@interface TSTestAbstractBase : NSObject <TSTestTakingModel>
@property (nonatomic,copy) NSString *sectionName;
@property (nonatomic,strong) NSArray *questions;
@property (nonatomic) NSInteger numChoices;
@property (nonatomic,copy) NSString *testID;
@property (nonatomic) NSInteger assignmentID;
@property (nonatomic, getter = isTimed) BOOL timedTest;
@property (nonatomic) NSInteger contentType;
@property (nonatomic) NSTimeInterval unassignedTime;
@property (nonatomic) NSTimeInterval totalTimeSpentThusFar;
@property (nonatomic,strong) NSArray *correct_answers;
@property (nonatomic) NSInteger objectID;
@property (nonatomic,retain) NSDictionary *testInfo;


-(NSInteger)questionNumberForIndex:(NSInteger)i;

-(void)setNumberOfQuestions:(NSInteger)num;
-(NSIndexPath*)indexPathOfQuestionNumber:(NSInteger)number;
-(void)setAnswers:(NSArray*)answers;
//-(void)setAnswers:(NSArray*)answers afterTimeLimit:(NSArray*)timeLimit;
-(BOOL)isTutorBased;
-(NSInteger)initialNumbering;
@end
