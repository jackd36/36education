//
//  TutorActionsViewController.m
//  MC HW
//
//  Created by Eric Lubin on 10/21/12.
//
//

#import "TutorActionsViewController.h"
#import "UIImage+extensions.h"
#import "StudentActionViewController.h"
#import "AssignHomeworkViewController.h"
#import "ChangePasswordViewController.h"
#import "UISplitViewController+VCSwapping.h"
#import "AppStartViewController.h"
#import "ThirtySixTutorStudentPickerViewController.h"
#import "UIImage+extensions.h"
#import "ACTScoresViewController.h"
#import "ELAppDelegate.h"
#import "StudentAdminViewController.h"
//#import "LeftViewControllerContainerSVC.h"

@interface TutorActionsViewController ()

@property (nonatomic) BOOL actionSheetVisible;
@property (nonatomic,strong) UIPopoverController *activePopover;
@property (nonatomic,strong) NSMutableDictionary *cachedViewControllers;

@end
NSString *const  MC_GRADES_SHOULD_DISMISS_POPOVER = @"DISMISS_POPOVER_NOW";
@implementation TutorActionsViewController
@synthesize actionSheetVisible,activePopover;
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

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if(viewController == self){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self lastSelectedPageKey]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(ThirtySixTutorStudentPickerViewController*)studentPicker{
    if(_studentPicker == nil){
        _studentPicker = [[ThirtySixTutorStudentPickerViewController alloc] init];
        //vc.allStudents = _tutor.students;
        _studentPicker.tutor = _tutor;
        
    }
    _studentPicker.selectedStudentID = [_selectedStudent[@"id"] integerValue];
    return _studentPicker;
}

-(void)receivedNotif:(NSNotification*)notif{
    if([notif.name isEqualToString:MC_GRADES_SHOULD_DISMISS_POPOVER]){
        [activePopover dismissPopoverAnimated:YES];
        self.activePopover = nil;
    }
    else if([notif.name isEqualToString:DID_CHANGE_STUDENT_SELECTION]){
        NSInteger selectedStudentID = [notif.userInfo[@"id"] integerValue];
        [self selectStudent:selectedStudentID];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [self.tableView indexPathForSelectedRow] != nil){
            [self tableView:self.tableView didSelectRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
        }
        
    }
}
-(NSString*)selectedStudentKey{
    return [NSString stringWithFormat:@"selectedStudent__%d",_tutor.object_id];
}
//-(void)chooseUser{
//    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
//        ThirtySixTutorStudentPickerViewController *vc = [[ThirtySixTutorStudentPickerViewController alloc] init];
//        vc.allStudents = _tutor.students;
//    }
//    else{
//        //
//    }
//    
//    NSDictionary *newStudent = [[self pickerView] selectedUser];
//    if([self.student[@"id"] intValue] == [newStudent[@"id"] intValue])
//        return;
//    
//    self.student = newStudent;
//    
//    self.attemptFilterController = nil;
//    filterLabel.text = nil;
//    
//    ((UIBarButtonItem*)self.navigationItem.rightBarButtonItems[0]).title = [student valueForKey:@"name"];
//    loadedOnceForUser= NO;
//    
//    [[NSUserDefaults standardUserDefaults] setObject:student forKey:[self selectedStudentKey]];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    [self reloadTableViewDataSource:YES];
//}

-(BOOL)shouldAutorotate{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || toInterfaceOrientation == UIInterfaceOrientationPortrait;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    self.navigationItem.title = @"36 Education";
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotif:) name:MC_GRADES_SHOULD_DISMISS_POPOVER object:nil];
        
//        UINavigationController *nc = [[UINavigationController alloc] init];
//        [self addChildViewController:nc];
//        self.tableView.tableFooterView = nc.view;
        //nc.view.frame = CGRectMake(0,self.view.height-320,self.view.width,320);
    }
    
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"19-gear" withColor:[UIColor whiteColor]] style:UIBarButtonItemStyleBordered target:self action:@selector(showActionSheet:)];
    
    //self.student = [[NSUserDefaults standardUserDefaults] valueForKey:[self selectedStudentKey]];
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        //self.navigationController.toolbarHidden = NO;
        
        
        UIBarButtonItem *picker =  [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(pickStudents)];
