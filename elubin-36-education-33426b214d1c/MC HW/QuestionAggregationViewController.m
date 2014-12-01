//
//  QuestionAggregationViewController.m
//  MC HW
//
//  Created by Eric Lubin on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QuestionAggregationViewController.h"
//#import "QuestionAttemptCell.h"
#import "TwoByTwoCellView.h"
#import "TDBadgedCell.h"
#import "AggregationAttemptTableViewCell.h"
#import "QuestionTagViewController.h"
#import "AddQuestionTagViewController.h"

@interface QuestionAggregationViewController ()

@end

@implementation QuestionAggregationViewController
-(NSString*)headerTitleForSecondSection{
    return @"Tags";
}


-(void)cell:(TagsTableCell *)tableViewCell tagSelectedAtIndex:(NSInteger)index title:(NSString *)title{
    NSNumber *tagID = [[[self.objectInfo valueForKey:@"tags"] objectAtIndex:index] valueForKey:@"tag_id"];
    NSNumber *tagContentType = [self.objectInfo valueForKey:@"tag_content_type"];
    
    NSDictionary *objectInfo = [NSDictionary dictionaryWithObjectsAndKeys:tagID,@"object_id",tagContentType,@"object_content_type",title,@"description",nil];
    
    QuestionTagViewController *vc = [[QuestionTagViewController alloc] init];
    vc.objectInfo = objectInfo;
    vc.studentsIDs = self.studentsIDs;
    vc.attemptReferrerID = [[self.objectInfo valueForKey:@"object_id"] integerValue];
    
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}


