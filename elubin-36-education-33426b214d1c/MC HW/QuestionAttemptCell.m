//
//  QuestionAttemptCell.m
//  MC HW
//
//  Created by Eric Lubin on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QuestionAttemptCell.h"
#import "UIImage+extensions.h"
@implementation QuestionAttemptCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.textLabel.font= [UIFont boldSystemFontOfSize:20];
        self.badge.radius = 9.0f;
        // Initialization code
    }
    return self;
}


-(void)setObject:(NSDictionary*)question{

    NSString *choiceString = [question valueForKey:@"choice"];
    BOOL overTimeLimit = [[question valueForKey:@"is_over_time_limit"] boolValue];
    BOOL correct = [[question valueForKey:@"correct"] boolValue];
    NSString *timeKey = @"time_spent";
    if(self.enforceTimeLimit && overTimeLimit){
        choiceString = @"";
        correct = NO;
        timeKey = nil;
        //self.imageView.image = ;
    }
    
    
    if(overTimeLimit){
        self.imageView.image = [UIImage imageNamed:@"78-stopwatch"];
        self.imageView.highlightedImage = [UIImage imageNamed:@"78-stopwatch-white"];
    }
    else{
        self.imageView.image = nil;
    }
    
    if(correct){
        self.badgeColor = [UIColor colorWithHue:0.33 saturation:1.0 brightness:0.80 alpha:1.0];
        self.badgeString = choiceString;
    }
    else {
        if([choiceString isEqualToString:@""]){
            self.badgeColor = [UIColor blackColor];
            self.badgeString = [NSString stringWithFormat:@"[%@]",[question valueForKey:@"correct_answer"]];
        }
        else{
            self.badgeColor = [UIColor colorWithHue:0.000 saturation:1.0 brightness:0.80 alpha:1.0];
            self.badgeString = [choiceString stringByAppendingFormat:@" [%@]",[question valueForKey:@"correct_answer"]];
        }
        
    }
    NSInteger timeSpent = (int)roundf([[question valueForKey:timeKey] floatValue]);
    NSInteger seconds = timeSpent %60;
    NSInteger minutes = (timeSpent-seconds)/60;
    
    NSMutableString *timeString = [NSMutableString string];
    
    if(minutes != 0){
        [timeString appendFormat:@"%d minute%@",minutes,minutes != 1 ? @"s" : @""];
    }
    if(seconds != 0){//want to create a string no matter what
    if([timeString length] >0)
        [timeString appendString:@" "];
    [timeString appendFormat:@"%d second%@",seconds,seconds != 1 ? @"s": @""];
    }
    
    self.timestampLabel.text = timeString;
    self.textLabel.text = [NSString stringWithFormat:@"#%d",[[question valueForKey:@"_order"] intValue]+1];
    
}


@end
