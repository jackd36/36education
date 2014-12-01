//
//  StudentAdminViewController.m
//  MC HW
//
//  Created by Eric Lubin on 1/17/13.
//
//

#import "StudentAdminViewController.h"
#import "NSArray+Grouping.h"
#import "HighlightableAttributedTextTableViewCell.h"
#import "EditStudentViewController.h"
#import "ThirtySixTutorStudentPickerViewController.h"
@interface StudentAdminViewController ()
@property (nonatomic,strong) NSMutableArray *studentsBySection;
@property (nonatomic,strong) NSArray *filteredStudentsBySection;
@property (nonatomic,strong) NSMutableArray *allStudents;
@property (nonatomic,strong) NSArray *allTutors;
@property (nonatomic,strong) NSArray *allLocations;
@property (nonatomic,strong) NSMutableArray *lastnameIndices;
@property (nonatomic,strong) NSArray *extendedTimeOptions;
@property (nonatomic,strong) NSIndexPath *selectedIndexPath;
@property (nonatomic,strong) UISearchDisplayController *searchDisplay;
@property (nonatomic,strong) NSMutableDictionary *selectedStudent;
@property (nonatomic,strong) UIPopoverController *activePopover;
@end
NSString * const UPDATE_STUDENTS_LIST_NOTIFICATION = @"UPDATE_STUDENTS_LIST_NOTIFICATIONSLKJLAKDSDJLK";
@implementation StudentAdminViewController

- (id)init
{
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        // Custom initialization
    }
    return self;
}

-(void)addNewUser:(UIBarButtonItem*)button{
    if(self.activePopover != nil)
        return;
    
    EditStudentViewController *vc = [[EditStudentViewController alloc] initWithStudent:nil timeOptions:self.extendedTimeOptions allLocations:self.allLocations allTutors:self.allTutors];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        UIPopoverController *pc = [[UIPopoverController alloc] initWithContentViewController:nc];
        self.activePopover = pc;
        pc.delegate = self;
        //pc.delegate = vc;
        
        [pc presentPopoverFromBarButtonItem:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
        [self presentViewController:nc animated:YES completion:nil];
}

-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    return NO;
}
-(void)dismissView{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self.delegate updateUserDataFromNotifications];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!self.tutor.isAdmin && !self.tutor.isStaff){
        [NSException raise:@"The current user does not have permission to view this page" format:nil];
    }
    self.navigationItem.title = @"Student Admin";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewUser:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    //if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissView)];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    CGFloat searchBarHeight =44;
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,0,searchBarHeight)];
    
    
    searchBar.scopeButtonTitles = nil;
    
    searchBar.selectedScopeButtonIndex  = 3;
    UISearchDisplayController *searchDisplay =[[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplay.searchResultsDelegate = self;
    searchDisplay.searchResultsDataSource = self;
    searchDisplay.delegate = self;
    self.searchDisplay = searchDisplay;
    //self.searchBar = searchBar;
    //searchBar.delegate = self;
    //[self.tableView addSubview:searchBar];
    searchBar.tintColor = nil;
    self.tableView.tableHeaderView = searchBar;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:ADDED_NEW_STUDENT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popoverWasDismissed) name:POPOVER_NEEDS_DISMISSING object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldDismissPopover) name:SHOULD_DISMISS_POPOVER_FOR_STUDENTS_NOTIFICATION object:nil];
    [self reloadTableViewDataSource];
}
-(void)shouldDismissPopover{
    [self.activePopover dismissPopoverAnimated:YES];
    self.activePopover = nil;
}

