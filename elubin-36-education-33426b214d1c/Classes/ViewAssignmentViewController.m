//
//  ViewAssignmentViewController.m
//  MC HW
//
//  Created by Eric Lubin on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewAssignmentViewController.h"
#import "NSArray+Grouping.h"
#import "HomeworkTableViewCell.h"
#import "AssignmentInfoViewController.h"
#import "TestTakingViewController.h"
#import "SelectObjectViewController.h"
#import "UIImage+extensions.h"
#import "ChangePasswordViewController.h"
#import "StudentActionViewController.h"
#import "GenericTestUploadHTTPRequest.h"
#import "UnuploadedTestTableViewCell.h"
#import "UnuploadedTestsViewController.h"
#import "CustomizeAssignmentViewController.h"
#import "AppStartViewController.h"
#import "ELAppDelegate.h"
@interface ViewAssignmentViewController()
@property (nonatomic,strong) NSMutableArray *unsortedAssignments;
@property (nonatomic,strong) NSArray *sortedSections;
@property (nonatomic,retain) UIPopoverController *activePopover;
@property (nonatomic) BOOL refreshDataOnNextAppearance;
@property (nonatomic,retain) NSDictionary *unuploadedTests;

-(NSMutableDictionary*)assignmentForIndexPath:(NSIndexPath*)indexPath;
-(void)reloadTableViewDataSource;
@end

@implementation ViewAssignmentViewController

@synthesize student,unsortedAssignments,sortedSections,refreshDataOnNextAppearance,activePopover,unuploadedTests;

-(NSMutableArray*)completedUnuploadedTests{
    return [self.unuploadedTests objectForKey:[NSNumber numberWithInt:CompletedTestUpload]];
}

-(NSMutableArray*)incompleteUnuploadedTests{
    return [self.unuploadedTests objectForKey:[NSNumber numberWithInt:UncompletedTestUpload]];
}
- (id)init
{
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        else
            self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        // Custom initialization
    }
    return self;
}
- (void)dealloc {
    [student release];
    [unsortedAssignments release];
    [activePopover release];
    [unuploadedTests release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
-(void)viewDidUnload{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    self.sortedSections = nil;
    // Release any cached data, images, etc that aren't in use.
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(self.completedUnuploadedTests.count > 0){
        if(section == 0){
            return nil;
        }
        section--;
    }
    return [[self.sortedSections objectAtIndex:section] valueForKey:NSARRAY_GROUPING_SECTION_TITLE_STRING];
}
-(NSArray*)sortedSections{ //lazy load the sorted sections
    if(sortedSections == nil){
        NSArray *array = [unsortedAssignments groupUsingKey:@"tutor"];
        self.sortedSections = [array sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:NSARRAY_GROUPING_SECTION_TITLE_STRING ascending:YES]]];
        
    }
    return sortedSections;
}
#pragma mark - View lifecycle


