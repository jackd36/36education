//
//  TSDoubleBadgedCell.m
//  MC HW
//
//  Created by Eric Lubin on 3/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSDoubleBadgedCell.h"

@interface TDBadgedCell()
-(void)configureSelf;
@end

@implementation TSDoubleBadgedCell
@synthesize badge2=__badge2,badgeString2=__badgeString2;
- (void)dealloc
{
    [__badge2 release];
    [__badgeString2 release];
    [super dealloc];
}
-(void)configureSelf{
    [super configureSelf];
    __badge2 = [[TDBadgeView alloc] initWithFrame:CGRectZero];
    self.badge2.parent = self;
    [self.contentView addSubview:self.badge2];
    [self.badge2 setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	[super setHighlighted:highlighted animated:animated];
	[self.badge2 setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self.badge2 setNeedsDisplay];
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    if (editing) 
    {
        self.badge2.hidden = YES;
        [self.badge2 setNeedsDisplay];
        [self setNeedsDisplay];
    }
    else 
    {
        self.badge2.hidden = NO;
        [self.badge2 setNeedsDisplay];
        [self setNeedsDisplay];
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if(self.badgeString2)
	{
        self.badge2.hidden = self.editing;
        CGSize badgeSize = [self.badgeString2 sizeWithFont:[UIFont boldSystemFontOfSize: 11]];
		CGRect badgeframe = CGRectMake(0,
                                       self.badge.top,
                                       badgeSize.width + 13,
                                       18);
        
        [self.badge2 setFrame:badgeframe];
       
        
        
		[self.badge2 setBadgeString:self.badgeString2];
        self.badge2.right = self.badge.left-5;
        
        
        if(self.badge2.left <= self.textLabel.right){
            self.textLabel.width = self.badge2.left-10.0f-self.textLabel.left;
            
        }
        if(self.badge2.left <= self.detailTextLabel.right){
            self.detailTextLabel.right = self.badge2.left-10.0f;
        }
        
        self.badge2.showShadow = self.showShadow;
        if(self.badgeColorHighlighted)
			self.badge2.badgeColorHighlighted = self.badgeColorHighlighted;
		else 
			self.badge2.badgeColorHighlighted = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.000f];
        
        //set badge colours or impose defaults
		if(self.badgeColor)
			self.badge2.badgeColor = self.badgeColor;
		else
			self.badge2.badgeColor = [UIColor colorWithRed:0.530f green:0.600f blue:0.738f alpha:1.000f];
    }
    else{
        self.badge2.hidden = YES;
    }

}

@end