-(void)popoverWasDismissed{
    self.activePopover = nil;
    UITableView *tableView = nil;
    if([self.searchDisplay isActive]){
        tableView = self.searchDisplay.searchResultsTableView;
    }
    else
        tableView = self.tableView;
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}
-(void)receivedNotification:(NSNotification*)notification{
    NSMutableDictionary *newStudent = (NSMutableDictionary*)notification.userInfo;

    
    NSComparator comparator = ^(NSDictionary *obj1, NSDictionary *obj2) {
        NSComparisonResult result = [obj1[@"last"] compare:obj2[@"last"]];
        if(result != NSOrderedSame)
            return result;
        else{
            return [obj1[@"first"] compare:obj2[@"first"]];
        }
    };
    
    NSInteger desiredLocation = [self.allStudents indexOfObject:newStudent inSortedRange:NSMakeRange(0, [self.allStudents count]) options:NSBinarySearchingInsertionIndex usingComparator:comparator];
    
    [self.allStudents insertObject:newStudent atIndex:desiredLocation];
    
    NSComparator compareFirstLetter = ^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        return [obj1[NSARRAY_GROUPING_SECTION_TITLE_STRING] compare:obj2[NSARRAY_GROUPING_SECTION_TITLE_STRING]];
    };
    NSDictionary *target = @{NSARRAY_GROUPING_SECTION_TITLE_STRING:[[newStudent[@"last"] substringWithRange:NSMakeRange(0, 1)] uppercaseString]};
    NSInteger indexOfLetter = [self.studentsBySection indexOfObject:target  inSortedRange:NSMakeRange(0, [self.studentsBySection count]) options:NSBinarySearchingInsertionIndex usingComparator:compareFirstLetter];
    
    
    
    if(indexOfLetter < [self.studentsBySection count] && compareFirstLetter(self.studentsBySection[indexOfLetter],target) == NSOrderedSame){
        //add to array
        NSMutableArray *subStudents = self.studentsBySection[indexOfLetter][NSARRAY_GROUPING_OBJECTS_STRING];
        NSInteger indexInSection = [subStudents indexOfObject:newStudent inSortedRange:NSMakeRange(0, [subStudents count]) options:NSBinarySearchingInsertionIndex usingComparator:comparator];
        
        [subStudents insertObject:newStudent atIndex:indexInSection];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexInSection inSection:indexOfLetter]] withRowAnimation:UITableViewRowAnimationNone];
         
    }
    else{
        //create new section
        
        NSDictionary *newSection = @{NSARRAY_GROUPING_SECTION_TITLE_STRING:target[NSARRAY_GROUPING_SECTION_TITLE_STRING],NSARRAY_GROUPING_OBJECTS_STRING:@[newStudent]};
        [self.studentsBySection insertObject:newSection atIndex:indexOfLetter];
        [self.lastnameIndices insertObject:newSection[NSARRAY_GROUPING_SECTION_TITLE_STRING] atIndex:indexOfLetter+1]; //+1 because there is a search element at index 0
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:indexOfLetter] withRowAnimation:UITableViewRowAnimationNone];
        
        [self.tableView reloadSectionIndexTitles];
    }
    
    
    [self sendNotificationToStudentListingPage];

}


-(void)sendNotificationToStudentListingPage{
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_STUDENTS_LIST_NOTIFICATION object:nil userInfo:@{@"students":self.allStudents}];

}
-(void)customizeRequest:(TSHTTPRequest *)request{
    request.useSVProgressHUD = self.studentsBySection == nil;
}


-(void)viewWillAppear:(BOOL)animated{
    
    
    [super viewWillAppear:animated];
    if(self.selectedStudent != nil){
        [self.selectedStudent removeObserver:self forKeyPath:@"name"];
        self.selectedStudent = nil;
    }
}

