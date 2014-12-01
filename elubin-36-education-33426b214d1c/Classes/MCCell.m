//
//  MCCell.m
//  MC HW
//
//  Created by Eric Lubin on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCCell.h"
@interface MCCell()
@property (nonatomic,retain) UILabel *label;

@end
@implementation MCCell
@synthesize label,answered,correct,showsRightWrong;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = UITextAlignmentCenter;
        //label.font = [UIFont boldSystemFontOfSize:frame.size.height/2];
        //[self addSubview:label];
        //[label release];
        // Initialization code
    }
    return self;
}
-(NSString*)cellString{
    return label.text;
}
-(void)setCellString:(NSString *)cellString{
    label.text = cellString;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    
    
}
-(void)setAnswered:(BOOL)answr{
    if(answr != answered)
        [self setNeedsDisplay];
    answered = answr;
    
}
-(void)setCorrect:(BOOL)corr{
    if(corr != correct)
        [self setNeedsDisplay];
    correct = corr;
}

-(void)setShowsRightWrong:(BOOL)rightWrong{
    if(rightWrong != showsRightWrong && answered)
        [self setNeedsDisplay];
    showsRightWrong = rightWrong;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
	// And draw with a blue fill color
	
	// Draw them with a 2.0 stroke width so they are a bit more visible.
	CGContextSetLineWidth(context, 0.0);
	
    //	// Add an ellipse circumscribed in the given rect to the current path, then stroke it
    //	CGContextAddEllipseInRect(context, CGRectMake(30.0, 30.0, 60.0, 60.0));
    //	CGContextStrokePath(context);
    //	
    //	// Stroke ellipse convenience that is equivalent to AddEllipseInRect(); StrokePath();
    //	CGContextStrokeEllipseInRect(context, CGRectMake(30.0, 120.0, 60.0, 60.0));
    CGContextSetRGBFillColor(context, 1.0,1.0,1.0, 1.0);
    CGFloat diameter = MIN(rect.size.width,rect.size.height)-2;
	CGContextFillRect(context, CGRectMake(0, 0, diameter+2, diameter+2));
	// Fill rect convenience equivalent to AddEllipseInRect(); FillPath();
    
    if([self isAnswered]){
        self.label.font = [UIFont boldSystemFontOfSize:(diameter+4)/2.0];
        self.label.textColor = [UIColor whiteColor];
        if(!self.userInteractionEnabled){
            CGContextSetRGBFillColor(context,.25,.25,.3,1.0);
        }
        
        else if(![self doesShowRightWrong])
            CGContextSetRGBFillColor(context, .22, .56,.86, 1.0);
        else{
            if([self isCorrect]){
                CGContextSetRGBFillColor(context, 0, 1.0,0, 1.0);
            }
            else{
                CGContextSetRGBFillColor(context, 1.0, 0,0, 1.0);
            }
        }
    }
    else{
        self.label.font = [UIFont systemFontOfSize:diameter/2.0];
        self.label.textColor = [UIColor blackColor];
        CGContextSetRGBFillColor(context, .85, .85,.85, 1.0);
    }
    
    
	CGContextFillEllipseInRect(context, CGRectMake(1, 1, diameter, diameter));
    [label sizeToFit];
    label.center = CGPointMake(self.bounds.size.width,self.bounds.size.height);

    [label drawTextInRect:rect];
    // Drawing code
}

-(void)setUserInteractionEnabled:(BOOL)userInteractionEnabled{
    [super setUserInteractionEnabled:userInteractionEnabled];
    [self setNeedsDisplay];
}

@end
