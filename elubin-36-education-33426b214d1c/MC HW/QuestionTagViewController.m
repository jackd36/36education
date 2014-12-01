//
//  QuestionTagViewController.m
//  MC HW
//
//  Created by Eric Lubin on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QuestionTagViewController.h"
#import "TwoByTwoCellView.h"
#import "AggregationAttemptTableViewCell.h"
#import "QuestionCell.h"
#import "QuestionAggregationViewController.h"
#import "UIViewController+AttemptLogic.h"
@interface QuestionTagViewController ()

@end

@implementation QuestionTagViewController
-(id)init{
    if(self = [super init]){
        self.numberOfRowsInGrid = 1;
        self.keyForObjectInfoDidLoad = @"pct_correct";
    }
    return self;
}
-(BOOL)isSecondSectionVisible{
    return NO;
}

-(BOOL)onAttemptsTab{
    return NO;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Question Tag";//[self.objectInfo valueForKey:@"description"];
    self.navigationItem.titleView = nil;
	// Do any additional setup after loading the view.
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return [self.objectInfo valueForKey:@"description"];
    }
    else{
        return [super tableView:tableView titleForHeaderInSection:section];
    }
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section ==2){
        NSDictionary *attempt = [[self arrayOfActiveSegment] objectAtIndex:indexPath.row];
        


            static NSString *CellIdentifierSectionInfo3 = @"SectionInfo3";
            QuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierSectionInfo3];
            if(cell == nil){
                cell = [[[QuestionCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierSectionInfo3] autorelease];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            cell.object = attempt;
            if([[self.objectInfo valueForKey:@"section_type"] isEqualToString:@"Math"]){
                cell.textLabel.text = [NSString stringWithFormat:@"Question %d",[[attempt valueForKey:@"_order"] integerValue]+1];
            }
            else
                cell.textLabel.text = [NSString stringWithFormat:@"Q%d, %@",[[attempt valueForKey:@"_order"] integerValue]+1,[attempt valueForKey:@"passage"]];
            
            cell.detailTextLabel.text = [attempt valueForKey:@"testID"];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
            return cell;
            
            
        
        // Configure the cell...
        
        
    }

    
    else{ //indexPath.section == 0
        TwoByTwoCellView *cell = [[[TwoByTwoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        cell.topLeftTitle.text = @"average correct";
        
        cell.topRightTitle.text = @"# of attempts";
;
        
        id compScore = [self.objectInfo valueForKey:@"pct_correct"];
        if(compScore == [NSNull null])
            compScore = nil;
        cell.topLeftValue.text     = [NSString stringWithFormat:@"%.1f%%",[compScore floatValue]*100];
        
        

        cell.topRightValue.text = [[self.objectInfo valueForKey:@"num_attempts"] description];

        
        cell.numRows = self.numberOfRowsInGrid;
        return cell;
    }
    
}

-(NSString*)headerTitleForAggregates{
    return @"Questions";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section ==2){
        NSDictionary *attempt =  [[self arrayOfActiveSegment] objectAtIndex:indexPath.row];

        GenericAggregationViewController *vc = aggregationViewControllerForAttempt(attempt);
        vc.studentsIDs = self.studentsIDs;
        vc.tutorAided = self.tutorAided;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
        
    }
    
}


@end