-(void)requestCompleted:(id)jsonValue{
    NSDictionary *info = jsonValue;
    NSArray *sortByName = @[[NSSortDescriptor sortDescriptorWithKey:@"last" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"first" ascending:YES]];
    
    
    
    NSArray *allStudents = [info[@"list"] sortedArrayUsingDescriptors:sortByName];
    
    self.allStudents = [NSMutableArray arrayWithCapacity:[allStudents count]];
    
    for(NSDictionary *student in allStudents){
        [self.allStudents addObject:[student mutableCopy]];
    }
    
    self.studentsBySection = [self.allStudents groupUsingBlock:^NSString *(NSDictionary *object) {
        return [[object[@"last"] substringToIndex:1] uppercaseString];
    }];
    
    self.lastnameIndices = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
    [self.lastnameIndices addObjectsFromArray:[self.studentsBySection valueForKey:NSARRAY_GROUPING_SECTION_TITLE_STRING]];
    
    self.extendedTimeOptions = info[@"time_options"];
    self.filteredStudentsBySection = nil;
    self.allTutors = [info[@"tutors"] sortedArrayUsingDescriptors:sortByName];
    self.allLocations = [info[@"locations"] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if(tableView == self.tableView){
        return self.lastnameIndices;
    }
    return nil;
}
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    
    if(index == 0){
        [self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top)];
        return NSNotFound;
    }
    else{
        return index-1;
    }
    
}


-(NSString*)uniqueURLPath{
    return @"students_by_location/all/";
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return [[self appropriateArrayForTableView:tableView] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return [[self appropriateArrayForTableView:tableView][section][NSARRAY_GROUPING_OBJECTS_STRING] count];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

    
    return [self appropriateArrayForTableView:tableView][section][NSARRAY_GROUPING_SECTION_TITLE_STRING];
}

-(NSArray*)appropriateArrayForTableView:(UITableView*)tableView{
    if(tableView == self.tableView)
        return self.studentsBySection;
    else
        return self.filteredStudentsBySection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    HighlightableAttributedTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")){
        if(cell == nil)
            cell = [[HighlightableAttributedTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    else{
        
        if(cell == nil){
            cell = (HighlightableAttributedTextTableViewCell*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    

    NSDictionary *student = [self studentFromTableView:tableView indexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    
    cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    
    cell.textLabel.textColor= [self textColorFromStudent:student];
    
    NSString *name = [NSString stringWithFormat:@"%@ %@",student[@"first"],student[@"last"]];
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")){
        NSMutableAttributedString *label = [[NSMutableAttributedString alloc] initWithString:name];
        [label addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.0]} range:NSMakeRange(0,[student[@"first"] length])];
        [label addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18.0]} range:NSMakeRange([student[@"first"] length], [student[@"last"] length]+1)];
       
        //[label addAttributes:@{NSForegroundColorAttributeName:[self textColorFromStudent:student]} range:NSMakeRange(0, [name length])];
        
        cell.textLabel.attributedText = label;
    }
    else{
        cell.textLabel.text = name;
        
    }
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")){
        
        [cell setUnhighlightedTextColor:cell.textLabel.textColor];
        //cell.unhighlightedTextColor = cell.textLabel.textColor;
    }
    // Configure the cell...
    
    return cell;
}
-(UIColor*)textColorFromStudent:(NSDictionary*)student{
    if([student[@"active"] boolValue]){
        return [UIColor blackColor];
    }
    else{
        return [UIColor lightGrayColor];
    }
}



-(NSMutableDictionary*)studentFromTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath{
    return [self appropriateArrayForTableView:tableView][indexPath.section][NSARRAY_GROUPING_OBJECTS_STRING][indexPath.row];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/
-(void)activateStudentInTableView:(UITableView*)tableView AtIndexPath:(NSIndexPath*)indexPath  active:(BOOL)active{
    NSMutableDictionary *student = [self studentFromTableView:tableView indexPath:indexPath];
    
    TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:[NSString stringWithFormat:@"students_by_location/%@/set_active/",student[@"id"]]];
    request.useSVProgressHUD = YES;
    NSString *isActive = [NSString stringWithFormat:@"%d",active];
    
    [request addPostValue:isActive forKey:@"active"];
    request.progressMaskType = SVProgressHUDMaskTypeClear;
    //request.progressFailureText = @"Unable to deactivate user. Please check your connection and try again later.";
    request.completionBlock = ^{
        student[@"active"] = @(active);
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self sendNotificationToStudentListingPage];
    };
    
    [request startAsynchronous];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self activateStudentInTableView:tableView AtIndexPath:indexPath active:NO];
        
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

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    
    if(![change[NSKeyValueChangeOldKey] isEqualToString:change[NSKeyValueChangeNewKey]]){
        
        UITableView *tableView = nil;
        UITableView *otherTableView = nil;
        if([self.searchDisplay isActive]){
            tableView = self.searchDisplay.searchResultsTableView;
            otherTableView = self.tableView;
        }
        else {
            tableView = self.tableView;
            otherTableView = self.searchDisplay.searchResultsTableView;
            
        }
        
        [tableView reloadRowsAtIndexPaths:@[[tableView indexPathForSelectedRow]] withRowAnimation:UITableViewRowAnimationNone];
        
        
        //find selectedstudent in other tableview and reload
        [otherTableView reloadRowsAtIndexPaths:[otherTableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
        [self sendNotificationToStudentListingPage];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *student =  [self studentFromTableView:tableView indexPath:indexPath];
    if(![student[@"active"] boolValue]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Inactive User" message:@"The user you are trying to edit is currently inactive. What would you like to do?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Activate", nil];
//        if(tableView == self.tableView){
//            alert.tag
//        }
        self.selectedIndexPath = indexPath;
        alert.tag = tableView == self.tableView;
        [alert show];
    
    }
    else{
        
        self.selectedStudent = student;
        [self.selectedStudent addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:NULL];
        
        EditStudentViewController *vc = [[EditStudentViewController alloc] initWithStudent:student timeOptions:self.extendedTimeOptions allLocations:self.allLocations allTutors:self.allTutors];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
            UIPopoverController *pc = [[UIPopoverController alloc] initWithContentViewController:nc];
            self.activePopover = pc;
            pc.delegate = vc;
            
            [pc presentPopoverFromRect:[tableView rectForRowAtIndexPath:indexPath] inView:tableView permittedArrowDirections:UIPopoverArrowDirectionAny ^ UIPopoverArrowDirectionUp animated:YES];
            
        }
        else{
            
            
            [self.navigationController pushViewController:vc animated:YES];
        }
    }

}



-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    UITableView *tableView = nil;
    if(alertView.tag == 1){
        tableView = self.tableView;
    }
    else{
        tableView = self.searchDisplay.searchResultsTableView;
    }
    if(buttonIndex == 1){
        [self activateStudentInTableView:tableView AtIndexPath:self.selectedIndexPath active:YES];
    }
    else{
        [tableView deselectRowAtIndexPath:self.selectedIndexPath animated:YES];
    }
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || toInterfaceOrientation == UIInterfaceOrientationPortrait;
}


