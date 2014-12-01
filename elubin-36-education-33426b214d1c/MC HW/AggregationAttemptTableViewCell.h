//
//  AggregationAttemptTableViewCell.h
//  MC HW
//
//  Created by Eric Lubin on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSDoubleBadgedCell.h"

@interface AggregationAttemptTableViewCell : TSDoubleBadgedCell
-(void)setAttempt:(NSDictionary*)dictionary studentBased:(BOOL)student;

@property (nonatomic) CGFloat pctCorrect;
@end
