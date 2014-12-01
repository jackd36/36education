//
//  SectionAggregationViewController.m
//  MC HW
//
//  Created by Eric Lubin on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SectionAggregationViewController.h"
#import "AggregationAttemptTableViewCell.h"
#import "TwoByTwoCellView.h"
#import "SectionAttemptViewController.h"
#import "UIViewController+AttemptLogic.h"
#import "PassageCell.h"
#import "QuestionCell.h"
#import "TagsTableCell.h"
@interface SectionAggregationViewController ()

@end

@implementation SectionAggregationViewController


-(id)init{
    if(self = [super init]){
        self.numberOfRowsInGrid = 2;
        self.keyForObjectInfoDidLoad = @"section_tag";
    }
    return self;
}
-(BOOL)isSecondSectionVisible{
    return NO;
}
-(BOOL)shouldContainPassages{
    return ![[self.objectInfo valueForKey:@"section_type"] isEqualToString:@"Math"];
}
-(NSString*)headerTitleForAggregates{
    if([self shouldContainPassages]){
        return @"Passages";
    }
    else {
        return @"Questions";
    }
}
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
            
            
            cell.badgeString = [[attempt valueForKey:@"scaled_score"] description];
            cell.badgeString2 = [NSString stringWithFormat:@"%@/%@",[attempt valueForKey:@"raw_score"],[attempt valueForKey:@"num_questions"]];
            
            cell.pctCorrect = [[attempt valueForKey:@"raw_score"] floatValue]/[[attempt valueForKey:@"num_questions"] floatValue];
            
            return cell;
        }
        else{
            
            if([self shouldContainPassages]){
                static NSString *CellIdentifierSectionInfo = @"SectionInfo";
                PassageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierSectionInfo];
                if(cell == nil){
                    cell = [[[PassageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierSectionInfo] autorelease];
                    
                }
                cell.object = attempt;
                
                return cell;
            }
            
            else{
                static NSString *CellIdentifierSectionInfo3 = @"SectionInfo3";
                QuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierSectionInfo3];
                if(cell == nil){
                    cell = [[[QuestionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierSectionInfo3] autorelease];
                    
                }
                cell.object = attempt;
                
                return cell;
            }

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
        cell.topLeftTitle.text = @"average raw score";
        
        cell.topRightTitle.text = @"# of questions";
        cell.bottomLeftTitle.text = @"average scaled score";
        cell.bottomRightTitle.text = @"# of attempts";
        
        id compScore = [self.objectInfo valueForKey:@"raw_score_avg"];
        if(compScore == [NSNull null])
            compScore = nil;
        cell.topLeftValue.text     = [NSString stringWithFormat:@"%.1f",[compScore floatValue]];
        cell.topRightValue.text = [[self.objectInfo valueForKey:@"num_questions"] description];
        id scaledScore =[self.objectInfo valueForKey:@"scaled_score_avg"];
        if(scaledScore == [NSNull null])
            scaledScore = nil;
        cell.bottomLeftValue.text = [NSString stringWithFormat:@"%.1f",[scaledScore floatValue]];
        cell.bottomRightValue.text    = [NSString stringWithFormat:@"%d",[[self.objectInfo valueForKey:@"num_attempts"] integerValue]];
        
        cell.numRows = 2;
        return cell;
    }
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    if(indexPath.section == 1){
//        ScoringGridWebViewController *vc = [[ScoringGridWebViewController alloc] initWithTestID:[[self.objectInfo valueForKey:@"object_id"] integerValue]];
//        vc.navigationItem.title = [self.objectInfo valueForKey:@"testID"];
//        [self.navigationController pushViewController:vc animated:YES];
//        [vc release];
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
                SectionAttemptViewController *vc = [[SectionAttemptViewController alloc] init];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}



-(CGFloat)heightForRowInSecondSection{
    if([self shouldContainPassages]){
        return [super heightForRowInSecondSection];
    }
    else
        return [TagsTableCell heightForTags:[[self.objectInfo valueForKey:@"tags"] valueForKey:@"tag__description"] forCellWidth:self.view.bounds.size.width];
}

@end
