//
//  TestAggregationViewController.m
//  MC HW
//
//  Created by Eric Lubin on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestAggregationViewController.h"
#import "TestAttemptTableViewCell.h"
#import "TestAttemptViewController.h"
#import "TwoByTwoCellView.h"
#import "ScoringGridWebViewController.h"
#import "AggregationAttemptTableViewCell.h"
#import "SectionCell.h"
#import "UIViewController+AttemptLogic.h"
@interface TestAggregationViewController ()

@end

@implementation TestAggregationViewController
//-(id)init{
//    if(self = [super init]){
//        
//    }
//    return self;
//}
-(BOOL)isSecondSectionVisible{
    return YES;
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
-(NSString*)headerTitleForAggregates{
    return @"Sections";
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if(indexPath.section ==2){
        NSDictionary *attempt = [[self arrayOfActiveSegment] objectAtIndex:indexPath.row];
        
        if([self onAttemptsTab]){
        
            static NSString *CellIdentifierTest = @"Test";
            
            AggregationAttemptTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierTest];
            if (cell == nil) {
                cell = [[[AggregationAttemptTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifierTest] autorelease];
            }
            //cell.pctCorrect = ;
            [cell setAttempt:attempt studentBased:[self.studentsIDs count]>1];
            
            
            cell.badgeString = [NSString stringWithFormat:@"%.0f",ceilf([[attempt valueForKey:@"composite_score"] floatValue])] ;
            cell.pctCorrect = (float)([[attempt valueForKey:@"composite_score"] integerValue]-1)/(float)35;
            
            return cell;
        }
        else{
            static NSString *CellIdentifierSectionInfo = @"SectionInfo";
            SectionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierSectionInfo];
            if(cell == nil){
                cell = [[[SectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierSectionInfo] autorelease];
                
            }
            cell.object = attempt;
            //[cell setObject:attempt isAttempt:NO];
            
            return cell;
        }
        // Configure the cell...
        
        
    }
    else if(indexPath.section == 1){
        UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"Scaled Score Conversion Table";
        return cell;
    }
    
    else{ //indexPath.section == 0
        TwoByTwoCellView *cell = [[[TwoByTwoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        cell.topLeftTitle.text = @"avg composite score";
        cell.topRightTitle.text = @"# of attempts";
        
        id compScore = [self.objectInfo valueForKey:@"composite_score_avg"];
        if(compScore == [NSNull null])
            compScore = nil;
        cell.topLeftValue.text     = [NSString stringWithFormat:@"%.1f",[compScore floatValue]];
        
        cell.topRightValue.text    = [NSString stringWithFormat:@"%d",[[self.objectInfo valueForKey:@"num_attempts"] integerValue]];
        
        cell.numRows = 1;
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    if(indexPath.section == 1){
        ScoringGridWebViewController *vc = [[ScoringGridWebViewController alloc] initWithTestID:[[self.objectInfo valueForKey:@"object_id"] integerValue]];
        vc.navigationItem.title = [self.objectInfo valueForKey:@"testID"];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
//        TTWebController *webController = [[TTWebController alloc] init];
//        [webController openURL:];
//        [self.navigationController pushViewController:webController animated:YES];
//        [webController release];
    }
    
    
    
    else if(indexPath.section ==2){
        
        NSDictionary *attempt =  [[self arrayOfActiveSegment] objectAtIndex:indexPath.row];
        if([self onAttemptsTab]){
            if(self.attemptReferrerID == [[attempt valueForKey:@"attempt_id"] integerValue])
                [self.navigationController popViewControllerAnimated:YES];
            else {
                TestAttemptViewController *vc = [[TestAttemptViewController alloc] init];
                vc.objectInfo = attempt;
                vc.hideAggregationFeature = YES;
                [self.navigationController pushViewController:vc animated:YES];
                [vc release];
            }
        }
        else{
            GenericAggregationViewController *vc = aggregationViewControllerForAttempt(attempt);
            vc.studentsIDs = self.studentsIDs;
            vc.tutorAided = self.tutorAided;
            [self.navigationController pushViewController:vc animated:YES];
            
        }
    }
    
}

@end
