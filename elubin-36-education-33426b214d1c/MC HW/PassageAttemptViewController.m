//
//  PassageAttemptViewController.m
//  MC HW
//
//  Created by Eric Lubin on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PassageAttemptViewController.h"
#import "TwoByTwoCellView.h"
#import "QuestionAttemptCell.h"
@interface PassageAttemptViewController ()

@end

@implementation PassageAttemptViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.subListingCellClassName = @"QuestionAttemptCell";
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
-(BOOL)allowsSubListingEditing{
    return YES;
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



#pragma mark - Table view data source


-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0)
        return [super tableView:tableView titleForHeaderInSection:section];
    else {
        return @"Answers";
    }
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
        NSString *defaultKey = nil;
        NSString *timeSpentKey = @"time_spent";
        
        if([self.objectInfo valueForKey:@"date_completed"] == [NSNull null]){
            cell.topLeftTitle.text = @"# answered";
            defaultKey = @"number_answered";
        }
        else{
            cell.topLeftTitle.text = @"raw score";
            defaultKey = @"raw_score";
        }
        
        if(![self enforceTimeLimitInUI]){
            defaultKey = [defaultKey stringByAppendingString:@"_no_time_limit"];
            timeSpentKey = [defaultKey stringByAppendingString:@"_no_time_limit"];
        }
        
        cell.topRightTitle.text = @"time spent";
        
        
        
        cell.topLeftValue.text     = [NSString stringWithFormat:@"%@ of %@",[self.objectInfo valueForKey:defaultKey],[self.objectInfo valueForKey:@"num_questions"]];
        
        NSInteger timeSpent = roundf([[self.objectInfo valueForKey:timeSpentKey] floatValue]);
        NSInteger seconds = timeSpent %60;
        NSInteger minutes = (timeSpent-seconds)/60;
        cell.topRightValue.text    = [NSString stringWithFormat:@"%d:%02d",minutes,seconds];
        
        cell.numRows = 1;
        //cell.backgroundView = nil;
        //cell.backgroundColor = [UIColor whiteColor];
        return cell;
        
    }
    else{
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 70;
	}
	
	return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}
#pragma mark - Table view delegate


@end
