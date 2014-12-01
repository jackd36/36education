//
//  MCControl.m
//  MC HW
//
//  Created by Eric Lubin on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCControl.h"
@interface MCControl ()
@property (nonatomic) NSInteger numberOfChoices;
@end

@implementation MCControl
@synthesize correctAnswer,numberOfChoices;

-(id)initWithNumberOfChoices:(NSInteger)numChoices offset:(BOOL)offset{
    numberOfChoices = numChoices;
    NSArray *defaultArray= nil;
    if(!offset)
        defaultArray = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E", nil];
    else
        defaultArray = [NSArray arrayWithObjects:@"F",@"G",@"H",@"J",@"K", nil];
    NSArray *choicesArray = [[defaultArray subarrayWithRange:NSMakeRange(0, numChoices)] arrayByAddingObject:@" "];
    
    if (self = [super initWithSectionTitles:choicesArray]){
        
        self.tintColor = [UIColor lightGrayColor];
        //[UIColor colorWithRed:79.0/255.0 green:145.0/255.0 blue:205.0/255.0 alpha:1.0];
        self.selectedIndex = numChoices;
    }
    return self;
}
-(void)moveThumbToChoice:(MultipleChoice)choice animate:(BOOL)animate{
    NSInteger index = (numberOfChoices+choice)%(numberOfChoices+1);
    [self moveThumbToIndex:index animate:animate];
}
-(MultipleChoice)selectedChoice{
    return (self.selectedIndex+1)%(numberOfChoices+1);
}
//-(NSInteger)activelySelectedIndex{
//    
//}
//-(MultipleChoice)activelySelectedChoice{
//    
//    
//}
-(void)moveThumbToIndex:(NSUInteger)segmentIndex animate:(BOOL)animate{
    [super moveThumbToIndex:segmentIndex animate:animate];
    if(correctAnswer == Choice_None){
        [self unanswered];
    }
    else{
        MultipleChoice answer = (self.selectedIndex+1)%(numberOfChoices +1);
        if(answer == Choice_None)
            [self unanswered];
        else if(answer == correctAnswer)
            [self answeredCorrectly];
        else{
            [self answeredIncorrectly];
        }
    }
}
-(void)answeredCorrectly{
    self.thumb.tintColor = [UIColor greenColor];
}

-(void)answeredIncorrectly{
    self.thumb.tintColor = [UIColor redColor];
}
-(void)unanswered{
    self.thumb.tintColor =[[UIColor colorWithRed:79.0f/255.0f green:145.0f/255.0f blue:205.0f/255.0f alpha:1.0f] retain];
}

@end
