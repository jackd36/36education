//
//  AssignHomeworkViewController.m
//  MC HW
//
//  Created by Eric Lubin on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AssignHomeworkViewController.h"
#import "NSDate+prettifiedRelativeDateString.h"
#import "NSArray+Grouping.h"
#import "AssignmentInfoViewController.h"
#import "HomeworkTableViewCell.h"
#import "TestTakingViewController.h"
#import "GenericTestUploadHTTPRequest.h"
#import "UnuploadedTestTableViewCell.h"
#import "UnuploadedTestsViewController.h"
#import "CustomizeAssignmentViewController.h"
#import "WEPopoverController.h"
@interface AssignHomeworkViewController()
@property (nonatomic,strong) NSMutableArray *objects;
-(void)sectionizeObjects;
-(void)updateAssigment:(NSInteger)assignmentID WithDictionary:(NSDictionary*)dict replace:(BOOL)replace;
@property (nonatomic,strong) NSArray *sections;
@property (nonatomic,getter=objectsChanged) BOOL dirty;
@property (nonatomic,strong) UIPopoverController *activePopover;
@property (nonatomic,retain) NSDictionary *unuploadedTests;
@end
@implementation AssignHomeworkViewController
@synthesize objects,sections,student,dirty,tutor,activePopover,unuploadedTests;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        // Custom initialization
    }
    return self;
}

-(id)init{
    if(self = [self initWithStyle:UITableViewStylePlain]){
        
    }
    return self;
}

-(NSMutableArray*)completedUnuploadedTests{
    return [self.unuploadedTests objectForKey:[NSNumber numberWithInt:CompletedTestUpload]];
}

-(NSMutableArray*)incompleteUnuploadedTests{
    return [self.unuploadedTests objectForKey:[NSNumber numberWithInt:UncompletedTestUpload]];
}

-(NSDictionary*)unuploadedTests{
    if(unuploadedTests == nil){
        NSArray *complete = [GenericTestUploadHTTPRequest unuploadedTestsWithStatus:CompletedTestUpload forUploader:tutor.object_id];
        NSArray *incomplete = [GenericTestUploadHTTPRequest unuploadedTestsWithStatus:UncompletedTestUpload forUploader:tutor.object_id];
        
        self.unuploadedTests = [NSDictionary dictionaryWithObjectsAndKeys:complete,[NSNumber numberWithInt:CompletedTestUpload],incomplete,[NSNumber numberWithInt:UncompletedTestUpload], nil];
    }
    return  unuploadedTests;
}

- (void)dealloc {
    [activePopover release];
    [objects release];
    [sections release];
    [student release];
    [tutor release];
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    self.sections = nil;
    self.activePopover = nil;
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Assignments";
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    [self sectionizeObjects];
    self.tableView.rowHeight=55.0f;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newAssignment)] autorelease];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:THIRTYSIX_ED_DID_ADD_ASSIGNMENT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:THIRTYSIX_ED_DID_CHANGE_ASSIGNMENT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:THIRTY_SIX_DID_COMPLETE_ASSIGNMENT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:THIRTY_SIX_ASSIGNMENT_STATUS_DID_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:MC_GRADES_SHOULD_DISMISS_POPOVER object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:DID_COMPLETE_UPLOADING_FALLBACKS object:nil];
    
}
//-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
//    if([activePopover isPopoverVisible]){
//        UINavigationController *nc = (UINavigationController*)activePopover.contentViewController;
//        AssignmentInfoViewController *vc = (AssignmentInfoViewController*)[nc.viewControllers objectAtIndex:0];
//        if(![vc isEditing]){
//            [activePopover dismissPopoverAnimated:YES];
//            self.activePopover = nil;
//        }
//    }
//    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
//}
-(NSArray*)sections{
    if(sections == nil || [self objectsChanged]){
        [self sectionizeObjects];
        dirty = FALSE;
        
    }
    
    return sections;
}

