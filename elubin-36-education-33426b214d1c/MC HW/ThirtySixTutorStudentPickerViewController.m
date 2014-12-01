//
//  ThirtySixTutorStudentPickerViewController.m
//  MC HW
//
//  Created by Eric Lubin on 10/23/12.
//
//

#import "ThirtySixTutorStudentPickerViewController.h"
#import "HighlightableAttributedTextTableViewCell.h"
#import "StudentAdminViewController.h"
//#import "EditStudentViewController.h"
#import "NSArray+Grouping.h"
#import "NSDictionary+KeyConversion.h"

@interface ThirtySixTutorStudentPickerViewController ()
//@property NSIndexPath *selectedStudent;

@property (nonatomic,strong) NSArray *studentSubset;
@property (nonatomic,strong) NSArray *lastnameindices;
@property (nonatomic) BOOL showInactive;
@property (nonatomic, strong) UILabel *studentNameInToolbarLabel;
@property (nonatomic, strong) UIBarButtonItem *studentNameNew;
//@property (nonatomic,strong) UISearchBar *searchBar;
@property (nonatomic,strong) NSArray *filteredStudents;
@property (nonatomic,strong) UISearchDisplayController *searchDisplay;
@property (nonatomic,strong) StudentAdminViewController *studentAdminViewController;
@property (nonatomic,strong) NSArray *groupedStudentsFromAdmin;


@end
NSString * const DID_CHANGE_STUDENT_SELECTION = @"DID_CHANGE_STUDENT_SELECTION";
NSString * const DID_LOAD_CACHED_STUDENT_IPAD = @"DID_LOAD_CACHED_STUDENT_IPAD";
NSString * const NEEDS_MORE_SCREEN_REAL_ESTATE  = @"NEEDS_MORE_SCREEN_REAL_ESTATE";
NSString * const NEEDS_LESS_SCREEN_REAL_ESTATE  = @"NEEDS_LESS_SCREEN_REAL_ESTATE";
NSString * const NEEDS_NO_SCREEN_REAL_ESTATE  = @"NEEDS_NO_SCREEN_REAL_ESTATE"; //used when selection is completed and we want to hide the student selection
NSInteger const minimumNumberOfLastNameLettersToShowIndex = 6;
@implementation ThirtySixTutorStudentPickerViewController

- (id)init
{
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
        _selectedStudentID = NSNotFound;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:DID_LOAD_CACHED_STUDENT_IPAD object:nil];
            
        }
        
        // Custom initialization
    }
    return self;
}
-(BOOL)largeEnoughToSearch{
    return [self.lastnameindices count]-[self containsSearchBar] >= minimumNumberOfLastNameLettersToShowIndex;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if(tableView == self.tableView && [self largeEnoughToSearch])
        return self.lastnameindices;
    else 
        return nil;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

-(StudentAdminViewController*)studentAdminViewController{
    if(_studentAdminViewController == nil){
        StudentAdminViewController *vc = [[StudentAdminViewController alloc] init];
        vc.tutor = self.tutor;
        vc.delegate = self;
        _studentAdminViewController = vc;
    }
    return _studentAdminViewController;
}

-(void)receivedNotification:(NSNotification*)notif{
    if([notif.name isEqualToString:DID_LOAD_CACHED_STUDENT_IPAD]){
        self.selectedStudentID = [notif.userInfo[@"id"] integerValue];
        if(_selectedStudentID == NSNotFound)
            return;
        [_studentSubset enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            if([obj[@"id"] integerValue] == self.selectedStudentID){
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                self.studentTitle = obj[@"name"];
                *stop = YES;
            }
        }];
        //[self.tableView reloadData];
        [self scrollToSelectedUser:NO];
        
    }
    else if([notif.name isEqualToString:UPDATE_STUDENTS_LIST_NOTIFICATION]){////[notif.name isEqualToString:ADDED_NEW_STUDENT_NOTIFICATION]){
        
        self.groupedStudentsFromAdmin =  notif.userInfo[@"students"];
        
    }
}

-(void)setAllStudents:(NSArray*)students{
    self.tutor.students = students;
}

-(NSArray*)allStudents{
    return self.tutor.students;
}



