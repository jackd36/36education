//
//  TSTestTakingModel.h
//  MC HW
//
//  Created by Eric Lubin on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSQuestion.h"
@protocol TSTestTakingModel <NSObject>
-(TSQuestion*)questionAtIndexPath:(NSIndexPath*)indexPath;
-(NSInteger)questionIndexForIndexPath:(NSIndexPath*)indexPath;
-(NSString*)titleForSection:(NSInteger)section;
-(NSInteger)numberOfSections;
-(NSInteger)numberOfRowsInSection:(NSInteger)section;
-(NSInteger)numberOfRows;
-(NSIndexPath*)indexPathOfQuestion:(NSInteger)questionIndex;
-(NSIndexPath*)indexPathOfQuestionObject:(TSQuestion*)question;
-(NSInteger)lengthOfTest; ///in minutes
-(NSDictionary*)dictionaryRepresentation;
-(NSInteger)unansweredQuestions;
@end
