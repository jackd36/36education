//
//  AggregationAttemptTableViewCell.m
//  MC HW
//
//  Created by Eric Lubin on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AggregationAttemptTableViewCell.h"
#import "NSDate+prettifiedRelativeDateString.h"
@interface AggregationAttemptTableViewCell()

@end
@implementation AggregationAttemptTableViewCell
@synthesize pctCorrect;
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    UITableViewCellStyle style2 = 0;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        style2 = UITableViewCellStyleValue1;
    else
        style2 = UITableViewCellStyleSubtitle;
    if(self = [super initWithStyle:style2 reuseIdentifier:reuseIdentifier]){
        pctCorrect = MAXFLOAT;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    return self;
}

-(void)setAttempt:(NSDictionary*)dictionary studentBased:(BOOL)student{
    NSString *dateString = [[NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"date_completed"] integerValue]] relativeDateStringTime:YES];
    if(student){
        self.textLabel.text = [dictionary valueForKey:@"student"];
        self.detailTextLabel.text =dateString;
    }
    else{
        self.textLabel.text = dateString;
    }
}
-(void)layoutSubviews{
    if(pctCorrect != MAXFLOAT)
        self.badgeColor = [UIColor colorWithHue:0.3333*pctCorrect saturation:1.0 brightness:0.80 alpha:1.0];
    [super layoutSubviews];
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