-(void)convertNotificationArray{
    NSArray *groupedStudents = self.groupedStudentsFromAdmin;
    if(groupedStudents == nil)
        return;
    
    //NSArray *ungrouped = [groupedStudents ungroupArray];
    NSArray *studentsForCurrentTutor = [groupedStudents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY tutors.pk == %d",self.tutor.object_id]]; // only pick students that the current tutor has been assigned to
    
    NSMutableArray *newAllStudents = [NSMutableArray arrayWithCapacity:[studentsForCurrentTutor count]];
    for(NSDictionary *student in studentsForCurrentTutor){
        NSDictionary *newStudent = [student dictionaryWithValuesForKeys:@[@"first",@"last",@"name",@"id",@"active"]];
        [newAllStudents addObject:newStudent];
    }
    
    self.allStudents = newAllStudents;
    [self reloadStudentDataArray];
    
    [self createLastNameIndices];
    
    
    [self.tableView reloadData];
    [self.tableView reloadSectionIndexTitles];
    self.groupedStudentsFromAdmin = nil;
    
    //now we make sure that the currently selected student was not affected, and if it was we update accordingly.
    
    
    [self reconfigureToolbar:YES animated:NO];

    NSDictionary *student = [[_tutor.students filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id = %d && active = %@",self.selectedStudentID,@YES]] lastObject];
    
    if(student == nil){
        //old selected student is no more
        student = [self.tutor firstActiveStudent];
        

    }
    self.selectedStudentID = [student[@"id"] integerValue];
    self.studentTitle = student[@"name"];
    [[NSNotificationCenter defaultCenter] postNotificationName:DID_CHANGE_STUDENT_SELECTION object:nil userInfo:@{@"id":@(self.selectedStudentID)}];
    
}



-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    
    if([self containsSearchBar] && index == 0){
        [self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top)];
    }
    else{
        NSString *letter = self.lastnameindices[index];
        
        //TODO: find first occurence of student that has a last name that starts with this. Scroll to the row in quesiton.
        [_studentSubset enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            if([[obj[@"last"] substringWithRange:NSMakeRange(0, 1)] isEqualToString:letter]){
                [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                *stop = YES;
            }
        }];
    }
    return NSNotFound;
}

-(BOOL)containsSearchBar{
    return YES;
}

-(void)createLastNameIndices{
    NSMutableSet *lastnames = [NSMutableSet set];
    for(NSDictionary *student in self.studentSubset){
        NSString *letter = [[student[@"last"] substringToIndex:1] capitalizedString];
        [lastnames addObject:letter];
    }
   
    NSArray *lastNameIndices = [lastnames sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES]]];
    if([self containsSearchBar])
        self.lastnameindices =  [@[UITableViewIndexSearch] arrayByAddingObjectsFromArray:lastNameIndices];
    else{
        self.lastnameindices = lastNameIndices;
    }
    
    
}

-(void)reloadStudentDataArray{
    if(_showInactive){
        self.studentSubset = self.allStudents;
    }
    else{
        self.studentSubset = [self studentSubsetWithActive:YES];
    }
}

-(NSArray*)studentSubsetWithActive:(BOOL)active{
    return [self.allStudents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"active == %@",@(active)]];
}

-(BOOL)anyInactiveStudents{
    return [[self studentSubsetWithActive:NO] count] > 0;
}


-(void)viewDidUnload{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if(self.tutor.isStaff){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:UPDATE_STUDENTS_LIST_NOTIFICATION object:nil];
    }
    //self.allStudents = @[@{@"first":@"Eric",@"last":@"Lubin",@"id":@(12),@"active":@(YES)},@{@"first":@"Alexei",@"last":@"Lubchanski",@"id":@(11),@"active":@(NO)}];
    
    
    [self reloadStudentDataArray];
    [self createLastNameIndices];
    //
    self.navigationController.toolbarHidden = NO;
    self.navigationItem.title = @"Select a Student";
    
    if([self containsSearchBar] && [self largeEnoughToSearch]){
        CGFloat searchBarHeight =44;
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,0,searchBarHeight)];
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
        
        //self.tableView.contentInset = UIEdgeInsetsMake(searchBarHeight, 0, 0, 0);
    }
    
    [self reconfigureToolbar:YES animated:NO];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissModal)];
    }

    if(self.tutor.isStaff){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(presentEditViewController)];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];

    }
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)setViewActive:(BOOL)active animated:(BOOL)animated{
    //this is used to adjust toolbars as needed as the view resizes.
    
    if(!active){
        if(!self.navigationController.navigationBarHidden)
            [self.navigationController setNavigationBarHidden:YES animated:NO];
        
        
        
    }
    else{
        if(self.navigationController.navigationBarHidden)
            [self.navigationController setNavigationBarHidden:NO animated:NO];
        
    }
    [self reconfigureToolbar:active animated:animated];
}