-(BOOL)isSecondSectionVisible{
    //NSLog(@"%@",self.objectInfo);
    return YES;//[[self.objectInfo valueForKey:@"tags"] count] > 0;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.keyForObjectInfoDidLoad = @"choice_distribution";
        self.numberOfRowsInSectionOne = 2;
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableViewDataSource) name:QuestionDidModifyTags object:nil];
    
    
	// Do any additional setup after loading the view.
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // Release any retained subviews of the main view.
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section ==2){
        NSDictionary *attempt = [[self arrayOfActiveSegment] objectAtIndex:indexPath.row];
        
        if([self onAttemptsTab]){
            
            
 
            static NSString *CellIdentifierSectionInfo = @"SectionInfo";
            AggregationAttemptTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierSectionInfo];
            if(cell == nil){
                
                cell = [[[AggregationAttemptTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierSectionInfo] autorelease];
                cell.accessoryType  = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
            }
            [cell setAttempt:attempt studentBased:[self.studentsIDs count]>1];
            cell.pctCorrect = [[attempt valueForKey:@"correct"] floatValue];
            NSString *choice = [attempt valueForKey:@"choice"];
            if((id)choice != [NSNull null] && [choice length] == 0)
                choice = @"None";
            cell.badgeString =choice;
            //[cell setObject:attempt isAttempt:NO];
            
            return cell;
        }
        // Configure the cell...
        return nil;
        
    }
    else if(indexPath.section == 1){
        NSArray *tags = [[self.objectInfo valueForKey:@"tags"] valueForKey:@"tag__description"];
        TagsTableCell *cell = [[[TagsTableCell alloc] initWithTags:tags] autorelease];
        cell.delegate = self;
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        return cell;
    }
    
    else{ //indexPath.section == 0
        if(indexPath.row == 0){
            TwoByTwoCellView *cell = [[[TwoByTwoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
            cell.topLeftTitle.text = @"% correct";
            cell.topRightTitle.text = @"# of attempts";
            
    //        id compScore = [self.objectInfo valueForKey:@"composite_score_avg"];
    //        if(compScore == [NSNull null])
    //            compScore = nil;
    //        cell.topLeftValue.text     = [NSString stringWithFormat:@"%.1f",[compScore floatValue]];
    //      
            id pctCorrect = [self.objectInfo valueForKey:@"pct_correct"];
            if(pctCorrect == [NSNull null])
                pctCorrect = nil;
            if(pctCorrect == nil)
                cell.topLeftValue.text = @"00.00";
            else
                cell.topLeftValue.text = [NSString stringWithFormat:@"%2.2f",[pctCorrect floatValue]*100];
            
            NSNumber *numAttempts = [self.objectInfo valueForKey:@"num_attempts"];
            if(numAttempts == nil)
                cell.topRightValue.text = nil;
            else
                cell.topRightValue.text    = [NSString stringWithFormat:@"%d",[[self.objectInfo valueForKey:@"num_attempts"] integerValue]];
            
            cell.numRows = 1;
            return cell;
        }
        else if(indexPath.row == 1){
            TDBadgedCell *cell = [[[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.badge.radius = 9.0f;
            cell.badgeColor = [UIColor colorWithHue:0.33 saturation:1.0 brightness:0.8 alpha:1.0];
            cell.textLabel.text = @"Correct Answer";
            NSString *choice = [self.objectInfo valueForKey:@"correct_answer"];
            
           
            cell.badgeString = choice;
            return cell;
        }
        else{
            UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
            
//            CPTXYGraph *graph = [[CPTXYGraph alloc] initWithFrame:cell.contentView.bounds];
//            CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 0,300, [self tableView:tableView heightForRowAtIndexPath:indexPath])];
//            hostingView.hostedGraph = graph;
//            
//            NSLog(@"%@",self.objectInfo);
//            CPTPieChart *pieChart = [[CPTPieChart alloc] init];
//            pieChart.pieRadius = 60.0f;
//            pieChart.startAngle = M_PI_4;
//            pieChart.sliceDirection = CPTPieDirectionCounterClockwise;
//            pieChart.dataSource = self;
//            [graph addPlot:pieChart];
//            //graph.title = @"Choice distribution";
////            CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
////            [graph applyTheme:theme];
//            graph.axisSet = nil;
            //CPTLegend *legend = [CPTLegend legendWithGraph:graph];
            
            //[cell.contentView addSubview:pieChart];
            //CPTGraph *graph = [[CPTGraph alloc] initWithFrame:cell.contentView.bounds];
            //[cell.contentView addSubview:graph];
            
            //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            //cell.textLabel.text = @"Distribution graph...";
            //[cell.contentView addSubview:hostingView];
            //hostingView.center = CGPointMake(cell.contentView.bounds.size.width/2,cell.contentView.bounds.size.height/2);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
}
//-(NSString*)legendTitleForPieChart:(CPTPieChart*)pieChart recordIndex:(NSUInteger)index{
//    return [[[self.objectInfo valueForKey:@"choice_distribution"] objectAtIndex:index] valueForKey:@"choice"];
//}
//-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot{
//    return [[self.objectInfo valueForKey:@"choice_distribution"] count];
//}
//-(NSNumber*)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index{
//    
//    return [NSNumber numberWithFloat:[[[[self.objectInfo valueForKey:@"choice_distribution"] objectAtIndex:index] valueForKey:@"frequency"] floatValue]/[[self.objectInfo valueForKey:@"num_attempts"] floatValue]];
//}
//-(CPTLayer*)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index{
//    static CPTMutableTextStyle *whiteText = nil;
//    if(!whiteText){
//        whiteText = [[CPTMutableTextStyle alloc] init];
//        whiteText.color = [CPTColor blackColor];
//        
//    }
//    CPTLayer *layer = [[CPTLayer alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//    CPTTextLayer *newLayer = nil;
//    newLayer = [[CPTTextLayer alloc] initWithText:[[[self.objectInfo valueForKey:@"choice_distribution"] objectAtIndex:index] valueForKey:@"choice"] style:whiteText];
//    [layer addSublayer:newLayer];
//    [layer release];
//    return [newLayer autorelease];
//}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        if(indexPath.row == 1){
            return 35.0f;
        }
        else if(indexPath.row == 2){
            return 170.0f;
        }
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1){
        [self tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }

}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    // Navigation logic may go here. Create and push another view controller.
    //no editing may be done here anymore
//    if(indexPath.section == 1){
//        TagsTableCell *cell = (TagsTableCell*)[tableView cellForRowAtIndexPath:indexPath];
//        if(![cell hasTags])//no editing
//            return;
//        
//        AddQuestionTagViewController *vc = [[AddQuestionTagViewController alloc] init];
//        UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:vc];
//        //controller.navigationBar.tintColor = kDefaultToolbarColor;
//        vc.questionIndex = [[self.objectInfo valueForKey:@"index"] integerValue];
//        vc.questionOffset = [[self.objectInfo valueForKey:@"_order"] integerValue]-vc.questionIndex;
//        vc.waitForRequestCompletion = YES;
//        vc.contentType = [[self.objectInfo valueForKey:@"parent_content_type"] integerValue];
//        vc.objectID = [[self.objectInfo valueForKey:@"parent_id"] integerValue];
//        vc.sectionName = [self.objectInfo valueForKey:@"section_type"];
//        controller.modalPresentationStyle =vc.modalPresentationStyle;
//        [self presentModalViewController:controller animated:YES];
//        [vc release];
//        [controller release];
//        
//    }
}
-(CGFloat)heightForRowInSecondSection{
    
    return [TagsTableCell heightForTags:[[self.objectInfo valueForKey:@"tags"] valueForKey:@"tag__description"] forCellWidth:self.view.bounds.size.width];
}
@end
