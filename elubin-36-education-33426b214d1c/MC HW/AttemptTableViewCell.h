//
//  AttemptTableViewCell.h
//  MC HW
//
//  Created by Eric Lubin on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSDoubleBadgedCell.h"
@interface AttemptTableViewCell : TSDoubleBadgedCell{
     UILabel*      _timestampLabel;
}

@property (nonatomic) float pctCorrect;
@property (nonatomic, readonly, retain) UILabel*      timestampLabel;
@property (nonatomic) BOOL sectionIsFactoredOut;
@property (nonatomic) BOOL enforceTimeLimit;
-(void)setAttempt:(NSDictionary*)attempt;
@end
