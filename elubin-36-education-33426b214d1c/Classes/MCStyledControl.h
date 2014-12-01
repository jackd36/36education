//
//  MCStyledControl.h
//  MC HW
//
//  Created by Eric Lubin on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSQuestion.h"
@interface MCStyledControl : UIControl
@property (nonatomic) MultipleChoice correctAnswer;

-(id)initWithNumberOfChoices:(NSInteger)numChoices offset:(BOOL)offset orientation:(UIInterfaceOrientation)orientation;


-(void)moveThumbToChoice:(MultipleChoice)choice animate:(BOOL)animate;
-(MultipleChoice)selectedChoice;


-(CGFloat)sizeOfCell;
-(CGFloat)padding;
+(CGFloat)sizeofCellForNumChoices:(NSInteger)numChoices orientation:(UIInterfaceOrientation)orientation;
+(CGFloat)paddingForNumChoices:(NSInteger)numChoices orientation:(UIInterfaceOrientation)orientation;

+(CGFloat)totalWidthForNumChoices:(NSInteger)numChoices orientation:(UIInterfaceOrientation)orientation;
-(CGFloat)totalWidth;
@property (nonatomic) NSInteger selectedIndex;

@end
