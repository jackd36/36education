//
//  ErrorInfoViewController.m
//  MC HW
//
//  Created by Eric Lubin on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ErrorInfoViewController.h"
#import "NSArray+Grouping.h"
#import "TDBadgedCell.h"
#import "FilterTimeLimitView.h"
#import "SpecificTagErrorViewController.h"
@interface ErrorInfoViewController ()
@property (nonatomic,strong) NSDictionary *errorInfo;
@property (nonatomic,weak) UISwitch *enforceTimeLimitSwitch;
@end


@implementation ErrorInfoViewController
@synthesize objectInfo = objectInfo,enforceTimeLimit=_enforceTimeLimit,enforceTimeLimitSwitch=_enforceTimeLimitSwitch;

- (id)init
{
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        self.contentSizeForViewInPopover = CGSizeMake(320,360);
    }
    return self;
}


-(NSArray*)activeErrorInfo{
    if([self enforceTimeLimitInUI])
        return [self.errorInfo valueForKey:@"errors"];
    else{
        return [self.errorInfo valueForKey:@"errors_no_time_limit"];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Error Analysis";
    FilterTimeLimitView *view = [[FilterTimeLimitView alloc] initWithFrame:CGRectMake(0, 0, MIN(self.view.bounds.size.width-26,400), 44)];
    view.title.text = @"Enforce time limit";
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:view];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    view.onOff.on = self.enforceTimeLimit;
    _enforceTimeLimitSwitch = view.onOff;
    
    
    [_enforceTimeLimitSwitch addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
    self.toolbarItems = [NSArray arrayWithObjects:flexibleSpace,item,flexibleSpace,nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if(self.errorInfo == nil)
        [self loadDataUsingCache:YES];
}
-(void)valueChanged{
    self.enforceTimeLimit = _enforceTimeLimitSwitch.isOn;
    [self.tableView reloadData];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(BOOL)completeAttempt{
    return [objectInfo valueForKey:@"date_completed"] != nil && [objectInfo valueForKey:@"date_completed"] != [NSNull null];
}
-(BOOL)isOverTimeLimit{
    return [[objectInfo valueForKey:@"is_over_time_limit"] boolValue] && [self completeAttempt];
}
-(BOOL)enforceTimeLimitInUI{
    return ![self isOverTimeLimit] || self.enforceTimeLimitSwitch.isOn;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return [self.activeErrorInfo count];
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section{
    id title = self.activeErrorInfo[section][NSARRAY_GROUPING_SECTION_TITLE_STRING];
    
    if(title == [NSNull null])
        return nil;
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
//    NSArray *sectionDictionaries = [[self.activeErrorInfo objectAtIndex:section] valueForKey:NSARRAY_GROUPING_OBJECTS_STRING];
//    int total = [sectionDictionaries count];
//    
//    for(NSDictionary *dict in sectionDictionaries){
//        total+=[[dict valueForKey:NSARRAY_GROUPING_OBJECTS_STRING] count];
//    }
//    return total;
    return [self.activeErrorInfo[section][NSARRAY_GROUPING_OBJECTS_STRING] count];
}
//-(NSDictionary*)dictionaryForIndexPath:(NSIndexPath*)path{
//    NSDictionary *section = [self.activeErrorInfo objectAtIndex:path.section];
//    int activeIndex = 0;
//    
//    for(NSDictionary *tag in [section valueForKey:NSARRAY_GROUPING_OBJECTS_STRING]){
//        if(activeIndex == path.row){
//            return tag;
//        }
//        for(NSDictionary *question in [tag valueForKey:NSARRAY_GROUPING_OBJECTS_STRING]){
//            if(activeIndex == path.row)
//                return question;
//            activeIndex++;
//        }
//        activeIndex++;
//    }
//    
//    return nil;
//}
//-(BOOL)dictionaryIsTagTitle:(NSDictionary*)dictionary{
//    return [dictionary valueForKey:NSARRAY_GROUPING_OBJECTS_STRING] != nil;
//}


-(NSDictionary*)dictionaryForIndexPath:(NSIndexPath*)indexPath{
    return self.activeErrorInfo[indexPath.section][NSARRAY_GROUPING_OBJECTS_STRING][indexPath.row];
}
-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict = [self dictionaryForIndexPath:indexPath];
    //if([self dictionaryIsTagTitle:dict]){
        id text = dict[@"error_info"];
        
        if(text != [NSNull null] && [text length] > 0){
            UIFont *cellFont = [UIFont systemFontOfSize:14.0f];
            
            CGFloat width = tableView.frame.size.width;
            if(self.tableView == tableView){
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                    width -= 45*2;
                else
                    width -= 10*2;
            }
            width-=50;
            
            CGSize constraintSize = CGSizeMake(width, MAXFLOAT);
            CGSize labelSize = [text sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
            CGFloat height = labelSize.height +30;
            if(height >=45)
                return height;
        }
        

    
    return 45.0f;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TDBadgedCell *cell = nil;
    NSDictionary *dict = [self dictionaryForIndexPath:indexPath];
    
        static NSString *CellIdentifier = @"TagTitle";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil){
            cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.imageView.image = [UIImage imageNamed:@"DetailViewTag"];
            cell.detailTextLabel.numberOfLines = 0;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.badgeColor = [UIColor blackColor];
            cell.badge.radius = 9.0f;
            
        }
        id description = dict[@"description"];
        if(description != [NSNull null])
            cell.textLabel.text = description;
        else
            cell.textLabel.text = nil;
        id eInfo = dict[@"error_info"];
        if(eInfo != [NSNull null])
            cell.detailTextLabel.text = eInfo;
        else
            cell.detailTextLabel.text = nil;
    
        cell.badgeString = [NSString stringWithFormat:@"%d",[dict[@"questions"] count]];
        
    //}
//    else{
//        static NSString *CellIdentifier2 = @"TagTitle3";
//        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
//        if(cell == nil){
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier2];
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            
//        }
//        cell.textLabel.text = [NSString stringWithFormat:@"Question %d",[[dict valueForKey:@"_order"] integerValue]+1];
//        cell.detailTextLabel.text = [dict valueForKey:@"passage"];
//        
//    }
    // Configure the cell...
    
    return cell;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if([self isOverTimeLimit]){
        [self.navigationController setToolbarHidden:YES animated:animated];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    if([self isOverTimeLimit]){
        [self.navigationController setToolbarHidden:NO animated:animated];
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
-(NSString*)uniqueURLPath{
    return [NSString stringWithFormat:@"attempt/%@/id/%@/errors/",objectInfo[@"content_type"],objectInfo[@"attempt_id"]];
}


-(void)loadDataUsingCache:(BOOL)cached{
    NSString *uniquePath = [self uniqueURLPath];
    __block TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:uniquePath];
    
//    if(cached){
//        request.cachePolicy = ASIAskServerIfModifiedCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy; //since the chances of an attempt actually changing is extremely slim and the call is somewhat expensive, dont reload unless the cache expires
//    }
//    else
//        request.cachePolicy = ASIDoNotReadFromCacheCachePolicy;
//    
    request.cachePolicy = ASIAskServerIfModifiedCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy;
    __weak TSHTTPRequest *weakRequest = request;
    
    request.useSVProgressHUD = YES;
    request.progressLoadingText = @"Aggregating errors...";
    request.completionBlock = ^{
        NSDictionary *dict = [weakRequest.responseData JSONValue];
        
        
        NSArray *errors = [dict[@"errors"] groupUsingKey:@"category_description"];
        
        
        NSArray *errors_no_time_limit = [dict[@"errors_no_time_limit"] groupUsingKey:@"category_description"];
        self.errorInfo = @{ @"errors" : errors,@"errors_no_time_limit":errors_no_time_limit };
 
        [self.tableView reloadData];
        [self doneLoadingTableViewDataWithSuccess:YES];
    };
    request.failedBlock = ^{
        [self doneLoadingTableViewDataWithSuccess:NO];
    };
    [request startAsynchronous];
}
//
//-(NSArray*)groupChildren:(NSArray*)array{
//    NSMutableArray *outputArray = [NSMutableArray arrayWithCapacity:[array count]];
//    for(NSDictionary *dict in array){
//        NSArray *groupedChild = [[dict valueForKey:NSARRAY_GROUPING_OBJECTS_STRING] groupUsingKeys:@"description",@"error_info", nil];
//        NSMutableArray *newGroupedChild = [[NSMutableArray alloc] initWithCapacity:[groupedChild count]];
//        for(NSDictionary *grandchild in groupedChild){
//            NSArray *greatGrandChildren = [grandchild valueForKey:NSARRAY_GROUPING_OBJECTS_STRING];
//            NSArray *arrayOfArraysOfQuestions = [greatGrandChildren valueForKey:@"questions"];
//            
//            NSMutableArray *array = [[NSMutableArray alloc] init];
//            for(NSArray *questionArray in arrayOfArraysOfQuestions){
//                [array addObjectsFromArray:questionArray];
//            }
//
//            [array sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"_order" ascending:YES]]];
//            NSDictionary *newGrandChild = [[NSDictionary alloc] initWithObjectsAndKeys:[grandchild valueForKey:@"error_info"],@"error_info",[grandchild valueForKey:@"description"],@"description",array,NSARRAY_GROUPING_OBJECTS_STRING, nil];
//            [newGroupedChild addObject:newGrandChild];
//        }
//        
//        
//        
//        NSDictionary *newDict = [[NSDictionary alloc] initWithObjectsAndKeys:newGroupedChild,NSARRAY_GROUPING_OBJECTS_STRING,[dict valueForKey:NSARRAY_GROUPING_SECTION_TITLE_STRING],NSARRAY_GROUPING_SECTION_TITLE_STRING, nil];
//        [outputArray addObject:newDict];
//    }
//    return outputArray;
//    
//}

    
-(void)reloadTableViewDataSource{
    [self loadDataUsingCache:NO];
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SpecificTagErrorViewController *vc = [[SpecificTagErrorViewController alloc] init];
    NSDictionary *dictionary = [self dictionaryForIndexPath:indexPath];
    vc.enforceTimeLimit = self.enforceTimeLimitInUI;
    vc.info = @{ @"category_description" : dictionary[@"category_description"],@"description":dictionary[@"description"],@"error_info":dictionary[@"error_info"],@"questions":[dictionary[@"questions"] groupUsingKey:@"passage"] };
    [self.navigationController pushViewController:vc animated:YES];
    //vc.questions = [self dictionaryForIndexPath:indexPath]
}

@end
