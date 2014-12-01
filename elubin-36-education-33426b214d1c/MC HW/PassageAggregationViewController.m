//
//  PassageAggregationViewController.m
//  MC HW
//
//  Created by Eric Lubin on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PassageAggregationViewController.h"
#import "PassageAttemptViewController.h"
#import "AggregationAttemptTableViewCell.h"
#import "QuestionCell.h"
#import "TwoByTwoCellView.h"
#import "UIViewController+AttemptLogic.h"

#import "AddQuestionTagViewController.h"
#import "PassageTagViewController.h"

@interface PassageAggregationViewController ()

@end

@implementation PassageAggregationViewController

-(id)init{
    if(self = [super init]){
        self.keyForObjectInfoDidLoad = @"tags";
        

    }
    return self;
}

-(BOOL)isSecondSectionVisible{
    return YES;//[[self.objectInfo valueForKey:@"tags"] count] > 0;
}
-(NSString*)headerTitleForSecondSection{
    return @"Tags";
}
-(NSString*)headerTitleForAggregates{
    return @"Questions";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableViewDataSource) name:PassageDidModifyTags object:nil];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // Release any retained subviews of the main view.
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section ==2){
        NSDictionary *attempt = [[self arrayOfActiveSegment] objectAtIndex:indexPath.row];
        
        if([self onAttemptsTab]){
            
            static NSString *CellIdentifierTest = @"Test";
            
            AggregationAttemptTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierTest];
            if (cell == nil) {
                cell = [[[AggregationAttemptTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierTest] autorelease];
            }
            
            //cell.pctCorrect = ;
            [cell setAttempt:attempt studentBased:[self.studentsIDs count]>1];
            
            id num_questions = [attempt valueForKey:@"num_questions"];
            if(num_questions == [NSNull null])
                num_questions = nil;
            cell.badgeString = [NSString stringWithFormat:@"%@/%d",[attempt valueForKey:@"raw_score"],[num_questions intValue]];
            
            
            cell.pctCorrect = [[attempt valueForKey:@"raw_score"] floatValue]/[[attempt valueForKey:@"num_questions"] floatValue];
            
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
        // Configure the cell...
        
        
    }
    else if(indexPath.section == 1){
        NSArray *tags = [[self.objectInfo valueForKey:@"tags"] valueForKey:@"passagetag__description"];
        TagsTableCell *cell = [[[TagsTableCell alloc] initWithTags:tags] autorelease];
        cell.delegate=self;
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        return cell;
    }
    
    else{ //indexPath.section == 0
        TwoByTwoCellView *cell = [[[TwoByTwoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        cell.topLeftTitle.text = @"average raw score";
        
        cell.topRightTitle.text = @"# of attempts";
        
        id compScore = [self.objectInfo valueForKey:@"raw_score_avg"];
        if(compScore == [NSNull null])
            compScore = nil;
        id numQuestions = [self.objectInfo valueForKey:@"num_questions"];
        if(numQuestions == [NSNull null])
            numQuestions = nil;
        cell.topLeftValue.text     = [NSString stringWithFormat:@"%.1f of %d",[compScore floatValue],[numQuestions integerValue]];
        cell.topRightValue.text = [NSString stringWithFormat:@"%d",[[self.objectInfo valueForKey:@"num_attempts"] integerValue]];


        cell.numRows = 1;
        return cell;
    }
    
}
-(void)cell:(TagsTableCell *)tableViewCell tagSelectedAtIndex:(NSInteger)index title:(NSString *)title{
    NSNumber *tagID = [[[self.objectInfo valueForKey:@"tags"] objectAtIndex:index] valueForKey:@"passagetag_id"];
    NSNumber *tagContentType = [self.objectInfo valueForKey:@"passagetag_content_type"];
    
    NSDictionary *objectInfo = [NSDictionary dictionaryWithObjectsAndKeys:tagID,@"object_id",tagContentType,@"object_content_type",title,@"description",nil];
    
    PassageTagViewController *vc = [[PassageTagViewController alloc] init];
    vc.objectInfo = objectInfo;
    vc.studentsIDs = self.studentsIDs;
    vc.attemptReferrerID = [[self.objectInfo valueForKey:@"object_id"] integerValue];
    
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    if(indexPath.section == 1){
      
            [self tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
       
    }
    
    
    
    else if(indexPath.section ==2){
        NSDictionary *attempt =  [[self arrayOfActiveSegment] objectAtIndex:indexPath.row];
        if([self onAttemptsTab]){
            
            if(self.attemptReferrerID == [[attempt valueForKey:@"attempt_id"] integerValue])
                [self.navigationController popViewControllerAnimated:YES];
            else {
                PassageAttemptViewController *vc = [[PassageAttemptViewController alloc] init];
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
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1){
        AddQuestionTagViewController *vc = [[AddQuestionTagViewController alloc] init];
        UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:vc];
        //controller.navigationBar.tintColor = kDefaultToolbarColor;
        //vc.questionIndex = [[self.objectInfo valueForKey:@"_order"] integerValue];
        vc.waitForRequestCompletion = YES;
        //vc.contentType = [[self.objectInfo valueForKey:@"parent_content_type"] integerValue];
        vc.objectID = [[self.objectInfo valueForKey:@"object_id"] integerValue];
        vc.sectionName = [self.objectInfo valueForKey:@"section_type"];
        vc.descriptionOfContent = [self.objectInfo valueForKey:@"passage"];
        controller.modalPresentationStyle =vc.modalPresentationStyle;
        [self presentModalViewController:controller animated:YES];
        [vc release];
        [controller release];
    }
}
-(CGFloat)heightForRowInSecondSection{

    return [TagsTableCell heightForTags:[[self.objectInfo valueForKey:@"tags"] valueForKey:@"passagetag__description"] forCellWidth:self.view.bounds.size.width];
}

@end
