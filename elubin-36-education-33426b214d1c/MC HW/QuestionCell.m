//
//  QuestionCell.m
//  MC HW
//
//  Created by Eric Lubin on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QuestionCell.h"

@implementation QuestionCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.textLabel.font = [UIFont boldSystemFontOfSize:20];
        self.badge.radius = 9.0f;
        // Initialization code
    }
    return self;
}

-(void)setObject:(NSDictionary*)question{

    self.badgeColor = [UIColor blackColor];
    
    self.badgeString = [NSString stringWithFormat:@"[%@]",[question valueForKey:@"correct_answer"]];
    
    self.textLabel.text = [NSString stringWithFormat:@"#%d",[[question valueForKey:@"_order"] intValue]+1];
}

@end
