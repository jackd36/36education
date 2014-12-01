//
//  SelectObjectViewController.m
//  MC HW
//
//  Created by Eric Lubin on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SelectObjectViewController.h"

#import "UIImage+extensions.h"
#import "NSMutableDictionary+MC_Grades.h"
#import "NSArray+Grouping.h"
#import "ChooseTutorViewController.h"
#import "CustomizeAssignmentViewController.h"



@interface SelectObjectViewController()
-(void)loadDataWithCache:(BOOL)cache;
-(NSIndexPath*)pathToAssignment;
-(void)getAssignmentDescription:(NSDictionary*)selectedObject;
-(void)traverseTreeForIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated scrollToIndex:(NSInteger)number;
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;
-(void)getAssignmentDescription:(NSDictionary*)selectedObject search:(BOOL)searched;
@property (nonatomic) BOOL loadedAttempts;
@property (nonatomic,strong) NSArray *filteredObjects;
@property (nonatomic) BOOL hideAccessoryButtons;
@property (nonatomic,strong) UISegmentedControl *segmentedControl;
@property (nonatomic,strong) NSArray *objects;
@property (nonatomic,strong) NSArray *sectionNames;

//@property (nonatomic,copy) NSString *objectType;
@property (nonatomic,copy) NSString *sectionTitle;


@property (nonatomic) NSInteger selectedObjectID;


@property (nonatomic,strong) NSArray *contentTypeIDs;
@property (nonatomic,strong) NSArray *objectTypes;

@property (nonatomic) BOOL isFromSelectedSectionTag;

@property (nonatomic) NSInteger sectionTypeContentType;


@property (nonatomic) NSInteger scrollToIndex;

-(NSInteger)depth;

@end

@implementation SelectObjectViewController
@synthesize objects,objectTypes,assignment,contentTypeIDs,sectionTitle,scrollToIndex,filteredObjects,segmentedControl,sectionNames,studentID,selectedObjectID,hashLookupTable,sectionTypeContentType,isFromSelectedSectionTag,loadedAttempts,studentBased,hideAccessoryButtons;
- (id)init
{
    self = [self initWithNibName:@"SelectObjectViewController" bundle:nil];
    if (self) {
        self.objectTypes = [NSArray arrayWithObject:@"Tests"];
        scrollToIndex = NSNotFound;
        self.modalPresentationStyle = UIModalPresentationFormSheet;
        selectedObjectID = -1;
        self.contentSizeForViewInPopover = CGSizeMake(320,400);
        // Custom initialization
    }
    return self;
}
-(id)initWithPastAssignments:(NSArray*)assignments{
    if(self = [self init]){
        NSArray *someArray = assignments;
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        for(NSDictionary *ass in someArray){
            NSNumber *contentType = [ass valueForKey:@"content_type"];
            NSNumber *objectID = [ass valueForKey:@"object_id"];
            int value = 2-[[ass valueForKey:@"editable"] intValue];
            [dictionary addInt:value forContentType:contentType andObjectID:objectID];
        }
        self.hashLookupTable = dictionary;
    }
    return self;
}
-(id)initWithParent:(SelectObjectViewController*)parent{
    if(self = [self init]){
        self.assignment = parent.assignment;
        self.hashLookupTable = parent.hashLookupTable;
        self.sectionNames = parent.sectionNames;
        self.contentTypeIDs = parent.contentTypeIDs;
        self.studentID = parent.studentID;
        studentBased = parent.studentBased;
        self.objectTypes = parent.objectTypes;
        sectionTypeContentType = parent.sectionTypeContentType;
        self.navigationItem.title = [parent.objectTypes objectAtIndex:parent.depth+1];
    }
    return self;
}


