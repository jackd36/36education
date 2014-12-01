//
//  TestAttemptViewController.m
//  MC HW
//
//  Created by Eric Lubin on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestAttemptViewController.h"
#import "TwoByTwoCellView.h"
#import "SectionAttemptCell.h"
#import "SectionAttemptViewController.h"
@interface TestAttemptViewController ()

@end

@implementation TestAttemptViewController
- (id)init
{
    self = [super init];
    if (self) {
        self.subListingCellClassName = @"SectionAttemptCell";
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0)
        return [super tableView:tableView titleForHeaderInSection:section];
    else{
        return @"Sections";
    }
}

-(BOOL)canShowErrors{
    return NO;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section == 0){
        static NSString *TwoByTwoCellIdentifier = @"TwoByTwoCell";
        
        TwoByTwoCellView *cell = 
		(TwoByTwoCellView *) [tableView dequeueReusableCellWithIdentifier:TwoByTwoCellIdentifier];
		
        if (cell == nil) {
            cell = [[[TwoByTwoCellView alloc] 
                     initWithStyle:UITableViewCellStyleDefault 
                     reuseIdentifier:TwoByTwoCellIdentifier] 
                    autorelease];
        }
        cell.topLeftTitle.text = @"composite score";
        cell.topRightTitle.text = @"time spent";
        
        NSString *compositeScoreKey = @"composite_score";
        NSString *timeSpentKey = @"time_spent";
        
        if(![self enforceTimeLimitInUI]){
            compositeScoreKey = [compositeScoreKey stringByAppendingString:@"_no_time_limit"];
            timeSpentKey = [timeSpentKey stringByAppendingString:@"_no_time_limit"];
        }
        cell.topLeftValue.text     = [[self.objectInfo valueForKey:compositeScoreKey] description];
        
        @try {
            NSInteger timeSpent = roundf([[self.objectInfo valueForKey:timeSpentKey] floatValue]);
            NSInteger seconds = timeSpent %60;
            NSInteger minutes = (timeSpent-seconds)/60;
            cell.topRightValue.text    = [NSString stringWithFormat:@"%d:%02d",minutes,seconds];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception); 
            cell.topRightValue.text    = @"0:00";
            
        }

        
        
        cell.numRows = 1;
        //cell.backgroundView = nil;
        //cell.backgroundColor = [UIColor whiteColor];
        return cell;
        
    }
    else{
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

#pragma mark - Table view delegate



@end