-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption{
    [self filterContentForSearchText:controller.searchBar.text scope:searchOption];
	
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{

    
	[self filterContentForSearchText:searchString scope:controller.searchBar.selectedScopeButtonIndex];
	
    return YES;
}

-(NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return @"Deactivate";
    
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *student = [self studentFromTableView:tableView indexPath:indexPath];
    return [student[@"active"] boolValue];
}


- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope{

    
//    NSPredicate *predicate = nil;
//    if(scope < 3){
//        if(scope < 2){
//            NSString *searchKey = nil;
//            if (scope == 0){
//                searchKey = @"first_name";
//            }
//            else if(scope == 1){
//                searchKey = @"last_name";
//            }
//            predicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@",searchKey,searchText];
//            
//        }
//        else{
//            predicate = [NSPredicate predicateWithFormat:@"ANY location.name contains[cd] %@",searchText];
//            
//        }
//        
//    }
//    else{
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"first_name contains[cd] %@ || last_name contains[cd] %@ || ANY location.name contains[cd] %@",searchText,searchText,searchText];
    //}
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@",searchText];
    self.filteredStudentsBySection = [[self.allStudents filteredArrayUsingPredicate:predicate] groupUsingBlock:^NSString *(NSDictionary *object) {
        return [object[@"last"] substringToIndex:1];
    }];;

}


@end
