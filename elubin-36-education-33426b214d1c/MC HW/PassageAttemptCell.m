//
//  PassageAttemptCell.m
//  MC HW
//
//  Created by Eric Lubin on 3/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PassageAttemptCell.h"

@implementation PassageAttemptCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

-(void)setObject:(NSDictionary*)passage{
    
    self.textLabel.text = [passage valueForKey:@"passage"];
    
    
    //self.badgeColor = [UIColor blackColor];
    //self.badge2.badgeColor = [UIColor blackColor];
    
    
    
    NSString *defaultKey = nil;
    NSString *timeSpentKey = @"time_spent";
    if([passage valueForKey:@"date_completed"] == [NSNull null]){
        defaultKey = @"number_answered";
    }
    else{
        defaultKey = @"raw_score";
    }
    if(!self.enforceTimeLimit){
        defaultKey = [defaultKey stringByAppendingString:@"_no_time_limit"];
        timeSpentKey = [timeSpentKey stringByAppendingString:@"_no_time_limit"];
    }
    float pctCorrect = [[passage valueForKey:defaultKey] floatValue]/[[passage valueForKey:@"num_questions"] floatValue];
    self.badgeColor = [UIColor colorWithHue:0.3333*pctCorrect saturation:1.0 brightness:0.80 alpha:1.0];
    NSInteger timeSpent = (int)roundf([[passage valueForKey:timeSpentKey] floatValue]);
    NSInteger seconds = timeSpent %60;
    NSInteger minutes = (timeSpent-seconds)/60;
    
    NSMutableString *timeString = [NSMutableString string];
    
    if(minutes != 0){
        [timeString appendFormat:@"%d minute%@",minutes,minutes != 1 ? @"s" : @""];
    }
    if(seconds != 0){
        if([timeString length] >0)
            [timeString appendString:@" "];
        [timeString appendFormat:@"%d second%@",seconds,seconds != 1 ? @"s": @""];
    }
    
    self.timestampLabel.text = timeString;
    
    self.badgeString = [NSString stringWithFormat:@"%@/%@",[passage valueForKey:defaultKey],[passage valueForKey:@"num_questions"]];
    
}


@end