- (void)dealloc {
    [objects release];
    [objectTypes release];
    [assignment release];
    [contentTypeIDs release];
    [sectionTitle release];
    [segmentedControl release];
    [filteredObjects release];
    [hashLookupTable release];
    [sectionNames release];
    [_alertViewAction release];
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(assignment == nil){
        self.assignment = [NSMutableDictionary dictionary];
    }
    
    if(self.depth == 2 || isFromSelectedSectionTag)
        self.tableView.tableHeaderView = nil;
    else if(self.depth == 0){
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadNotCached)] autorelease];
        
        //
        UISegmentedControl *sc = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Recursive",@"Sorted by Type", nil]];
        [sc addTarget:self action:@selector(segmentDidChange) forControlEvents:UIControlEventValueChanged];
        sc.selectedSegmentIndex = 0;
        //sc.segmentedControlStyle = UISegmentedControlStyleBezeled;
        sc.frame = CGRectMake(0, 0, self.view.bounds.size.width-20, 40);
        //[container addSubview:sc];
        
        //sc.center = ;
        sc.frame = CGRectMake(sc.frame.origin.x, 10, sc.frame.size.width, sc.frame.size.height);
        self.segmentedControl = sc;
        [sc release];
        //self.tableView.tableHeaderView = container;
        //[container release];
    }

    //self.tableView.backgroundColor = kDefaultTableViewBackgroundColor;
    [self reloadNavigationTitle];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(previousPage)] autorelease];
    
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(self.depth == 0 && section == 0 && tableView == self.tableView){
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
        [container addSubview:segmentedControl];
        segmentedControl.center = CGPointMake(container.bounds.size.width/2, container.bounds.size.height/2);
        return [container autorelease];
        
    }
    return nil;
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(tableView == self.tableView)
        return sectionTitle;
    else
        return [[filteredObjects objectAtIndex:section] valueForKey:@"title"];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.depth == 0 && section == 0 && tableView==self.tableView)
        return 50.0f;
    else if(tableView != self.tableView)
        return [[self tableView:tableView titleForHeaderInSection:section] sizeWithFont:[UIFont boldSystemFontOfSize:16.0f] forWidth:self.view.bounds.size.width-20 lineBreakMode:NSLineBreakByWordWrapping].height;
    else{
        return [[self tableView:tableView titleForHeaderInSection:section] sizeWithFont:[UIFont boldSystemFontOfSize:23.0f] forWidth:self.view.bounds.size.width-20 lineBreakMode:NSLineBreakByWordWrapping].height;
    }
}
-(void)reloadNavigationTitle{
    NSString *title =[objectTypes objectAtIndex:self.depth];
    if(self.depth == 0 && [objects count] >0){
        title = [title stringByAppendingFormat:@" (%d)",[objects count]];
    }
    if(!self.navigationItem.title)
        self.navigationItem.title = title;
}
-(void)segmentDidChange{
    [self.tableView reloadData];
    [self reloadNavigationTitle];
}

-(BOOL)recursiveTabSelected{
    return segmentedControl.selectedSegmentIndex == 0 || self.depth != 0;
}
-(void)reloadNotCached{
    self.navigationItem.leftBarButtonItem.enabled = NO;
    [self loadDataWithCache:NO];
}
-(NSInteger)depth{

    return [self.navigationController.viewControllers indexOfObject:self];
}


