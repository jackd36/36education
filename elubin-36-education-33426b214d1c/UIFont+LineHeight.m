//
//  UIFont+LineHeight.m
//  MC HW
//
//  Created by Eric Lubin on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIFont+LineHeight.h"

@implementation UIFont (LineHeight)
-(CGFloat)ttLineHeight{
    return self.ascender-self.descender+1;
}
@end
