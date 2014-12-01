//
//  TagCapsuleControl.h
//  MC HW
//
//  Created by Eric Lubin on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagCapsuleControl : UIButton
-(id)initWithTitle:(NSString*)title;
-(id)initWithTitle:(NSString*)title constrainedToWidth:(CGFloat)width;
-(id)initWithTitle:(NSString*)title constrainedToWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)breakMode;

+(CGSize)dimensionsForTitle:(NSString*)title;
+(CGSize)dimensionsForTitle:(NSString *)title constrainedToWidth:(CGFloat)width;
+(CGSize)dimensionsForTitle:(NSString *)title constrainedToWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)breakMode;

+(UIFont*)capsuleFont;
@end