-(void)reconfigureToolbar:(BOOL)active animated:(BOOL)animated{
    
    //there are two possible configurations of the toolbar for the ipad. When the view is inactive. the toolbar will only ever show the text of the selected student
    NSString *buttonLabel = nil;
    NSInteger buttonTag = NSNotFound;
    if(_showInactive){
        buttonLabel = @"Hide Inactive";
        buttonTag = 1;
    }
    else{
        buttonLabel = @"View Inactive";
        buttonTag = 0;
    }
    
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:buttonLabel style:UIBarButtonItemStyleBordered target:self action:@selector(toggleAllStudents:)];
    button.tag = buttonTag;
    
    BOOL inactiveStudents = [self anyInactiveStudents];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        NSString *oldString;
        if(!IS_IOS_7)
            oldString = self.studentNameInToolbarLabel.text;
        else
            oldString = self.studentNameNew.title;
        CGFloat width = [[self.splitViewController valueForKey:@"leftColumnWidth"] floatValue];
        if(inactiveStudents)
            width-=112;
        UIBarButtonItem *title;
        if(!IS_IOS_7){
            UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0,width , 44)];
            UILabel *studentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,width , 44)];
            studentLabel.textAlignment = UITextAlignmentCenter;
            studentLabel.font = [UIFont boldSystemFontOfSize:22.0];
            studentLabel.backgroundColor = [UIColor clearColor];
            studentLabel.textColor = [UIColor whiteColor];
            studentLabel.shadowColor = [UIColor colorWithWhite:0 alpha:.5];
            studentLabel.shadowOffset = CGSizeMake(0, -1);
            studentLabel.adjustsFontSizeToFitWidth = YES;
            [container addSubview:studentLabel];
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCurrentStudent)];
            //gesture.numberOfTapsRequired =2;
            [container addGestureRecognizer:gesture];
            title= [[UIBarButtonItem alloc] initWithCustomView:container];
            self.studentNameInToolbarLabel = studentLabel;
            self.studentNameInToolbarLabel.text = oldString;
        } else {
            title = [[UIBarButtonItem alloc] initWithTitle:oldString style:UIBarButtonItemStylePlain target:self action:@selector(tappedCurrentStudent)];
            self.studentNameNew = title;
            
        }
        
        //[self.navigationController.toolbar addGestureRecognizer:gesture];
        
        if(inactiveStudents && active){
            [self setToolbarItems:@[title,flexibleSpace,button] animated:animated];
        }
        else
            [self setToolbarItems:@[flexibleSpace,title,flexibleSpace] animated:animated];
    }
    else{
        if(inactiveStudents)
            self.toolbarItems = @[button,flexibleSpace];
        //else{
        self.navigationController.toolbarHidden = !inactiveStudents;
        
        
    }
}


-(void)presentEditViewController{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:self.studentAdminViewController];
        nc.modalPresentationStyle = UIModalPresentationFormSheet;
        nc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:nc animated:YES completion:nil];
    }
    else{
        [self.navigationController pushViewController:self.studentAdminViewController animated:YES];
    }
}
-(BOOL)isCollapsed{
    return (IS_IOS_7 && self.view.bounds.size.height == 44) || (!IS_IOS_7 && self.view.bounds.size.height == 0);
}

-(void)tappedCurrentStudent{
    //if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if([self isCollapsed]){
            [self setViewActive:YES animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:NEEDS_LESS_SCREEN_REAL_ESTATE object:self];
            return;
        }
        else{
            [self setViewActive:NO animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:NEEDS_NO_SCREEN_REAL_ESTATE object:self];
        }
    
    
        //[self scrollToSelectedUser:YES];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    
    
    
	[self filterContentForSearchText:searchString scope:[controller.searchBar.scopeButtonTitles objectAtIndex:controller.searchBar.selectedScopeButtonIndex]];
	
    return YES;
}

