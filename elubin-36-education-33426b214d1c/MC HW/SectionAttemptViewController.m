//
//  SectionAttemptViewController.m
//  MC HW
//
//  Created by Eric Lubin on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SectionAttemptViewController.h"
#import "TwoByTwoCellView.h"
#import "QuestionAttemptCell.h"
#import "TSDoubleBadgedCell.h"
#import "PassageAttemptViewController.h"
#import "PassageAttemptCell.h"
@interface SectionAttemptViewController ()

@end

@implementation SectionAttemptViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.subListingCellClassName = @"PassageAttemptCell";
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
-(void)setObjectInfo:(NSDictionary *)objectInfo{
    [super setObjectInfo:objectInfo];
    
    if([self hasSingletonPassage])
        self.subListingCellClassName = @"QuestionAttemptCell";
    else
        self.subListingCellClassName = @"PassageAttemptCell";
}
-(BOOL)hasSingletonPassage{
    return [[self.objectInfo valueForKey:@"section_type"] isEqualToString:@"Math"];
}
-(BOOL)allowsSubListingEditing{
    return [self hasSingletonPassage];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0)
        return [super tableView:tableView titleForHeaderInSection:section];
    else {
        if([self hasSingletonPassage])
            return @"Answers";
        else
            return @"Passages";
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
        NSString *scaledScoreKey = @"scaled_score";
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
            scaledScoreKey = [scaledScoreKey stringByAppendingString:@"_no_time_limit"];
            timeSpentKey = [timeSpentKey stringByAppendingString:@"_no_time_limit"];
        }

        
        cell.topRightTitle.text = @"scaled score";
        cell.bottomLeftTitle.text = @"time spent";
        cell.bottomRightTitle.text = @"time allotted";
        
        
        cell.topLeftValue.text     = [NSString stringWithFormat:@"%@ of %@",[self.objectInfo valueForKey:defaultKey],[self.objectInfo valueForKey:@"num_questions"]];
        
        cell.topRightValue.text = [[self.objectInfo valueForKey:scaledScoreKey] description];
        
        
        
        NSInteger timeSpent = (int)roundf([[self.objectInfo valueForKey:timeSpentKey] floatValue]);
        NSInteger seconds = timeSpent %60;
        NSInteger minutes = (timeSpent-seconds)/60;
        
        
        cell.bottomLeftValue.text    = [NSString stringWithFormat:@"%d:%02d",minutes,seconds];
        
        
        NSInteger timeRemaining = [[self.objectInfo valueForKey:@"test_time"] integerValue];

        timeRemaining = timeRemaining;
        seconds = timeRemaining%60;
        minutes = (timeRemaining-seconds)/60;
//        if(timeRemaining < 0){
//            NSInteger totalTime = [[self.objectInfo valueForKey:@"test_time"] integerValue];
//            seconds = totalTime%60;
//            minutes = (totalTime-seconds)/60;
//            cell.bottomLeftValue.text = [NSString stringWithFormat:@"%d:%02d",minutes,seconds];
//        
//            cell.bottomRightValue.text = [NSString stringWithFormat:@"%d:%02d",0,0];
//        }
//        else{
        cell.bottomRightValue.text = [NSString stringWithFormat:@"%d:%02d",minutes,seconds];
        //}
        //cell.numRows = (1+[self assignmentWasTimed]);
        //cell.backgroundView = nil;
        //cell.backgroundColor = [UIColor whiteColor];
        return cell;
        
    }
    else{
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 70*(2/*+[self assignmentWasTimed]*/);
	}
	
	return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}
#pragma mark - Table view delegate



@end