-(void)previousPage{
    if(studentBased && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [[NSNotificationCenter defaultCenter] postNotificationName:MC_GRADES_SHOULD_DISMISS_POPOVER object:nil];
    }
    else
        [self.parentViewController dismissModalViewControllerAnimated:YES];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.segmentedControl = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    //if(self.depth ==0 && objects == nil)
        //[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    if(self.depth != 0 && !loadedAttempts)
        [self refreshAttemptsWithCallback:nil];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.depth == 0 && objects == nil){
        [self loadDataWithCache:YES];
    }
    if(scrollToIndex != NSNotFound){
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:scrollToIndex inSection:0] animated:animated scrollPosition:UITableViewScrollPositionMiddle];
        scrollToIndex = NSNotFound;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if(tableView == self.tableView)
        return 1;
    else
        return [filteredObjects count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(tableView == self.tableView){
        if([self recursiveTabSelected])
            return [objects count];
        else
            return [sectionNames count];
    }
    else
        return [[[filteredObjects objectAtIndex:section] valueForKey:@"objects"] count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *array = nil;
    if(tableView == self.tableView)
        array = objects;
    else
        array = [[filteredObjects objectAtIndex:indexPath.section] valueForKey:@"objects"];
    NSString *text = [[array objectAtIndex:indexPath.row] valueForKey:@"tags"];
    if(self.depth == 2 || text != nil || ![text isEqualToString:@""]){
        
		
		UIFont *cellFont = [UIFont systemFontOfSize:14.0f];
        CGFloat width = tableView.frame.size.width;
        if(self.tableView == tableView){
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                width -= 45*2;
            else
                width -= 10*2;
        }
        width-=20;
        
        CGSize constraintSize = CGSizeMake(width, MAXFLOAT);
		CGSize labelSize = [text sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
		CGFloat height = labelSize.height +30;
		if(height >=45)
			return height;
	}
	return 45;
   
}

-(void)refreshAttemptsWithCallback:(void (^)()) block{
    NSInteger depth = self.depth;
    NSInteger contentType = -1;
    
    
    if(depth > 0 && !isFromSelectedSectionTag)
        contentType = [[contentTypeIDs objectAtIndex:depth-1] integerValue];
    else if(isFromSelectedSectionTag)
        contentType = sectionTypeContentType;
    
    __block TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:[NSString stringWithFormat:@"students/%d/completed/?content_type=%d&object_id=%d",studentID,contentType,selectedObjectID]];
    //request.useSVProgressHUD = YES;
    //request.progressLoadingText = @"Loading previous attempts";
    //request.requestContainer = self;
    request.completionBlock = ^{
        loadedAttempts = YES;
        NSArray *results = [[request.responseData JSONValue] valueForKey:@"previous_completed"];
        NSNumber *ct = [self contentTypeForActiveVC];
        for(NSDictionary *attempt in results){
            NSNumber *attemptID = [attempt valueForKey:@"id"];
            
            AssignmentIndicatorType type;
            if([[attempt valueForKey:@"completed"] boolValue])
                type = IndicatorTypeComplete;
            else
                type = IndicatorTypeAssignedAndIncomplete;
            
            [hashLookupTable addInt:type forContentType:ct andObjectID:attemptID];
        }
        NSLog(@"%@",hashLookupTable);
        //NSLog(@"%@",objects);
        
        [self.tableView reloadData];
        if(block)
            block();
    };
                                    
    [request startAsynchronous];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([self recursiveTabSelected] || tableView != self.tableView){
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            cell.indentationWidth = 23.0f;
            cell.textLabel.backgroundColor = [UIColor clearColor];

        }
        cell.detailTextLabel.numberOfLines = 0;
        if((self.depth == 2 || hideAccessoryButtons) || (tableView != self.tableView && [self tableView:tableView titleForHeaderInSection:indexPath.section] != nil)){
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        }
        
        NSDictionary *object = nil;
        if(tableView == self.tableView)
            object = [objects objectAtIndex:indexPath.row];
        else
            object = [[[filteredObjects objectAtIndex:indexPath.section] valueForKey:@"objects"] objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [object valueForKey:@"title"];
        NSString *tag = [object valueForKey:@"tags"];
        
        
        NSNumber *number = nil;
        if(tableView != self.tableView){
            number = [contentTypeIDs objectAtIndex:2];
        }
        else{
            number =[self contentTypeForActiveVC];
        }
            
        
        NSDictionary *contentTypeDict = [hashLookupTable objectForKey:number];
        NSNumber *objectID = [object valueForKey:@"object_id"];
        AssignmentIndicatorType activity = [[contentTypeDict objectForKey:objectID] integerValue];
        

        
        cell.indentationLevel = 0.0;
        switch (activity) {
            case IndicatorTypeUnassigned:
                cell.imageView.image = [UIImage imageNamed:@"unread_unassigned"];
                cell.imageView.highlightedImage = [UIImage imageNamed:@"unread_pressed"];
                break;
            case IndicatorTypeAssignedAndUnread:
                cell.imageView.image = [UIImage imageNamed:@"unread"];
                cell.imageView.highlightedImage = [UIImage imageNamed:@"unread_pressed"];
                break;
            case IndicatorTypeAssignedAndIncomplete:
                cell.imageView.image = [UIImage imageNamed:@"unread_partial"];
                cell.imageView.highlightedImage = [UIImage imageNamed:@"unread_partial_pressed"];
                break;
            case IndicatorTypeComplete:
                cell.imageView.image = nil;
                cell.imageView.highlightedImage = nil;
                cell.indentationLevel = 1.0;
                break;
        }

        if((self.depth == 2 || tableView != self.tableView )&& ![tag isEqualToString:@""]){
            cell.detailTextLabel.text = tag;
        }
        else
            cell.detailTextLabel.text = nil;
        // Configure the cell...
        
        return cell;
    }
    else{
        static NSString *CellIdentifier = @"OtherCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell.indentationWidth = 23.0f;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
        cell.textLabel.text = [[sectionNames objectAtIndex:indexPath.row] valueForKey:@"name"];
        
        return cell;
    }
}

//
//-(AssignmentIndicatorType)indicatorTypeForContentType:(NSNumber*)c_type objectID:(NSNumber*)obj_id{
//    NSLog(@"id=%@,ct=%@",obj_id,c_type);
//    NSDictionary *hit = [[assignments filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"content_type = %@ && object_id = %@",c_type,obj_id]] lastObject];
//    NSLog(@"%@",hit);
//    if (hit == nil){
//        return IndicatorTypeUnassigned;
//    }
//    else{
//        if([[hit valueForKey:@"editable"] boolValue])
//            return IndicatorTypeAssignedAndUnread;
//        else{
//            if([[hit valueForKey:@"completed"] boolValue])
//                return IndicatorTypeComplete;
//            else {
//                return IndicatorTypeAssignedAndIncomplete;
//            }
//        }
//    }
//}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    if(self.depth == 1 && [[[objects objectAtIndex:indexPath.row] valueForKey:@"title"] isEqualToString:@"Math"])
        [self tableView:tableView didSelectRowAtIndexPath:indexPath];
    else{
        NSIndexPath *path = indexPath;
        if(tableView != self.tableView){
            
            path = [NSIndexPath indexPathForRow:[objects indexOfObject:[[[filteredObjects objectAtIndex:indexPath.section] valueForKey:@"objects"] objectAtIndex:indexPath.row]] inSection:0];
        }
        
        [self traverseTreeForIndexPath:path animated:YES scrollToIndex:NSNotFound];
    }
}

