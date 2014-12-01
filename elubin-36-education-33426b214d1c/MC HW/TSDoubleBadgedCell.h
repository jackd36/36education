//
//  TSDoubleBadgedCell.h
//  MC HW
//
//  Created by Eric Lubin on 3/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDBadgedCell.h"
@interface TSDoubleBadgedCell : TDBadgedCell
@property (readonly, retain)    TDBadgeView *badge2;
@property (nonatomic, retain)   NSString *badgeString2;
@end
