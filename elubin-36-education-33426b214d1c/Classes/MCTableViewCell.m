//
//  MCTableViewCell.m
//  MC HW
//
//  Created by Eric Lubin on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCTableViewCell.h"
#import "UIImage+extensions.h"

@interface MCTableViewCell ()
@property (nonatomic) UIInterfaceOrientation orientation;

@end
@implementation MCTableViewCell
@synthesize multipleChoiceControl,questionNumber;
- (id)initWithNumberOfChoices:(NSInteger)numChoices offset:(BOOL)offset tutor:(BOOL)tutor orientation:(UIInterfaceOrientation)orientation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.orientation = orientation;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        MCStyledControl *sc = [[MCStyledControl alloc] initWithNumberOfChoices:numChoices offset:offset orientation:orientation];
       // float fontSize = 17.0f;
//        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
//            sc.height = 52;
//            sc.font = [UIFont systemFontOfSize:20];
//            sc.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 20);
//            sc.cornerRadius =7;
//            
//            fontSize = 23.0f;
//        }
       // sc.tintColor = [UIColor whiteColor];
        multipleChoiceControl = [sc retain];
        [self.contentView addSubview:sc];
        //;
        [sc release];
        
        
        self.backgroundView=[[[UIView alloc] initWithFrame:self.bounds] autorelease];
        UIButton *button= [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat fontSize = 17.0f;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            fontSize = 25.0f;
        button.titleLabel.font = [UIFont systemFontOfSize:fontSize];
        button.backgroundColor =[UIColor clearColor];
        [button setTitleColor:THIRTY_SIX_DEFAULT_BUBBLE_COLOR forState:UIControlStateNormal];
        //button.titleLabel.textColor = THIRTY_SIX_DEFAULT_BUBBLE_COLOR;
//        if(tutor){
//            button.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
//            [button setImage:[UIImage imageNamed:@"15-tags" withColor:THIRTY_SIX_DEFAULT_BUBBLE_COLOR] forState:UIControlStateNormal];
//            button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
//        }
        button.showsTouchWhenHighlighted = YES;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        //button.tintColor = 
        questionNumber = [button retain];
        //title.contentMode = UIViewContentModeCenter;
        //title.shadowOffset = CGSizeMake(1, 1);
        //title.shadowColor = [UIColor lightGrayColor];
        
        
        
        [self.contentView addSubview:button];
        
        
        
        
    }
    return self;
}
- (void)dealloc {
    [multipleChoiceControl release];
    [questionNumber release];
    
    [super dealloc];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)layoutSubviews{
    [super layoutSubviews];
    CGSize size = [[questionNumber titleForState:UIControlStateNormal] sizeWithFont:questionNumber.titleLabel.font];
    
    //if(multipleChoiceControl.correctAnswer == Choice_None){
        
        questionNumber.frame = CGRectMake(0, 0, size.width, size.height);
        questionNumber.userInteractionEnabled = NO;
    //}
//    else{
//        questionNumber.frame = CGRectMake(0,0,size.width+25,size.height);
//        
//        questionNumber.userInteractionEnabled = YES;
//    }
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && !IS_IOS_7){
        CGFloat totalWidth = questionNumber.frame.size.width+multipleChoiceControl.frame.size.width;
        //CGFloat rightMargin = 8.0f;x
        //CGFloat leftMargin = 8.0f;
        //CGFloat leftSubtractMargin = 6.0f;
        CGFloat rightMargin,spaceInBetweenRelativeToSides,leftMargin;
        
        rightMargin = 750/(multipleChoiceControl.frame.size.width-150)-4;
        spaceInBetweenRelativeToSides = 0.75f;
        leftMargin = (self.contentView.bounds.size.width-totalWidth-rightMargin)/(1+spaceInBetweenRelativeToSides);
        questionNumber.frame=CGRectMake(leftMargin,0,questionNumber.frame.size.width,questionNumber.frame.size.height);
        multipleChoiceControl.frame = CGRectMake(questionNumber.frame.origin.x+questionNumber.frame.size.width+spaceInBetweenRelativeToSides*leftMargin,0,multipleChoiceControl.frame.size.width,multipleChoiceControl.frame.size.height);
    }
    else{
        if(!IS_IOS_7 || UIInterfaceOrientationIsLandscape(self.orientation) || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            multipleChoiceControl.center = CGPointMake(self.contentView.bounds.size.width/2, 0);
        else {
            //right align multipleChoiceControl
            multipleChoiceControl.center = CGPointMake(self.contentView.bounds.size.width/2,0);
            multipleChoiceControl.frame = CGRectMake(self.contentView.bounds.size.width - multipleChoiceControl.frame.size.width - 10, multipleChoiceControl.frame.origin.y, multipleChoiceControl.frame.size.width, multipleChoiceControl.frame.size.height);
        }
        questionNumber.frame = CGRectMake(10,0,questionNumber.frame.size.width,questionNumber.frame.size.height);
    }
    
    
    questionNumber.center = CGPointMake(questionNumber.center.x,self.contentView.bounds.size.height/2);
    multipleChoiceControl.center = CGPointMake(multipleChoiceControl.center.x,self.contentView.bounds.size.height/2);
   
    //multipleChoiceControl.center = CGPointMake(self.contentView.bounds.size.width/2+15, self.contentView.bounds.size.height/2);
    
    
}

@end