-(void)traverseTreeForIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated scrollToIndex:(NSInteger)number{
    
    SelectObjectViewController *activeVC = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-1];

    
    SelectObjectViewController *vc = [[SelectObjectViewController alloc] initWithParent:activeVC];
    vc.objects = [[activeVC.objects objectAtIndex:indexPath.row] valueForKey:@"objects"];
    NSString *initial = @"";
    if(activeVC.depth > 0)
        initial = [activeVC.sectionTitle stringByAppendingString:@" \u2192 "];
    vc.sectionTitle = [initial stringByAppendingString:[[activeVC.objects objectAtIndex:indexPath.row] valueForKey:@"title"]];
    vc.scrollToIndex = number;
    
    vc.selectedObjectID = [[[activeVC.objects objectAtIndex:indexPath.row] valueForKey:@"object_id"] integerValue];
    [self.navigationController pushViewController:vc animated:animated];
    [vc release];
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

#pragma mark - Table view delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        if(_alertViewAction)
            self.alertViewAction();
        
        [assignment removeObjectForKey:@"subset"];
        [assignment setValue:@(NO) forKey:@"is_subset"];
        
    }
    else{
        CustomizeAssignmentViewController *vc = [[CustomizeAssignmentViewController alloc] init];
        vc.studentID = studentID;
        vc.delegate = self;
        vc.assignment = assignment;
        vc.hashLookupTable = hashLookupTable;
        
        
        
        //if([assignment[@"subset"] != nil] && [assignment[@"object_id"] intValue] != )
        [assignment removeObjectForKey:@"subset"];//removes previous subset so a ghost occurrence doesn't form
        
        
        
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self recursiveTabSelected] || self.tableView != tableView){
        NSDictionary *selectedObject = nil;
        if(tableView == self.tableView){
            selectedObject = [objects objectAtIndex:indexPath.row];
            [assignment setValue:[contentTypeIDs objectAtIndex:self.depth] forKey:@"content_type"];
        }
        else{
            selectedObject = [[[filteredObjects objectAtIndex:indexPath.section] valueForKey:@"objects"] objectAtIndex:indexPath.row];
            NSNumber *ct = nil;
            if([self tableView:tableView titleForHeaderInSection:indexPath.section] == nil)
                ct = [contentTypeIDs objectAtIndex:0];
            else
                ct=[contentTypeIDs objectAtIndex:2];
            
            [assignment setValue:ct forKey:@"content_type"];
        }
        

        [assignment setValue:[selectedObject valueForKey:@"object_id"] forKey:@"object_id"];
        
        if(!studentBased && ENABLE_SUBSET_ASSIGNMENTS){
            //prompt tutor whether he wants to customize the assignment or use the default
            __block typeof(self) blockSelf = self;
            self.alertViewAction = ^{
                //this only gets called right away in the default scenario, and it will get saved to execute after customizing the subset in the alternative case
                [blockSelf getAssignmentDescription:selectedObject search:tableView != blockSelf.tableView && [blockSelf tableView:tableView titleForHeaderInSection:indexPath.section] != nil];
                
                
            };
            UIAlertView *alert = [[UIAlertView alloc]  initWithTitle:@"Customize?" message:@"Would you like to assign a special subset of the selected assignment or assign it in whole?" delegate:self cancelButtonTitle:@"Customize..." otherButtonTitles:@"Default", nil];
            [alert show];
            [alert release];
            
        }
        else
            [self getAssignmentDescription:selectedObject search:tableView != self.tableView && [self tableView:tableView titleForHeaderInSection:indexPath.section] != nil];

    }
    else{
        
        NSArray *subArray = [objects groupByTakingSubElementAtIndex:indexPath.row withKey:@"objects" titleReplacement:@"title"];
        
        SelectObjectViewController *vc = [[SelectObjectViewController alloc] initWithParent:self];
        vc.objects = subArray;
        vc.sectionTitle = nil;
        
        vc.hideAccessoryButtons = [[[sectionNames objectAtIndex:indexPath.row] valueForKey:@"name"] isEqualToString:@"Math"];
        vc.navigationItem.title = [[sectionNames objectAtIndex:indexPath.row] valueForKey:@"name"];
        vc.isFromSelectedSectionTag = YES;
        vc.selectedObjectID = [[[sectionNames objectAtIndex:indexPath.row] valueForKey:@"id"] integerValue];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
    
}


