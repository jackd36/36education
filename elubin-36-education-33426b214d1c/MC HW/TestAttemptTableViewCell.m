//
//  TestAttemptTableViewCell.m
//  MC HW
//
//  Created by Eric Lubin on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestAttemptTableViewCell.h"

@implementation TestAttemptTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)setAttempt:(NSDictionary*)attempt{
    self.pctCorrect = ([[attempt valueForKey:@"composite_score"] floatValue]-1)/35.0f;
    self.badgeString = [NSString stringWithFormat:@"%.0f",ceilf([[attempt valueForKey:@"composite_score"] floatValue])] ;
    self.textLabel.text = [attempt valueForKey:@"testID"];
    self.detailTextLabel.text = nil;
    [super setAttempt:attempt];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
