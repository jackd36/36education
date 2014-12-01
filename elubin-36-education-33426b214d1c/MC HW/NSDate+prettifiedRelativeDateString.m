//
//  NSDate+prettifiedRelativeDateString.m
//  MC HW
//
//  Created by Eric Lubin on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSDate+prettifiedRelativeDateString.h"

@implementation NSDate (prettifiedRelativeDateString)
+(NSDate*)today{
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    
    NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
    today = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:today]]; 
    return today;
}
-(NSString*)relativeDateStringTime:(BOOL)time{
    static NSDateFormatter *dateFormatter;
    if(dateFormatter == nil){
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    NSDate *today = [NSDate today];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    if([today timeIntervalSinceReferenceDate] > [self timeIntervalSinceReferenceDate]){//overdue
        if([today timeIntervalSinceReferenceDate] - 86400.0 <= [self timeIntervalSinceReferenceDate])
            return @"Yesterday";
        else {
            
            NSDateComponents *components = [calendar components:NSYearCalendarUnit fromDate:today];
            
            components.month = 1;
            components.day = 1;
            
            NSDate *yearEnd = [calendar dateFromComponents:components];
            if([self timeIntervalSinceReferenceDate] >= [yearEnd timeIntervalSinceReferenceDate]){
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                    dateFormatter.dateFormat = @"EEEE M/d";
                else
                    dateFormatter.dateFormat = @"eee. M/d";
                return [dateFormatter stringFromDate:self];
            }
            else{ 
                
                dateFormatter.dateFormat = @"M/d/yy";
                
                return [dateFormatter stringFromDate:self];
            }
        }
    }
    else{
        if([today timeIntervalSinceReferenceDate] + 86400.0 > [self timeIntervalSinceReferenceDate]){
            if(!time)
                return @"Today";
            else {
                dateFormatter.dateFormat = @"h:mm a";
                return [dateFormatter stringFromDate:self];
            }
        }
        
        else if([today timeIntervalSinceReferenceDate] + 86400.0*2 > [self timeIntervalSinceReferenceDate])
            return @"Tomorrow";
        else {
            if([today timeIntervalSinceReferenceDate] + 86400.0*7 > [self timeIntervalSinceReferenceDate]){
                dateFormatter.dateFormat = @"EEEE";
                return [dateFormatter stringFromDate:self];
            }
            else{ 
                NSUInteger preservedComponents = (NSYearCalendarUnit);
                NSDateComponents *components = [calendar components:preservedComponents fromDate:today];
                components.year+=1;
                components.month = 1;
                components.day = 1;
                NSDate *yearStart = [calendar dateFromComponents:components];
                
                if([yearStart timeIntervalSinceReferenceDate] > [self timeIntervalSinceReferenceDate]){//this year
                    dateFormatter.dateFormat = @"MMMM d";
                    return [dateFormatter stringFromDate:self];
                }
                else {
                    dateFormatter.dateStyle = NSDateFormatterShortStyle;
                    dateFormatter.dateFormat = nil;
                    return [dateFormatter stringFromDate:self];
                }
            }
        }
    }
    return nil;
}
-(NSString*)relativeDateString{
    return [self relativeDateStringTime:NO];
}

-(NSString*)dueDateString{
    NSDate *today = [NSDate date];
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    df.dateFormat = @"EEE, MMM d, yyyy";
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    
    NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
    today = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:today]];
    
    
	if([self timeIntervalSinceReferenceDate] < [today timeIntervalSinceReferenceDate] +86400){
		if([self timeIntervalSinceReferenceDate] >= [today timeIntervalSinceReferenceDate])
			return [NSString stringWithFormat:@"Due today, %@",[df stringFromDate:self]];
		NSInteger days = [today timeIntervalSinceDate:self]/86400+1;
		
		NSString *string = [NSString stringWithFormat:@"Overdue %d day%@",days,days != 1 ? @"s":@""];
		return string;
	}
	NSInteger daysUntilDue = [self timeIntervalSinceDate:today]/86400;
	NSString *beginning;
	if(daysUntilDue == 1)
		beginning = @"Due tomorrow, ";
	else if(daysUntilDue <= 14 && daysUntilDue > 0)
		beginning = [NSString stringWithFormat:@"Due in %d days, ",daysUntilDue];
	else
		beginning = @"Due ";
	
	return [beginning stringByAppendingString:[df stringFromDate:self]];
}
@end
