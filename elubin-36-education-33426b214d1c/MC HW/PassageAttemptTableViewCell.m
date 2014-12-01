//
//  PassageAttemptTableViewCell.m
//  MC HW
//
//  Created by Eric Lubin on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PassageAttemptTableViewCell.h"

@implementation PassageAttemptTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)setAttempt:(NSDictionary*)attempt{
    self.pctCorrect = [[attempt valueForKey:@"raw_score"] floatValue]/[[attempt valueForKey:@"num_questions"] floatValue];
    self.badgeString = [NSString stringWithFormat:@"%@/%@",[attempt valueForKey:@"raw_score"],[attempt valueForKey:@"num_questions"]];
    self.detailTextLabel.text = [attempt valueForKey:@"testID"];
    if(self.sectionIsFactoredOut){
        self.textLabel.text = [attempt valueForKey:@"passage"];
    }
    else
        self.textLabel.text = [NSString stringWithFormat:@"%@, %@",[attempt valueForKey:@"passage"],[attempt valueForKey:@"section_type"]];
    [super setAttempt:attempt];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