-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [[NSNotificationCenter defaultCenter] postNotificationName:NEEDS_LESS_SCREEN_REAL_ESTATE object:self];
        [self setViewActive:YES animated:YES];
    }
}

-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [[NSNotificationCenter defaultCenter] postNotificationName:NEEDS_MORE_SCREEN_REAL_ESTATE object:self];
        [self setViewActive:YES animated:YES];
    }
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    
    
    self.filteredStudents = [self.studentSubset filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@",searchText]];
}




-(void)scrollToSelectedUser:(BOOL)animated{
    if(_selectedStudentID != NSNotFound){ //highlight active student
        for(int x=0;x<[_studentSubset count];x++){
            if([_studentSubset[x][@"id"] integerValue] == _selectedStudentID){
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:x inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:animated];
                break;
            }
        }
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self scrollToSelectedUser:NO];
    
    
   
}
-(void)updateUserDataFromNotifications{
    if(self.tutor.isStaff)
        [self convertNotificationArray];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //fixes weird bug with search bar not displaying correctly
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [self largeEnoughToSearch] && (_selectedStudentID == NSNotFound || ([_studentSubset count] > 0 && ([_studentSubset[0][@"id"] integerValue] == _selectedStudentID || [_studentSubset[1][@"id"] integerValue] == _selectedStudentID) ))){
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y+1) animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y-1) animated:YES];
        });
        
    }
}

-(void)dismissModal{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)toggleAllStudents:(UIBarButtonItem*)button{
    if(button.tag == 0){
        button.tag = 1;
        button.title = @"Hide Inactive";
        self.showInactive = YES;
    }
    else{
        button.tag = 0;
        button.title = @"View Inactive";
        self.showInactive = NO;
    }
    
    [self reloadStudentDataArray];
    [self createLastNameIndices];
    [self.tableView reloadData];
    //[self scrollToSelectedUser:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.studentAdminViewController = nil;
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    if(tableView == self.tableView)
        return [_studentSubset count];
    else{
        return [self.filteredStudents count];
    }
}

-(void)setStudentTitle:(NSString*)name{

    if(IS_IOS_7){
        self.studentNameNew.title = name;
    }
    else{
        self.studentNameInToolbarLabel.text = name;
    }
    
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
    NSDictionary *student = nil;
    if(tableView == self.tableView)
        student = _studentSubset[indexPath.row];
    else
        student = _filteredStudents[indexPath.row];
    
    if([student[@"id"] integerValue] == _selectedStudentID){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
            self.studentTitle = student[@"name"];
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if([student[@"active"] boolValue]){
        cell.textLabel.textColor = [UIColor blackColor];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    else{
        cell.textLabel.textColor = [UIColor lightGrayColor];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    
    
    
    NSString *name = [NSString stringWithFormat:@"%@ %@",student[@"first"],student[@"last"]];
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")){
        NSMutableAttributedString *label = [[NSMutableAttributedString alloc] initWithString:name];
        [label addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.0]} range:NSMakeRange(0,[student[@"first"] length])];
        [label addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18.0]} range:NSMakeRange([student[@"first"] length], [student[@"last"] length]+1)];
        
        cell.textLabel.attributedText = label;
    }
    else{
        cell.textLabel.text = name;
    }
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")){
        cell.unhighlightedTextColor = cell.textLabel.textColor;
    }
    // Configure the cell...
    
    return cell;
}

//-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")){
//        HighlightableAttributedTextTableViewCell *cell = (HighlightableAttributedTextTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
//        
//        cell.textLabel.textColor = cell.unhighlightedTextColor;
////        NSDictionary *student = nil;
////        if(indexPath.row >= 0 && indexPath.row < [_studentSubset count])
////            student = _studentSubset[indexPath.row];
////
////        if(student == nil || [student[@"active"] boolValue]){
////            cell.textLabel.textColor = [UIColor blackColor];
////            //cell.selectionStyle = UITableViewCellSelectionStyleBlue;
////        }
////        else{
////            cell.textLabel.textColor = [UIColor lightGrayColor];
////            
////        }
//    }
//}

//-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")){
//        HighlightableAttributedTextTableViewCell *cell = (HighlightableAttributedTextTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
//        
//        cell.textLabel.textColor = cell.unhighlightedTextColor;
//    }
//}
//
//-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")){
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//        cell.textLabel.textColor = [UIColor whiteColor];
//    }
//
//}