-(NSDictionary*)unuploadedTests{
    if(unuploadedTests == nil){
        NSArray *complete = [GenericTestUploadHTTPRequest unuploadedTestsWithStatus:CompletedTestUpload forUploader:student.object_id];
        NSArray *incomplete = [GenericTestUploadHTTPRequest unuploadedTestsWithStatus:UncompletedTestUpload forUploader:student.object_id];
        
        self.unuploadedTests = [NSDictionary dictionaryWithObjectsAndKeys:complete,[NSNumber numberWithInt:CompletedTestUpload],incomplete,[NSNumber numberWithInt:UncompletedTestUpload], nil];
    }
    return  unuploadedTests;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    
    self.navigationItem.title = @"Assignments";
    self.tableView.rowHeight=55.0f;
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"19-gear" withColor:[UIColor whiteColor]] style:UIBarButtonItemStyleBordered target:self action:@selector(showActionSheet:)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(otherAssignment)] autorelease];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:THIRTY_SIX_DID_COMPLETE_ASSIGNMENT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:THIRTY_SIX_ASSIGNMENT_STATUS_DID_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:THIRTYSIX_ED_DID_ADD_ASSIGNMENT object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:MC_GRADES_SHOULD_DISMISS_POPOVER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:DID_COMPLETE_UPLOADING_FALLBACKS object:nil];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)showActionSheet:(UIBarButtonItem*)button{
    if([activePopover.contentViewController isKindOfClass:[UINavigationController class]] && [((UINavigationController*)activePopover.contentViewController).topViewController isKindOfClass:[ChangePasswordViewController class]] ){
        return;
    }
    if(actionSheetVisible)
        return;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Log Out" otherButtonTitles:@"Change Password",@"Check for Updates", nil];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [actionSheet showFromBarButtonItem:button animated:YES];
        actionSheetVisible = YES;
    }
    else
        [actionSheet showFromToolbar:self.navigationController.toolbar];
    [actionSheet release];

}
-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    return NO;
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    actionSheetVisible = NO;
    if(buttonIndex == 0)
        [self logout];
    else if(buttonIndex == 1){
        ChangePasswordViewController *vc = [[ChangePasswordViewController alloc] init];
        //vc.modalInPopover = YES;
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
        nc.navigationBar.tintColor = kDefaultToolbarColor;
        nc.modalInPopover = YES;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            UIPopoverController *pc = [[UIPopoverController alloc] initWithContentViewController:nc];
            pc.delegate = self;
            [pc presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            self.activePopover = pc;
            [pc release];
            
        }
        else
            [self.navigationController presentViewController:nc animated:YES completion:nil];
        [vc release];
        [nc release];
    }
    else if(buttonIndex == 2){
        ELAppDelegate *delegate = [ELAppDelegate sharedDelegate];
        [delegate checkForUpdates:YES];
    }
}
-(void)otherAssignment{
    SelectObjectViewController *vc = [[SelectObjectViewController alloc] initWithPastAssignments:unsortedAssignments];
    vc.studentID = student.object_id;
    vc.studentBased = YES;
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
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
            pc.delegate = self;
            
            
            self.activePopover = pc;
            [pc presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            [pc release];
        }
    }
    [nc release];

    
}
-(void)receivedNotification:(NSNotification*)notif{
    if([notif.name isEqualToString:THIRTYSIX_ED_DID_ADD_ASSIGNMENT]){
        refreshDataOnNextAppearance = YES;
    }
    else if([notif.name isEqualToString:MC_GRADES_SHOULD_DISMISS_POPOVER]){
        [activePopover dismissPopoverAnimated:YES];
        self.activePopover = nil;
    }
    else if([notif.name isEqualToString:DID_COMPLETE_UPLOADING_FALLBACKS]){
        refreshDataOnNextAppearance = YES;
        self.unuploadedTests = nil;
        [self.tableView reloadData];
    }
    else{
        NSArray *filtered = [unsortedAssignments filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %@",[notif.userInfo valueForKey:@"id"]]];
        self.sortedSections = nil;
        if([notif.name isEqualToString:THIRTY_SIX_DID_COMPLETE_ASSIGNMENT]){
            
            
            
            [unsortedAssignments removeObjectsInArray:filtered];
            
        }
        else if([notif.name isEqualToString:THIRTY_SIX_ASSIGNMENT_STATUS_DID_CHANGE]){
            NSDictionary *oldObject = [filtered lastObject];
            NSMutableDictionary *assignment = [NSMutableDictionary dictionaryWithDictionary:oldObject];
            [assignment setValue:[NSNumber numberWithBool:NO] forKey:@"editable"];
            NSInteger index = [unsortedAssignments indexOfObject:oldObject];
            if(index != NSNotFound) //student assigned test to himself and started to take it.
                [unsortedAssignments replaceObjectAtIndex:index withObject:assignment];
            
            refreshDataOnNextAppearance = NO;
            
        }
        [activePopover dismissPopoverAnimated:YES];
        self.activePopover = nil;
        [self.tableView reloadData];
    }
}
-(void)logout{
    [TSHTTPRequest logout];
    AppStartViewController *vc = [[AppStartViewController alloc] init];
    [self.navigationController presentViewController:vc animated:YES completion:nil];

    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(unsortedAssignments == nil || refreshDataOnNextAppearance){
        [self reloadTableViewDataSource];
        refreshDataOnNextAppearance = NO;
    }
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait) || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return [self.sortedSections count]+(self.completedUnuploadedTests.count > 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    
    if(self.completedUnuploadedTests.count > 0){
        if(section == 0)
            return 1;
        section--;
    }
    return [[[self.sortedSections objectAtIndex:section] valueForKey:NSARRAY_GROUPING_OBJECTS_STRING] count];
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
    
    HomeworkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[HomeworkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
    }
    NSDictionary *assignment = [self assignmentForIndexPath:indexPath];
    
    
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
    return [GenericTestUploadHTTPRequest testUploadForAssignment:assignmentID uid:student.object_id];
}
-(NSMutableDictionary*)assignmentForIndexPath:(NSIndexPath*)indexPath{
    NSInteger countOfTests = self.completedUnuploadedTests.count;
    NSInteger section = indexPath.section,row = indexPath.row;
    if(countOfTests > 0){
        section--;
    }
        
    return [[[self.sortedSections objectAtIndex:section] valueForKey:NSARRAY_GROUPING_OBJECTS_STRING] objectAtIndex:row];
}
-(NSString*)uniqueURLPath{
    return [NSString stringWithFormat:@"students/%d/hw/",student.object_id];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    CustomizeAssignmentViewController *vc = [[CustomizeAssignmentViewController alloc] init];
    vc.readOnly = YES;
    
    
    
    vc.studentID=student.object_id;
    
    vc.assignment = [self assignmentForIndexPath:indexPath];
    vc.inPopover = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    vc.hashLookupTable = [NSMutableDictionary dictionary];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [vc release];
    nc.modalPresentationStyle = UIModalPresentationFormSheet;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){//present in popover
        UIPopoverController *pc = [[UIPopoverController alloc] initWithContentViewController:nc];
        self.activePopover = pc;
        
        //pc.delegate = self;
        [pc release];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [pc presentPopoverFromRect:CGRectMake(cell.bounds.size.width-35,13,29,29) inView:cell permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else{
        [self presentViewController:nc animated:YES completion:nil];
    }
    //}
    
    
    [nc release];
}
-(void)reloadTableViewDataSource{
    
    __block TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:[self uniqueURLPath]];
    //request.requestContainer = self;
    request.useSVProgressHUD = unsortedAssignments == nil;
    request.cachePolicy = ASIFallbackToCacheIfLoadFailsCachePolicy | ASIAskServerIfModifiedCachePolicy;
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
        self.unsortedAssignments = [NSMutableArray arrayWithArray:[newListarray filteredArrayUsingPredicate:predicate]];
        self.sortedSections = nil;
        [self.tableView reloadData];
        [self doneLoadingTableViewDataWithSuccess:request.didLoadFromWeb];
    };
    request.failedBlock = ^{
        [self doneLoadingTableViewDataWithSuccess:NO];
    };
    [request startAsynchronous];


    
    
    //NSLog(@"%@",url);
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger countOfTests = self.completedUnuploadedTests.count;
    
    if(countOfTests > 0 ||  self.incompleteUnuploadedTests.count > 0){
        //present WEPopover of viewcontroller here
        UnuploadedTestsViewController *vc3 = [[UnuploadedTestsViewController alloc] initWithUID:student.object_id];
       
        
        UINavigationController *container = [[UINavigationController alloc] initWithRootViewController:vc3];
        container.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:container animated:YES completion:nil];
        [container release];
        [vc3 release];
        
    }
    else{
    
    
        NSDictionary *assignment = [self assignmentForIndexPath:indexPath];
        

        AssignmentInfoViewController *vc = [[AssignmentInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
        vc.activeAssignment = (NSMutableDictionary*)assignment;
        vc.studentBasedView = YES;
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

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation{
    return YES;
}
@end