-(void)getAssignmentDescription:(NSDictionary*)selectedObject search:(BOOL)searched{
    NSInteger dep = self.depth;
    if(searched)
        dep = 2;
    
    __block TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:[NSString stringWithFormat:@"assignmentinfo/ct/%@/id/%@/",[contentTypeIDs objectAtIndex:dep],[selectedObject valueForKey:@"object_id"]]];
    //request.requestContainer = self;
    request.useSVProgressHUD = YES;
    request.progressFailureText = @"Connection Error:\nUnable to add assignment.";
    request.progressMaskType = SVProgressHUDMaskTypeClear;
    request.completionBlock = ^{
        
        
        NSDictionary *dict = [[request responseData] JSONValue];
        
        if(!studentBased){
            [assignment setValue:[dict valueForKey:@"detailTextLabel"] forKey:@"detailTextLabel"];
            [assignment setValue:[dict valueForKey:@"textLabel"] forKey:@"textLabel"];
            [self previousPage];
        }
        else{
            ChooseTutorViewController *vc = [[ChooseTutorViewController alloc] init];
            vc.studentID = studentID;
            vc.assignment = dict;
            vc.objectID = [[assignment valueForKey:@"object_id"] integerValue];
            vc.contentType = [[assignment valueForKey:@"content_type"] integerValue];
            
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        }
    };
    request.failedBlock = ^{
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];  
    };
    [request startAsynchronous];

    
    
    
}
-(void)getAssignmentDescription:(NSDictionary*)selectedObject{
    [self getAssignmentDescription:selectedObject search:NO];
}


-(NSNumber*)contentTypeForActiveVC{
    NSInteger depth = self.depth;
    if(depth == 0 && ![self recursiveTabSelected]){
        return [NSNumber numberWithInteger:sectionTypeContentType];
    }
    else{
        if(depth == 1 && isFromSelectedSectionTag){
            depth = 0;
            
        }
        return [contentTypeIDs objectAtIndex:depth];
    }
}
-(void)loadDataWithCache:(BOOL)cached{
    
    
    
    __block TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:@"db_structure/"];
    //request.requestContainer = self;
    if(cached){
        request.cachePolicy = ASIAskServerIfModifiedWhenStaleCachePolicy;
        request.useSVProgressHUD = NO;
    }
    else
        request.useSVProgressHUD = YES;
    
    
//request.secondsToCache = 7*86400;
    //request.requestMethod = @"GET";
    request.completionBlock = ^{
        NSDictionary *dict = [[request responseData] JSONValue];
        self.objects = [dict valueForKey:@"tests"];
        self.contentTypeIDs = [dict valueForKey:@"content_type_ids"];
        self.objectTypes = [dict valueForKey:@"content_type_names"];
        self.sectionNames = [dict valueForKey:@"section_names"];
        sectionTypeContentType = [[dict valueForKey:@"section_tag_ct"] integerValue];
        [self reloadNavigationTitle];
        
        [self.tableView reloadData];
        id block = nil;
        if([assignment valueForKey:@"content_type"] != nil){
            NSInteger offset = [contentTypeIDs indexOfObject:[assignment valueForKey:@"content_type"]];
            
            if(offset == 0){
                NSInteger row = [[objects valueForKey:@"object_id"] indexOfObject:[assignment valueForKey:@"object_id"]];
                block = ^{
                    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
                };
                
                
            }
            else{
                NSIndexPath *path = [self pathToAssignment];
                for(int x =0;x< [path length]-1;x++){
                    NSInteger scrollTo = NSNotFound;
                    BOOL animated = NO;
                    if(x==[path length]-2){
                        scrollTo = [path indexAtPosition:x+1];
                        animated = YES;
                    }
                    
                    [self traverseTreeForIndexPath:[NSIndexPath indexPathForRow:[path indexAtPosition:x] inSection:0] animated:animated scrollToIndex:scrollTo];
                }
            }
        }
        [self refreshAttemptsWithCallback:block];
        self.navigationItem.leftBarButtonItem.enabled = YES;
        
        
    };
    ;
    [request startAsynchronous];


}

