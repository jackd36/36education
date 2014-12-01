//
//  SectionCell.m
//  MC HW
//
//  Created by Eric Lubin on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SectionCell.h"

@implementation SectionCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        self.textLabel.font = [UIFont boldSystemFontOfSize:20];
//        self.badge.radius = 9.0f;
        // Initialization code
    }
    return self;
}
-(void)setObject:(NSDictionary *)section{
    self.textLabel.text = [section valueForKey:@"section_type"];
    self.badgeString = [NSString stringWithFormat:@"%0.1f",[[section valueForKey:@"scaled_score_avg"] floatValue]];
    
    
    
    self.badgeString2 = [NSString stringWithFormat:@"%0.1f/%@",[[section valueForKey:@"raw_score_avg"] floatValue],[section valueForKey:@"num_questions"]];
    
    float pctCorrect = [[section valueForKey:@"raw_score_avg"] floatValue]/[[section valueForKey:@"num_questions"] floatValue];
    self.badgeColor = [UIColor colorWithHue:0.3333*pctCorrect saturation:1.0 brightness:0.80 alpha:1.0];
}

@end
