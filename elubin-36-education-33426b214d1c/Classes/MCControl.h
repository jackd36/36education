//
//  MCControl.h
//  MC HW
//
//  Created by Eric Lubin on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVSegmentedControl.h"

#import "TSQuestion.h"
@interface MCControl : SVSegmentedControl
@property (nonatomic) MultipleChoice correctAnswer;

-(id)initWithNumberOfChoices:(NSInteger)numChoices offset:(BOOL)offset;


-(void)moveThumbToChoice:(MultipleChoice)choice animate:(BOOL)animate;
-(MultipleChoice)selectedChoice;
//-(NSInteger)activelySelectedIndex;
//-(MultipleChoice)activelySelectedChoice;
@end
