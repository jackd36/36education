//
//  SectionAttemptTableView.m
//  MC HW
//
//  Created by Eric Lubin on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SectionAttemptTableView.h"
@implementation SectionAttemptTableView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)setAttempt:(NSDictionary *)attempt{
    
//    TDBadgeView *badgeScaled =  [[[TDBadgeView alloc] initWithFrame:CGRectZero] autorelease];
//    [badgeScaled setNeedsDisplay];
//    badgeScaled.badgeString = [[attempt valueForKey:@"scaled_score"] description];
//    self.accessoryView =badgeScaled;
    
    self.pctCorrect = ([[attempt valueForKey:@"scaled_score"] floatValue]-1)/35.0f;
    self.badgeString2 = [NSString stringWithFormat:@"%@/%@",[attempt valueForKey:@"raw_score"],[attempt valueForKey:@"num_questions"]];
    self.badgeString = [[attempt valueForKey:@"scaled_score"] description];
    if(self.sectionIsFactoredOut){
        self.detailTextLabel.text = nil;
        self.textLabel.text = [attempt valueForKey:@"testID"];
    }
    else {
        self.textLabel.text = [attempt valueForKey:@"section_type"];
        self.detailTextLabel.text = [attempt valueForKey:@"testID"];
    }
    [super setAttempt:attempt];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
