//
//  SectionTagViewController.m
//  MC HW
//
//  Created by Eric Lubin on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SectionTagViewController.h"
#import "AggregationAttemptTableViewCell.h"
#import "TwoByTwoCellView.h"
#import "SectionAttemptViewController.h"
#import "UIImage+extensions.h"
//#import "ScatterPlotViewController.h"
@interface SectionTagViewController ()

@end

@implementation SectionTagViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.numberOfRowsInGrid = 2;
        
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = [self.objectInfo valueForKey:@"section_type"];
    self.navigationItem.titleView = nil;
//    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"16-line-chart" withColor:[UIColor whiteColor]] style:UIBarButtonItemStyleBordered target:self action:@selector(showGraph)] autorelease];
//    
	// Do any additional setup after loading the view.
}

//-(void)showGraph{
//    //NSArray *dateCompleted = [[self valueForKey:@"attempts"] valueForKey:@"date_completed"];
//    ScatterPlotViewController *vc = [[ScatterPlotViewController alloc] initWithAttempts:[self valueForKey:@"attempts"] xKey:@"date_completed" yKey:@"scaled_score"];
//    //ScatterPlotViewController *vc = [[ScatterPlotViewController alloc] initWithXCoordinates:dateCompleted yCoordinates:[[self valueForKey:@"attempts"] valueForKey:@"scaled_score"]];
//    [self.navigationController pushViewController:vc animated:YES];
//    [vc release];
//}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
-(BOOL)isSecondSectionVisible{
    return NO;
}
-(void)updateTopRightButton{
    
}
-(BOOL)onAttemptsTab{
    return TRUE;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section ==2){
        NSDictionary *attempt = [[self arrayOfActiveSegment] objectAtIndex:indexPath.row];
        
        
        
        static NSString *CellIdentifierTest = @"Test";
        
        AggregationAttemptTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierTest];
        if (cell == nil) {
            cell = [[[AggregationAttemptTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifierTest] autorelease];
        }
        //cell.pctCorrect = ;
        [cell setAttempt:attempt studentBased:[self.studentsIDs count]>1];
        
        
        
        
        cell.badgeString = [[attempt valueForKey:@"scaled_score"] description];
        cell.badgeString2 = [NSString stringWithFormat:@"%@/%@",[attempt valueForKey:@"raw_score"],[attempt valueForKey:@"num_questions"]];
        
        cell.pctCorrect = [[attempt valueForKey:@"raw_score"] floatValue]/[[attempt valueForKey:@"num_questions"] floatValue];
        
        return cell;
    }
    else{ //indexPath.section == 0
        TwoByTwoCellView *cell = [[TwoByTwoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.topLeftTitle.text = @"average raw score";
        
        cell.topRightTitle.text = @"average scaled score";
        cell.bottomLeftTitle.text = @"average time spent";
        cell.bottomRightTitle.text = @"average time left";
        @try {
            ;
            NSInteger timeSpent = roundf([[self.objectInfo valueForKey:@"time_spent"] floatValue]);
            NSInteger seconds = timeSpent %60;
            NSInteger minutes = (timeSpent-seconds)/60;
            
            cell.bottomLeftValue.text = [NSString stringWithFormat:@"%d:%02d",minutes,seconds];
            timeSpent = [[self.objectInfo valueForKey:@"time_to_complete"] integerValue]*60-timeSpent;
            seconds = timeSpent %60;
            minutes = (timeSpent-seconds)/60;
            cell.bottomRightValue.text    = [NSString stringWithFormat:@"%d:%02d",minutes,seconds];
            id rawScoreAvg = [self.objectInfo valueForKey:@"raw_score_avg"];
            if(rawScoreAvg == [NSNull null])
                rawScoreAvg = nil;
            
            id scaledScoreAvg = [self.objectInfo valueForKey:@"scaled_score_avg"];
            if(scaledScoreAvg == [NSNull null])
                scaledScoreAvg = nil;
            cell.topLeftValue.text = [NSString stringWithFormat:@"%.1f",[rawScoreAvg floatValue]];
            cell.topRightValue.text = [NSString stringWithFormat:@"%.1f",[scaledScoreAvg floatValue]];
        }
        @catch (NSException *exception) {
            NSLog(@"Caught exception: %@",exception);
        }

        
        
        cell.numRows = self.numberOfRowsInGrid;
        return cell;
    }
    
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 2){
        return [NSString stringWithFormat:@"%d Attempts",[[self valueForKey:@"attempts"] count]];
    }
    else{
        return [super tableView:tableView titleForHeaderInSection:section];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 2 && [self onAttemptsTab]){
        NSDictionary *attempt =  [[self arrayOfActiveSegment] objectAtIndex:indexPath.row];

            
        if(self.attemptReferrerID == [[attempt valueForKey:@"attempt_id"] integerValue])
            [self.navigationController popViewControllerAnimated:YES];
        else {
            SectionAttemptViewController *vc = [[SectionAttemptViewController alloc] init];
            vc.objectInfo = attempt;
            vc.hideAggregationFeature = YES;
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        }
        
    }
}
@end