//-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")){
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//        cell.textLabel.textColor = [UIColor whiteColor];
//    }
//    return indexPath;
//}
//
//-(NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")){
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//        NSDictionary *student = _studentSubset[indexPath.row];
//        
//        if([student[@"active"] boolValue]){
//            cell.textLabel.textColor = [UIColor blackColor];
//            //cell.selectionStyle = UITableViewCellSelectionStyleBlue;
//        }
//        else{
//            cell.textLabel.textColor = [UIColor lightGrayColor];
//            
//        }
//    }
//    return indexPath;

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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *student = nil;
    if(tableView == self.tableView)
        student = _studentSubset[indexPath.row];
    else
        student = _filteredStudents[indexPath.row];
    
    return [student[@"active"] boolValue];
}
-(NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *student = nil;
    if(tableView == self.tableView)
        student = _studentSubset[indexPath.row];
    else
        student = _filteredStudents[indexPath.row];
    
    if([student[@"active"] boolValue])
        return indexPath;
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    NSDictionary *selectedStudent = nil;
    if(self.tableView == tableView){
        selectedStudent = _studentSubset[indexPath.row];
    }
    else{
        
        selectedStudent = self.filteredStudents[indexPath.row];
        
    }
    if(![selectedStudent[@"active"] boolValue]){
        return;
    }
    NSInteger newValue = [selectedStudent[@"id"] integerValue];
    
    
    if(newValue != _selectedStudentID){
        if(_selectedStudentID != NSNotFound){
            NSInteger index = 0;
            NSIndexPath *selectedStudentMain = nil;
            for(NSDictionary *student in self.studentSubset){
                if([student[@"id"] integerValue] == _selectedStudentID){
                    selectedStudentMain = [NSIndexPath indexPathForRow:index inSection:0];
                    break;
                }
                index++;
            }
            if(selectedStudentMain != nil){
                //uncheck old selection in main tableview
                UITableViewCell *oldCell = [self.tableView cellForRowAtIndexPath:selectedStudentMain];
                oldCell.accessoryType = UITableViewCellAccessoryNone;
            }
            if(self.tableView != tableView){
                //do a similar thing in the search view controller and uncheck if needed
                NSIndexPath *selectedStudentSearch = nil;
                for(NSDictionary *student in self.filteredStudents){
                    if([student[@"id"] integerValue] == _selectedStudentID){
                        selectedStudentSearch = [NSIndexPath indexPathForRow:index inSection:0];
                        break;
                    }
                    index++;
                }
                if(selectedStudentSearch != nil){
                    //uncheck old selection in main tableview
                    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:selectedStudentSearch];
                    oldCell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
            
            
            
        }
        
        //check student that was just selected in the tableview in which it was just selected
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        if(tableView != self.tableView){
            //we now need to also check the student in the maintableview
            NSIndexPath *newSelectedStudentPath = nil;
            NSInteger index = 0;
            for(NSDictionary *student in self.studentSubset){
                if([student[@"id"] integerValue] == newValue){
                    newSelectedStudentPath = [NSIndexPath indexPathForRow:index inSection:0];
                    break;
                }
                index++;
            }
            if(newSelectedStudentPath == nil){
                [NSException raise:@"Un unknown error occured" format:@"We could not find the selected student(%@) in the main table view. This should never happen because the search students are a subset of the entire self.studentSubset",selectedStudent];
                
            }
            else{
                UITableViewCell *oldCell = [self.tableView cellForRowAtIndexPath:newSelectedStudentPath];
                oldCell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        
        
       
        self.selectedStudentID = newValue;
        
        self.studentTitle = selectedStudent[@"name"];
       
        [[NSNotificationCenter defaultCenter] postNotificationName:DID_CHANGE_STUDENT_SELECTION object:nil userInfo:@{@"id":@(self.selectedStudentID)}];
    
    }
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        [self dismissModal];
    }
    else{
        if(self.tableView != tableView){
            [self.searchDisplay setActive:NO animated:YES];
        }
        [self setViewActive:NO animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:NEEDS_NO_SCREEN_REAL_ESTATE object:self];

    }
    
}

-(BOOL)shouldAutorotate{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || toInterfaceOrientation == UIInterfaceOrientationPortrait;
}



@end
