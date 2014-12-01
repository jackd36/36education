//
//  MCStyledControl.m
//  MC HW
//
//  Created by Eric Lubin on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCStyledControl.h"
#import "MCCell.h"
@interface MCStyledControl()
@property (nonatomic) NSInteger numberOfChoices;
@property (nonatomic,retain) NSArray *choiceCells;
@property (nonatomic) UIInterfaceOrientation orientation;
@end

@implementation MCStyledControl
@synthesize correctAnswer,numberOfChoices,choiceCells,selectedIndex;

-(CGFloat)sizeOfCell{
    return [[self class] sizeofCellForNumChoices:numberOfChoices orientation:self.orientation];
}
-(CGFloat)padding{
    return [[self class] paddingForNumChoices:numberOfChoices orientation:self.orientation];
}
+(CGFloat)paddingForNumChoices:(NSInteger)numChoices orientation:(UIInterfaceOrientation)orientation {
    CGFloat multiplier = 3.0/4.0;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if(UIInterfaceOrientationIsPortrait(orientation)){
            if(numChoices == 5)
                multiplier = .3;
            else
                multiplier = .34;
        }
        else{
            if(numChoices == 4){
                multiplier = .5;
            }
            else
                multiplier = .5;
        }
    }
    return [self sizeofCellForNumChoices:numChoices orientation:orientation]*multiplier;
}

+(CGFloat)sizeofCellForNumChoices:(NSInteger)numChoices orientation:(UIInterfaceOrientation)orientation{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return 50.0f;
    else{
        if(UIInterfaceOrientationIsPortrait(orientation)){
            if(numChoices == 4){
                return 35.0f;
            }
            else{
                return 30.0f;
            }
        }
        else{
            if(numChoices == 4){
                return 50.0f;
            }
            else{
                return 45.0f;
            }
            
        }
    }
}


+(CGFloat)totalWidthForNumChoices:(NSInteger)numChoices orientation:(UIInterfaceOrientation)orientation{
    return [self sizeofCellForNumChoices:numChoices orientation:orientation]*(numChoices+1)+[self paddingForNumChoices:numChoices orientation:orientation]*numChoices+2;
}
-(CGFloat)totalWidth{
    return [[self class] totalWidthForNumChoices:numberOfChoices orientation:self.orientation];
}
-(id)initWithNumberOfChoices:(NSInteger)numChoices offset:(BOOL)offset orientation:(UIInterfaceOrientation)orientation{
    self.orientation = orientation;
    numberOfChoices = numChoices;
    NSArray *defaultArray= nil;
    if(!offset)
        defaultArray = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E", nil];
    else
        defaultArray = [NSArray arrayWithObjects:@"F",@"G",@"H",@"J",@"K", nil];
    
    NSArray *choicesArray = [[defaultArray subarrayWithRange:NSMakeRange(0, numChoices)] arrayByAddingObject:@" "];
    CGFloat width = [self sizeOfCell];
    CGSize choiceSize = CGSizeMake(width, width);
    
    
    CGFloat padding = [self padding];
    if (self = [self initWithFrame:CGRectMake(0, 0, [self totalWidth], choiceSize.height+2)]){
        CGFloat offset = 1.0f;
        NSMutableArray *cells =[NSMutableArray arrayWithCapacity:numberOfChoices+1];
        for(int x =0;x<=numberOfChoices;x++){
            
            MCCell *cell = [[MCCell alloc] initWithFrame:CGRectMake(offset, 1, choiceSize.width, choiceSize.height)];
            cell.cellString = [choicesArray objectAtIndex:x];
            
            [self addSubview:cell];
            [cells addObject:cell];
            offset+=padding+choiceSize.width;
            [cell release];
        }
        self.choiceCells = cells;
        
        //[UIColor colorWithRed:79.0/255.0 green:145.0/255.0 blue:205.0/255.0 alpha:1.0];
        self.selectedIndex = numChoices;
    }
    return self;
}

-(void)setCorrectAnswer:(MultipleChoice)ca{
    correctAnswer = ca;
    [choiceCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        MCCell *cell = obj;
        MultipleChoice activeChoice = (idx+1)%(numberOfChoices +1);
        if(correctAnswer == Choice_None || activeChoice == Choice_None)
            cell.showsRightWrong = NO;
        else{
            cell.showsRightWrong = YES;
            cell.correct = activeChoice == correctAnswer;
        }
        
    }];
}

- (void)dealloc
{
    [choiceCells release];
    [super dealloc];
}


-(void)setSelectedIndex:(NSInteger)index{
    selectedIndex = index;
    [choiceCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        MCCell *cell = obj;
        if(index == idx){
            cell.answered = YES;
            
        }
        else
            cell.answered = NO;
        
        
    }];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    [choiceCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        MCCell *cell = obj;
        CGRect rect = cell.frame;
        CGFloat padding = [self padding];
        rect.origin.x-=padding/2;
        rect.size.width+=padding;
        if(CGRectContainsPoint(rect, location)){
            if(selectedIndex != idx){
                self.selectedIndex = idx;
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
            
            *stop = YES;
        }
        
    }];
    
}
-(void)moveThumbToChoice:(MultipleChoice)choice animate:(BOOL)animate{
    NSInteger index = (numberOfChoices+choice)%(numberOfChoices+1);
    self.selectedIndex = index;
}
-(MultipleChoice)selectedChoice{
    return (selectedIndex+1)%(numberOfChoices+1);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)setUserInteractionEnabled:(BOOL)userInteractionEnabled{
    [super setUserInteractionEnabled:userInteractionEnabled];
    [choiceCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        MCCell *cell = obj;
        if(selectedIndex == idx){
            cell.userInteractionEnabled = userInteractionEnabled;
            *stop = YES;
        }
    }];
}

@end
