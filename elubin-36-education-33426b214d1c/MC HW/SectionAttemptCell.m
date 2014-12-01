//
//  SectionAttemptCell.m
//  MC HW
//
//  Created by Eric Lubin on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SectionAttemptCell.h"

@implementation SectionAttemptCell

-(void)setObject:(NSDictionary*)section{
    self.textLabel.text = [section valueForKey:@"section_type"];
    
    
    
    NSString *defaultKey = nil;
    if([section valueForKey:@"date_completed"] == [NSNull null]){
        defaultKey = @"number_answered";
    }
    else{
        defaultKey = @"raw_score";
    }
    NSString *scaledScoreKey = @"scaled_score";
    NSString *timeSpentKey = @"time_spent";
    if(!self.enforceTimeLimit){
        scaledScoreKey = [scaledScoreKey stringByAppendingString:@"_no_time_limit"];
        defaultKey = [defaultKey stringByAppendingString:@"_no_time_limit"];
        timeSpentKey = [timeSpentKey stringByAppendingString:@"_no_time_limit"];
    }
    
    
    
    self.badgeString = [[section valueForKey:scaledScoreKey] description];
    self.badgeString2 = [NSString stringWithFormat:@"%@/%@",[section valueForKey:defaultKey],[section valueForKey:@"num_questions"]];
    
    NSInteger timeSpent = (int)roundf([[section valueForKey:timeSpentKey] floatValue]);
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
    
    float pctCorrect = [[section valueForKey:defaultKey] floatValue]/[[section valueForKey:@"num_questions"] floatValue];
    self.badgeColor = [UIColor colorWithHue:0.3333*pctCorrect saturation:1.0 brightness:0.80 alpha:1.0];
}


@end
