//
//  PassageCell.m
//  MC HW
//
//  Created by Eric Lubin on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PassageCell.h"

@implementation PassageCell

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

-(void)setObject:(NSDictionary *)passage{
    self.textLabel.text = [passage valueForKey:@"passage"];
    
    float raw_score_avg = [[passage valueForKey:@"raw_score_avg"] floatValue];
    self.badgeString = [NSString stringWithFormat:@"%.1f/%@",raw_score_avg,[passage valueForKey:@"num_questions"]];
    
    float pctCorrect = [[passage valueForKey:@"raw_score_avg"] floatValue]/[[passage valueForKey:@"num_questions"] floatValue];
    self.badgeColor = [UIColor colorWithHue:0.3333*pctCorrect saturation:1.0 brightness:0.80 alpha:1.0];
}

@end
