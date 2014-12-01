//
//  ChangeAnswerViewController.h
//  MC HW
//
//  Created by Eric Lubin on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSQuestion.h"
NSString extern * const THIRTY_SIX_DID_MODIFY_ANSWER;

@interface ChangeAnswerViewController : UIViewController
@property (nonatomic) NSInteger attemptID;
@property (nonatomic) MultipleChoice previousChoice;
@property (nonatomic) MultipleChoice correctAnswer;
@property (nonatomic) NSInteger numberOfChoices;
@property (nonatomic) NSInteger questionIndex;
//@property (nonatomic,copy) NSString *questionString;
@property (nonatomic,copy) NSString *parentString;
-(id)initWithNumberOfChoices:(NSInteger)choices;
//@property (nonatomic) BOOL offset;
@end