//        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//        self.toolbarItems = @[flexibleSpace,picker];
//        self.hidesBottomBarWhenPushed = YES;
        self.navigationItem.rightBarButtonItem = picker;
    }
    
    

    [self loadCachedStudent];
    NSArray *indices = [[NSUserDefaults standardUserDefaults] objectForKey:[self lastSelectedPageKey]];
    if(indices != nil){
        NSIndexPath *path = [NSIndexPath indexPathForRow:[indices[1] integerValue] inSection:[indices[0] integerValue]];
        [self tableView:self.tableView didSelectRowAtIndexPath:path];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotif:) name:DID_CHANGE_STUDENT_SELECTION object:nil];
    
    
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        NSArray *indices = [[NSUserDefaults standardUserDefaults] objectForKey:[self lastSelectedPageKey]];
        if(indices != nil){
            NSIndexPath *path = [NSIndexPath indexPathForRow:[indices[1] integerValue] inSection:[indices[0] integerValue]];
            [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

-(void)loadCachedStudent{
    
    
    NSNumber *oldSelectedUserObject = [[NSUserDefaults standardUserDefaults] objectForKey:[self selectedStudentKey]];
    NSInteger oldSelectedUser = NSNotFound;
    if(oldSelectedUserObject != nil)
        oldSelectedUser = [oldSelectedUserObject integerValue];
    
    [self selectStudent:oldSelectedUser];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){//student selection viewcontroller has already been loaded at this point, so we need to send a notificaiton
        NSNumber *number = _selectedStudent[@"id"];
        if(number == nil)
            number = @(NSNotFound);
        [[NSNotificationCenter defaultCenter] postNotificationName:DID_LOAD_CACHED_STUDENT_IPAD object:nil userInfo:@{@"id":number}];
        if(oldSelectedUser != NSNotFound){
            [self.studentPicker setViewActive:NO animated:YES];
            //tell the studentPicker that it is no longer needed
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NEEDS_NO_SCREEN_REAL_ESTATE object:_studentPicker];
        }
    }
    
}

-(void)selectStudent:(NSInteger)studentID{
    NSDictionary *student = [[_tutor.students filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id = %d && active = %@",studentID,@YES]] lastObject];
    if(student == nil && [_tutor.students count] > 0){
        student = [self.tutor firstActiveStudent];//TODO: this is wrong. need to select first ACTIVE student
        
        
        
    }
    
    if(student == nil){//invalid integer set and more than one choice
        self.selectedStudent = nil;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self selectedStudentKey]];
        self.navigationItem.rightBarButtonItem.title = @"Select User";
    }
    else{
        self.selectedStudent = student;
        [[NSUserDefaults standardUserDefaults] setInteger:[_selectedStudent[@"id"] integerValue] forKey:[self selectedStudentKey]];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            self.navigationItem.rightBarButtonItem.title = _selectedStudent[@"name"];
        }
        
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.cachedViewControllers = [NSMutableDictionary dictionary];
}
-(void)pickStudents{
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:self.studentPicker];
    [self presentViewController:nc animated:YES completion:nil];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.cachedViewControllers = [NSMutableDictionary dictionary];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidUnload{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;//+[_tutor isStaff];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return 1;
    else if(section == 1)
        return 2;
    else
        return 1;
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
        [actionSheet showInView:self.view];
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
                
                
            }
            else
                [self.navigationController presentViewController:nc animated:YES completion:nil];
            
        }
        else if(buttonIndex == 2){
            ELAppDelegate *delegate = [ELAppDelegate sharedDelegate];
            
            [delegate checkForUpdates:YES];
        }
    
}
-(void)logout{
    [TSHTTPRequest logout];
    
    AppStartViewController *vc = [[AppStartViewController alloc] init];
    [self.navigationController presentViewController:vc animated:YES completion:nil];
    //[self dismissViewControllerAnimated:YES completion:nil];
}
-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    return NO;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
      //  cell.accessoryType = UITableViewCellAccessoryNone;
    //else
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // Configure the cell...
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            cell.imageView.image = [UIImage imageNamed:@"83-calendar"];
            if(!IS_IOS_7)
                cell.imageView.highlightedImage = [UIImage imageNamed:@"83-calendar" withColor:[UIColor whiteColor]];
            cell.textLabel.text = @"Current Assignments";
        }

    }
    else if(indexPath.section == 1){
        if(indexPath.row == 0){
            cell.textLabel.text = @"Homework";
            cell.imageView.image = [UIImage imageNamed:@"33-cabinet"];
            if(!IS_IOS_7)
                cell.imageView.highlightedImage = [UIImage imageNamed:@"33-cabinet" withColor:[UIColor whiteColor]];
        }
        else if (indexPath.row == 1){
            cell.textLabel.text = @"ACTs";
            cell.imageView.image = [UIImage imageNamed:@"108-badge"];
            if(!IS_IOS_7)
                cell.imageView.highlightedImage = [UIImage imageNamed:@"108-badge" withColor:[UIColor whiteColor]];
        }
        else if(indexPath.row == 2){
            cell.textLabel.text = @"Target Scores";
            cell.imageView.image = [UIImage imageNamed:@"13-target"];
            if(!IS_IOS_7)
                cell.imageView.highlightedImage = [UIImage imageNamed:@"13-target" withColor:[UIColor whiteColor]];
        }
    }
    else if(indexPath.section == 3){
        cell.textLabel.text = @"Graphs & aggregation";
        cell.imageView.image = [UIImage imageNamed:@"81-dashboard"];
        if(!IS_IOS_7)
            cell.imageView.highlightedImage = [UIImage imageNamed:@"81-dashboard" withColor:[UIColor whiteColor]];
    }
    else if(indexPath.section == 2){
        cell.textLabel.text = @"Students";
        cell.imageView.image = [UIImage imageNamed:@"112-group"];
        if(!IS_IOS_7)
            cell.imageView.highlightedImage = [UIImage imageNamed:@"112-group" withColor:[UIColor whiteColor]];;
    }


    return cell;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0)
        return nil;
    else if (section == 1)
        return @"Performance";
    else if(section == 3)
        return @"Aggregation";
    else if(section == 2)
        return @"Administration";
    return nil;
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

