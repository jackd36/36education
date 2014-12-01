//
//  TagCapsuleControl.m
//  MC HW
//
//  Created by Eric Lubin on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TagCapsuleControl.h"
#define defaultFont [UIFont systemFontOfSize:15.0f]

static const CGFloat leftCap = 12,rightCap=17,topCap=0,bottomCap=0;
@implementation TagCapsuleControl


-(id)initWithTitle:(NSString*)title constrainedToWidth:(CGFloat)width{
    
    return [self initWithTitle:title constrainedToWidth:width lineBreakMode:NSLineBreakByTruncatingTail];
}

-(id)initWithTitle:(NSString*)title constrainedToWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)breakMode{
    
    CGRect frame;
    frame.size = [[self class] dimensionsForTitle:title constrainedToWidth:width lineBreakMode:breakMode];
    frame.origin = CGPointZero;
    if(self = [self initWithFrame:frame]){
        if((id)title == [NSNull null])
            title = @"This is feeding in NULL";
//        NSLog(@"size=%@,frame=%@",NSStringFromCGSize(sizeOfFont),NSStringFromCGRect(self.frame));
        UIEdgeInsets caps = UIEdgeInsetsMake(topCap, leftCap, bottomCap, rightCap);
        
        UIImage *bkgd = [[UIImage imageNamed:@"address_atom_disclosure"] resizableImageWithCapInsets:caps];
        [self setBackgroundImage:bkgd forState:UIControlStateNormal];
        self.titleLabel.font = defaultFont;
        self.titleLabel.textAlignment = UITextAlignmentCenter;
        //
        self.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self setTitle:title forState:UIControlStateNormal];
        //self.titleLabel.textColor = [UIColor blackColor];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        UIImage *bkgdSelected = [[UIImage imageNamed:@"address_atom_disclosure_selected"] resizableImageWithCapInsets:caps];
        [self setBackgroundImage:bkgdSelected forState:UIControlStateHighlighted];
        [self setBackgroundImage:bkgdSelected forState:UIControlStateSelected];
        
        
        
        
        //[title sizeWit
    }
    return self;
}
-(id)initWithTitle:(NSString*)title{
    return [self initWithTitle:title constrainedToWidth:0.0f];
}
-(NSString*)description{
    return [self titleForState:UIControlStateNormal];
}


-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat rightCap =12;
    self.titleLabel.frame = CGRectMake(0,0,self.frame.size.width-leftCap-rightCap-1,self.frame.size.height);
    self.titleLabel.center = CGPointMake(roundf((self.frame.size.width-rightCap)/2)-1,self.frame.size.height/2);
    
}

+(CGSize)dimensionsForTitle:(NSString*)title{
    return [self dimensionsForTitle:title constrainedToWidth:0.0f];
}
+(CGSize)dimensionsForTitle:(NSString *)title constrainedToWidth:(CGFloat)width{
    return [self dimensionsForTitle:title constrainedToWidth:width lineBreakMode:NSLineBreakByTruncatingTail];
}
+(CGSize)dimensionsForTitle:(NSString *)title constrainedToWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)breakMode{
    CGSize sizeOfFont;
    if((id)title == [NSNull null]){
        return CGSizeZero;
    }
    if(width == 0.0f)
        sizeOfFont = [title sizeWithFont:defaultFont];
    else
        sizeOfFont = [title sizeWithFont:defaultFont forWidth:width lineBreakMode:breakMode];
    
    return CGSizeMake(sizeOfFont.width+leftCap+rightCap, 25);
}
+(UIFont*)capsuleFont{
    return defaultFont;
}
@end
