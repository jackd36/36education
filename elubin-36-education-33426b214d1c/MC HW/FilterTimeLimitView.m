//
//  FilterTimeLimitView.m
//  MC HW
//
//  Created by Eric Lubin on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FilterTimeLimitView.h"
@implementation FilterTimeLimitView
@synthesize title,onOff;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        onOff = [[UISwitch alloc] initWithFrame:CGRectZero];
        onOff.onTintColor = kDefaultToolbarColor;
        //self.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor whiteColor]; // change this color
        label.adjustsFontSizeToFitWidth = YES;
        
        title = label;
        label.autoresizingMask =UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.autoresizingMask = label.autoresizingMask;
        [self addSubview:label];
        
        [self addSubview:onOff];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    float margin = 7;
    //onOff.right = margin;
    
    onOff.centerY = self.height/2;
    onOff.right = self.width;
    title.size = CGSizeMake(self.width-onOff.width-margin,self.height);
    
    
    title.center = CGPointMake(onOff.left/2,onOff.centerY);
    
    
}

@end