#pragma mark - Table view delegate





- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    UIViewController *viewController = nil;
    if(self.cachedViewControllers[indexPath] != nil){
        viewController = self.cachedViewControllers[indexPath];
    }
    
    else{
        if(indexPath.section == 0 && indexPath.row == 0){
            AssignHomeworkViewController *vc = [[AssignHomeworkViewController alloc] init];
            vc.tutor = _tutor;
            vc.student = _selectedStudent;
            viewController = vc;
            //[self.navigationController pushViewController:vc animated:YES];
        }
        else if(indexPath.section == 1 && indexPath.row == 1){
            ACTScoresViewController *vc = [[ACTScoresViewController alloc] init];
            vc.studentID = [_selectedStudent[@"id"] integerValue];
            viewController = vc;
        }
        else if(indexPath.section == 1 && indexPath.row == 0){
            StudentActionViewController *vc = [[StudentActionViewController alloc] init];
            vc.tutor = _tutor;
            vc.student = _selectedStudent;
            viewController = vc;
            //[self.navigationController pushViewController:vc animated:YES];
            
        }
//        else if(indexPath.section == 2 && indexPath.row == 0){
//            //this is where the student admin page will go
//            StudentAdminViewController *vc = [[StudentAdminViewController alloc] init];
//            vc.tutor = _tutor;
//            viewController = vc;
//            
//        }
        if(viewController != nil)
            self.cachedViewControllers[indexPath] = viewController;
    }
    //if(viewController != nil){
    [[NSUserDefaults standardUserDefaults] setObject:@[@(indexPath.section),@(indexPath.row)] forKey:[self lastSelectedPageKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        self.splitViewController.detailViewController = viewController;
    }
    else{
        [self.navigationController pushViewController:viewController animated:YES];
    }
    //}
    
    
    
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

-(NSString*)lastSelectedPageKey{
    return [[self class] lastSelectedPageKey:_tutor.object_id];
}
+(NSString*)lastSelectedPageKey:(NSInteger)tutorID{
    return [NSString stringWithFormat:@"selected_page__tutor-%d",tutorID];
}


@end