-(void)notificationReceived:(NSNotification*)notif{
    if([notif.name isEqualToString:MC_GRADES_SHOULD_DISMISS_POPOVER]){
        [activePopover dismissPopoverAnimated:YES];
        self.activePopover=nil;
    }
    else if([notif.name isEqualToString:DID_COMPLETE_UPLOADING_FALLBACKS]){
        dirty = YES;
        self.unuploadedTests = nil;
        [self.tableView reloadData];
    }
    else{
        NSMutableDictionary *assignment = [notif.userInfo valueForKey:@"assignment"];
        if([notif.name isEqualToString:THIRTYSIX_ED_DID_ADD_ASSIGNMENT]){;
            [assignment setValue:[NSNumber numberWithInt:tutor.object_id] forKey:@"tutor_id"];
            [objects addObject:assignment];
            dirty = YES;
            
        }
        else if([notif.name isEqualToString:THIRTYSIX_ED_DID_CHANGE_ASSIGNMENT]){
            //[self updateAssigment:[[assignment valueForKey:@"id"] integerValue] WithDictionary:assignment replace:YES];
            //no action needed, we switched it so we are modifying the items in place
        }
        else if([notif.name isEqualToString:THIRTY_SIX_DID_COMPLETE_ASSIGNMENT]){
            
            NSArray *filtered = [objects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %@",[notif.userInfo valueForKey:@"id"]]];
            
            [objects removeObjectsInArray:filtered];
            dirty=YES;
        }
        else if([notif.name isEqualToString:THIRTY_SIX_ASSIGNMENT_STATUS_DID_CHANGE]){
            NSArray *filtered = [objects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %@",[notif.userInfo valueForKey:@"id"]]];
            NSDictionary *oldObject = [filtered lastObject];
            NSMutableDictionary *newAssignment = [NSMutableDictionary dictionaryWithDictionary:oldObject];
            [newAssignment setValue:[NSNumber numberWithBool:NO] forKey:@"editable"];
            
            NSInteger oldIndex = [objects indexOfObject:oldObject];
            if(oldIndex == NSNotFound){
                NSLog(@"Weird issue with this object, is it nil?: %@",oldObject);
                
            }
            else
                [objects replaceObjectAtIndex:oldIndex withObject:newAssignment];
            
            [activePopover dismissPopoverAnimated:YES];
            self.activePopover = nil;
            dirty = YES;
        }

        [self.tableView reloadData];
    }
}
-(void)updateAssigment:(NSInteger)assignmentID WithDictionary:(NSDictionary*)dict replace:(BOOL)replace{
    NSDictionary *oldAssignment = [[objects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %d",assignmentID]] lastObject];
    
    
    if(replace){
        [objects replaceObjectAtIndex:[objects indexOfObject:oldAssignment] withObject:dict];
    }
    else{
        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:oldAssignment];
        [objects removeObject:oldAssignment];
        [mutableDict addEntriesFromDictionary:dict];
        [objects addObject:mutableDict];
    }
    dirty = YES;
}
-(void)newAssignment{
    
    AssignmentInfoViewController *vc = [[AssignmentInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
    vc.student = student;
    vc.allAssignments = objects;
    
    //vc.assignments = objects;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    //nc.navigationBar.tintColor = kDefaultToolbarColor;
    //vc.attempsIDs = attemptIDs;
    [vc release];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        [self presentModalViewController:nc animated:YES];
    else{
        if([activePopover isPopoverVisible]){
            [activePopover dismissPopoverAnimated:YES];
            self.activePopover = nil;
        }
        else{
            
            
            
            UIPopoverController *pc = [[UIPopoverController alloc] initWithContentViewController:nc];
            pc.delegate = vc;
            

            self.activePopover = pc;
            [pc presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            [pc release];
        }
    }
    [nc release];
}
-(NSArray*)arrayOfHomeworkAssignments{
    //return array of attempts, without duplicates, including content_type, object_id, and whether or not its editable
    // this will be taken from the objects property so wont just be limited to the active tutor
    return nil;
}


-(void)sectionizeObjects{
    [objects sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"due_date" ascending:YES]]];
    
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
    NSDateComponents *components = [calendar components:preservedComponents fromDate:today];
    today = [calendar dateFromComponents:components];
    components.day+=1;
    
    NSDate *tomorrow = [calendar dateFromComponents:components];
    components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit fromDate:today];
    components.day+=8-components.weekday;
    NSDate *nextSunday = [calendar dateFromComponents:components];
    components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:today];
    components.month+=1;
    components.day = 1;
    NSDate *nextMonthBegins = [calendar dateFromComponents:components];
    components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:today];
    components.month+=2;
    components.day = 1;
    NSDate *nextNextMonthBegins = [calendar dateFromComponents:components];
    components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:today];
    components.year+=1;
    components.month = 1;
    components.day = 1;
    NSDate *nextYearBegins = [calendar dateFromComponents:components];
    components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:today];
    components.year+=2;
    components.month = 1;
    components.day = 1;
    NSDate *nextNextYearBegins = [calendar dateFromComponents:components];
    NSArray *filtered = [objects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tutor_id == %@",[NSNumber numberWithInteger:tutor.object_id]]];
    NSArray *grouped = [filtered groupUsingBlock:^NSString *(id object) {
        id due = [object valueForKey:@"due_date"];
        if(due == [NSNull null] || due == nil)
            return @"NONE";
        NSInteger objectDate = [due intValue];
        if(objectDate < [today timeIntervalSince1970])
            return @"Overdue";
        else if(objectDate < [tomorrow timeIntervalSince1970])
            return @"Today";
        else if(objectDate < [tomorrow timeIntervalSince1970]+86400)
            return @"Tomorrow";
        else if(objectDate < [nextSunday timeIntervalSince1970])
            return @"This Week";
        else if(objectDate < [nextSunday timeIntervalSince1970]+86400*7)
            return @"Next Week";
        else if(objectDate < [nextMonthBegins timeIntervalSince1970])
            return @"This Month";
        else if(objectDate < [nextNextMonthBegins timeIntervalSince1970])
            return @"Next Month";
        else if(objectDate < [nextYearBegins timeIntervalSince1970])
            return @"This Year";
        else if(objectDate < [nextNextYearBegins timeIntervalSince1970])
            return @"Next Year";
        return @"A long ways away…";
    }];
    self.sections = grouped;
    //NSLog(@"%@",grouped);
    
}
-(void)reloadTableViewDataSource{
    
    [self loadAssignments:NO];
    
    
    
    
    //NSLog(@"%@",url);
}
-(NSString*)uniqueURLPath{
    return [NSString stringWithFormat:@"students/%@/hw/",[student valueForKey:@"id"]];
}
-(void)loadAssignments:(BOOL)cached{
    __block TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:[self uniqueURLPath]];
    //request.requestContainer = self;
    request.cachePolicy = ASIAskServerIfModifiedCachePolicy |ASIFallbackToCacheIfLoadFailsCachePolicy;
    request.useSVProgressHUD = objects == nil;
    //request.useSVProgressHUD = objects == nil;
    /*if(cached){
        request.cachePolicy = ASIAskServerIfModifiedWhenStaleCachePolicy;
        
    }*/
    request.completionBlock = ^{
        NSDictionary *dict = [[request responseData] JSONValue];
        
        NSArray *array = [dict valueForKey:@"list"];
        //we need to make copies of each dictionary to make them mutable
        NSMutableArray *newListarray = [NSMutableArray arrayWithCapacity:[array count]];
        for (NSDictionary *assignment in array){
            [newListarray addObject:[[assignment mutableCopy] autorelease]];
        }
        
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
            TestUpload upload = [self doesContainElementsForAssignment:evaluatedObject];
            return !(upload & CompletedTestUpload) ||  [[evaluatedObject valueForKey:@"contentObjectType"] isEqualToString:@"Test"];
        }];
        self.objects = [NSMutableArray arrayWithArray:[newListarray filteredArrayUsingPredicate:predicate]];
        
        self.sections = nil;
        
        [self.tableView reloadData];
        [self doneLoadingTableViewDataWithSuccess:request.didLoadFromWeb];
    };
    request.failedBlock = ^{
        [self doneLoadingTableViewDataWithSuccess:NO];
    };
    
    
    
    [request startAsynchronous];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    CustomizeAssignmentViewController *vc = [[CustomizeAssignmentViewController alloc] init];
    vc.readOnly = YES;
    

    
    vc.studentID=[student[@"id"] integerValue];
    
    vc.assignment =self.sections[indexPath.section][NSARRAY_GROUPING_OBJECTS_STRING ][indexPath.row];
    
    vc.hashLookupTable = [NSMutableDictionary dictionary];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [vc release];
    nc.modalPresentationStyle = UIModalPresentationFormSheet;
    UITableViewCell *popoverCell = [self.tableView cellForRowAtIndexPath:indexPath];
    CGRect popoverRect = CGRectMake(popoverCell.bounds.size.width-50,13,29,29);
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){//present in popover
        vc.inPopover = YES;
        UIPopoverController *pc = [[UIPopoverController alloc] initWithContentViewController:nc];
        self.activePopover = pc;
        
        [pc release];
        
        
        [pc presentPopoverFromRect:popoverRect inView:popoverCell permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else{
        
        if(IS_IPHONE_5){
            vc.inPopover = YES;   
        
            WEPopoverController * pc = [[WEPopoverController alloc] initWithContentViewController:nc];
            self.activePopover = (UIPopoverController*)pc;
            [pc presentPopoverFromRect:popoverRect inView:popoverCell permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            [pc release];
        }
        else{
            [self presentViewController:nc animated:YES completion:nil];
        }
    }
    //}
    
    
    [nc release];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    self.sections = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(sections == nil)
        [self loadAssignments:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return [self.sections count]+(self.completedUnuploadedTests.count > 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(self.completedUnuploadedTests.count > 0){
        if(section == 0)
            return 1;
        section--;
    }
    return [[[self.sections objectAtIndex:section] valueForKey:NSARRAY_GROUPING_OBJECTS_STRING] count];
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(self.completedUnuploadedTests.count > 0){
        if(section == 0){
            return nil;
        }
        section--;
    }
    NSString *title = [[self.sections objectAtIndex:section] valueForKey:NSARRAY_GROUPING_SECTION_TITLE_STRING];

    if([title isEqualToString:@"NONE"])
        return nil;
    return title;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger countOfTests = self.completedUnuploadedTests.count;
    if(countOfTests > 0){
        if(indexPath.section == 0){
            UnuploadedTestTableViewCell *cell = [[[UnuploadedTestTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
            cell.state = ELUploadingStateAlertFailed;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.text = [NSString stringWithFormat:@"%d assignment%@ failed to upload.\nTap to resubmit.",countOfTests,countOfTests != 1?@"s":@""];
            cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
            return cell;
        }
        
        
        
    }
    
    static NSString *CellIdentifier = @"Cell";
    
    HomeworkTableViewCell *cell = (HomeworkTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[HomeworkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.captionLabel.adjustsFontSizeToFitWidth = NO;
        cell.titleLabel.adjustsFontSizeToFitWidth = YES;
        cell.captionLabel.textColor = [UIColor lightGrayColor];
    }
    
    
    NSInteger section = indexPath.section;
    if(countOfTests > 0){
        section--;
    }
    
    
    NSDictionary *assignment = [[[self.sections objectAtIndex:section] valueForKey:NSARRAY_GROUPING_OBJECTS_STRING] objectAtIndex:indexPath.row];
    
    
    
    [cell setAssignment:assignment];
    TestUpload upload = [self doesContainElementsForAssignment:assignment];
    if(upload & UncompletedTestUpload){
        cell.imageView.image = [UIImage imageNamed:@"failure-btn"];
        cell.imageView.highlightedImage = nil;
    }
    return cell;
}

-(TestUpload)doesContainElementsForAssignment:(NSDictionary*)assignment{
    NSInteger assignmentID = [[assignment valueForKey:@"id"] integerValue];
    return [GenericTestUploadHTTPRequest testUploadForAssignment:assignmentID uid:tutor.object_id];
}


-(void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeworkTableViewCell *cell = (HomeworkTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.titleLabel.adjustsFontSizeToFitWidth = NO;
}
-(void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeworkTableViewCell *cell = (HomeworkTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.titleLabel.adjustsFontSizeToFitWidth = YES;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger countOfTests = self.completedUnuploadedTests.count;
    NSInteger section = indexPath.section;
    if(countOfTests > 0){
        if(indexPath.section == 0)
            return NO;
        section--;
    }
    
    NSDictionary *assignment = [[[self.sections objectAtIndex:section] valueForKey:NSARRAY_GROUPING_OBJECTS_STRING] objectAtIndex:indexPath.row];
    return [[assignment valueForKey:@"editable"] boolValue];
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSInteger countOfTests = self.completedUnuploadedTests.count;
        NSInteger section = indexPath.section;
        if(countOfTests > 0){
            section--;
        }
        
        NSDictionary *assignment = [[[self.sections objectAtIndex:section] valueForKey:NSARRAY_GROUPING_OBJECTS_STRING] objectAtIndex:indexPath.row];
        if([[assignment valueForKey:@"editable"] boolValue]){
            
            __block TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:[NSString stringWithFormat:@"hw/%@/remove/",[assignment valueForKey:@"id"]]];
            //request.requestContainer = self;
            request.useSVProgressHUD = YES;
            request.responseStringAsErrorMessage = YES;
            request.progressMaskType = SVProgressHUDMaskTypeClear;
            //request.userInfo = [NSDictionary dictionaryWithObject:indexPath forKey:@"indexPath"];
            request.completionBlock = ^{
                //NSIndexPath *indexPath = [request.userInfo valueForKey:@"indexPath"];
//                NSDictionary *assignment = [[[self.sections objectAtIndex:indexPath.section] valueForKey:NSARRAY_GROUPING_OBJECTS_STRING] objectAtIndex:indexPath.row];
                
                
                NSString *oldSectionName = [[self.sections objectAtIndex:section] valueForKey:NSARRAY_GROUPING_SECTION_TITLE_STRING];
                [objects removeObject:assignment];
                dirty = YES;
                NSLog(@"%@",self.sections);
                //NSDictionary *otherAssignment = [objects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %@",[assignment valueForKey:@"id"]]];
                
                if([self.sections count] <= section || ![[[self.sections objectAtIndex:section] valueForKey:NSARRAY_GROUPING_SECTION_TITLE_STRING] isEqualToString:oldSectionName]){
                    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
                }
                else{
                    
                    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                }
                
            };
            request.failedBlock = ^{
                if([request responseStatusCode] == 400 && [[request responseString] isEqualToString:@"Assignment already begun"]){
                    
                    NSDictionary *assignment = [[[self.sections objectAtIndex:section] valueForKey:NSARRAY_GROUPING_OBJECTS_STRING] objectAtIndex:indexPath.row];
                    [self updateAssigment:[[assignment valueForKey:@"id"] integerValue] WithDictionary:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:FALSE] forKey:@"editable"] replace:NO];
                    [self.tableView reloadData];
                }  
            };
            [request startAsynchronous];
            
            
        }
        // Delete the row from the data source
        
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger countOfTests = self.completedUnuploadedTests.count;
    
    if(countOfTests > 0 ||  self.incompleteUnuploadedTests.count > 0){
        //present WEPopover of viewcontroller here
        UnuploadedTestsViewController *vc3 = [[UnuploadedTestsViewController alloc] initWithUID:tutor.object_id];
        
        
        UINavigationController *container = [[UINavigationController alloc] initWithRootViewController:vc3];
        container.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:container animated:YES completion:nil];
        [container release];
        [vc3 release];
        
    }
    else{
        AssignmentInfoViewController *vc = [[AssignmentInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
        //vc.attempsIDs = attemptIDs;
        vc.student = student;
        //vc.assignments = objects;
        vc.allAssignments = objects;
        vc.activeAssignment = [[[self.sections objectAtIndex:indexPath.section] valueForKey:NSARRAY_GROUPING_OBJECTS_STRING] objectAtIndex:indexPath.row];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
            UIPopoverController *pc = [[UIPopoverController alloc] initWithContentViewController:nc];
            pc.delegate = vc;
            
            
            self.activePopover = pc;
            CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
            //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [pc presentPopoverFromRect:cellRect inView:self.tableView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            [pc release];
            [nc release];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        else
            [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
}



@end