-(NSIndexPath*)pathToAssignment{
    NSInteger offset = [contentTypeIDs indexOfObject:[assignment valueForKey:@"content_type"]];
    if (offset == 0)
        return nil;
    else if(offset == 1){
        NSUInteger index1 = 0;
        NSUInteger index2 = NSNotFound;
        for(NSArray *passages in [objects valueForKey:@"objects"]){
            index2 = [[passages valueForKey:@"object_id"] indexOfObject:[assignment valueForKey:@"object_id"]];
            if(index2 != NSNotFound)
                break;
            index1++;
        }
        NSUInteger path[2];
        path[0] = index1;
        path[1] = index2;
        return [NSIndexPath indexPathWithIndexes:path length:2];
    }
    else if(offset == 2){
        NSUInteger index1=0,index2=0,index3=NSNotFound;
        for(NSArray *sections in [objects valueForKey:@"objects"]){
            
            index2=0;
            for(NSArray *passages in [sections valueForKey:@"objects"]){
                index3 = [[passages valueForKey:@"object_id"] indexOfObject:[assignment valueForKey:@"object_id"]];
                if(index3 != NSNotFound)
                    break;
                index2++;
            }
            if(index2 != [sections count])
                break;
            index1++;
        }
        NSUInteger path[3];
        path[0] = index1;
        path[1] = index2;
        path[2] = index3;
        return [NSIndexPath indexPathWithIndexes:path length:3];
    }
    return nil;
}
- (BOOL)searchDisplayController:(UISearchDisplayController*)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
	
	[self filterContentForSearchText:controller.searchBar.text scope:[controller.searchBar.scopeButtonTitles objectAtIndex:self.searchDisplayController.searchBar.selectedScopeButtonIndex]];
	
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    
    
	[self filterContentForSearchText:searchString scope:[controller.searchBar.scopeButtonTitles objectAtIndex:self.searchDisplayController.searchBar.selectedScopeButtonIndex]];
	
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
	self.filteredObjects = nil;
   
    
    searchText = [searchText stringByReplacingOccurrencesOfString:@"," withString:@" "];
    
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"p_name contains[cd] %@ || tags contains[cd] %@",searchText,searchText];
    NSMutableArray *results = [NSMutableArray array];
    if(self.depth == 0){
        NSArray *testsFilter = [objects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title contains[cd] %@",searchText]];
        if([testsFilter count] > 0){
            [results addObject:[NSDictionary dictionaryWithObject:testsFilter forKey:@"objects"]];
        }
        for(NSDictionary *subLevel in objects){
            NSString *testName = [subLevel valueForKey:@"title"];
            
            NSArray *array = [subLevel valueForKey:@"objects"];
            for(NSDictionary *subsubLevel in array){
                NSArray *subArray = [[subsubLevel valueForKey:@"objects"] filteredArrayUsingPredicate:predicate];
                if([subArray count] > 0){
                    [results addObject:[NSDictionary dictionaryWithObjectsAndKeys:subArray,@"objects",[NSString stringWithFormat:@"%@ - %@",[subsubLevel valueForKey:@"title"],testName],@"title",nil]];
                }
            }
        }
        
    }
    else if (self.depth == 1){
        for(NSDictionary *subLevel in objects){
            NSArray *array = [[subLevel valueForKey:@"objects"] filteredArrayUsingPredicate:predicate];
            if([array count] > 0){
                [results addObject:[NSDictionary dictionaryWithObjectsAndKeys:array,@"objects",[subLevel valueForKey:@"title"],@"title", nil]];
            }
        }
    }
    
	
	self.filteredObjects = [NSArray arrayWithArray:results];
	
	

}
@end
