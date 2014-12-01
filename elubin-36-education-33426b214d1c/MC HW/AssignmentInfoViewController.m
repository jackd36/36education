//
//  AssignmentInfoViewController.m
//  iSHS
//
//  Created by Eric Lubin on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AssignmentInfoViewController.h"
#import "EditNotesViewController.h"
#import "EditDueDateViewController.h"
#import "NSDate+prettifiedRelativeDateString.h"
#import "EditNotesViewController.h"
#import "SelectObjectViewController.h"

#import "TSTestTakingModel.h"
#import "TSTestAbstractBase.h"
#import "TSPassage.h"
#import "TSSection.h"
#import "TSTest.h"
#import "TestTakingViewController.h"
#import "TestQueueViewController.h"
#import "UIViewController+AttemptLogic.h"
#import "GenericAttemptViewController.h"
#import "NSMutableDictionary+MC_Grades.h"
#import "CustomizeAssignmentViewController.h"
#import "JSONToObjC.h"
NSString * const  THIRTYSIX_ED_DID_ADD_ASSIGNMENT = @"THIRTYSIX_ED_DID_ADD_ASSIGNMENT";
NSString * const  THIRTYSIX_ED_DID_CHANGE_ASSIGNMENT = @"THIRTYSIX_ED_DID_CHANGE_ASSIGNMENT";
@interface AssignmentInfoViewController ()
-(void)previousPage;
-(void)saveChanges;
-(NSInteger)notesRowNumber;
-(NSInteger)dueDateRowNumber;

@property (nonatomic, getter=isNewAssignment) BOOL newAssignment;
@property (nonatomic,getter=isDirty) BOOL dirtyFlag;

@end

@implementation AssignmentInfoViewController
@synthesize activeAssignment,newAssignment,dirtyFlag,student,studentBasedView,allAssignments;

#pragma mark -
#pragma mark Initialization

-(id)initWithStyle:(UITableViewStyle)style{
    if( self = [super initWithStyle:style]){
        self.contentSizeForViewInPopover = CGSizeMake(320,400);
    }
    return self;
}





#pragma mark -
#pragma mark View lifecycle
-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    return ![self isEditing];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if([self isNewAssignment])
		self.navigationItem.title = @"New";
	else
		self.navigationItem.title =  @"Info";
	self.tableView.allowsSelectionDuringEditing = YES;
    if(IS_IOS_7)
        self.tableView.backgroundColor = kDefaultTableViewBackgroundColor;
    //self.tableView.backgroundColor = kDefaultTableViewBackgroundColor;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	//UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEditing)];
    //self.navigationItem.rightBarButtonItem = edit;
	//[edit release];
    if(activeAssignment == nil){
        self.activeAssignment = [NSMutableDictionary dictionary];
        [activeAssignment setValue:[NSNumber numberWithBool:YES] forKey:@"editable"];
        [activeAssignment setValue:[NSNumber numberWithBool:NO] forKey:@"completed"];
        [activeAssignment setValue:[NSNumber numberWithBool:YES] forKey:@"timed"];
        newAssignment= YES;
    }
	if([self isNewAssignment]){
		UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(previousPage)];
		UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveChanges)];
		//discard changes uiactionsheet
		rightButton.enabled = NO;
		self.navigationItem.leftBarButtonItem = leftButton;
		self.navigationItem.rightBarButtonItem = rightButton;
		[leftButton release];
		[rightButton release];
        self.editing = YES;
	}
    else{
        if(![self isStudentBasedView]){
            self.navigationItem.rightBarButtonItem = self.editButtonItem;
            
        }
        if(![[activeAssignment valueForKey:@"completed"] boolValue]){
            NSString *title = @"Start";
            if(![[activeAssignment valueForKey:@"editable"] boolValue])
                title = @"Continue";
            
            UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 51)];
            UIButtonType btype;
            if(IS_IOS_7)
                btype = UIButtonTypeSystem;
            else
                btype = UIButtonTypeRoundedRect;
            
            UIButton *button = [UIButton buttonWithType:btype];
            button.frame = CGRectMake(10,0,container.frame.size.width-20,51);
            if(!IS_IOS_7){
                [button setBackgroundImage:[UIImage imageNamed:@"glossyButton-normal"] forState:UIControlStateNormal];
                [button setBackgroundImage:[UIImage imageNamed:@"glossyButton-disabled"] forState:UIControlStateDisabled];
                [button setBackgroundImage:[UIImage imageNamed:@"glossyButton-highlighted"] forState:UIControlStateHighlighted];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            } else {
                container.backgroundColor = [UIColor whiteColor];
            }
            [button setTitle:[NSString stringWithFormat:@"%@ Test",title] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
            [button addTarget:self action:@selector(takeTest) forControlEvents:UIControlEventTouchUpInside];
            [container addSubview:button];
            self.tableView.tableFooterView = container;
            [container release];
        }
    
    }
    
    if(!studentBasedView){
        [activeAssignment addObserver:self forKeyPath:@"notes" options:0 context:NULL];
        [activeAssignment addObserver:self forKeyPath:@"due_date" options:0 context:NULL];
        [activeAssignment addObserver:self forKeyPath:@"textLabel" options:0 context:NULL];
        [activeAssignment addObserver:self forKeyPath:@"subset" options:0 context:NULL];
        if(![self isNewAssignment]){
            
        }
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:THIRTY_SIX_DID_COMPLETE_ASSIGNMENT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:THIRTY_SIX_ASSIGNMENT_STATUS_DID_CHANGE object:nil];
    
}
-(void)receivedNotification:(NSNotification*)notif{
    if([notif.name isEqualToString:THIRTY_SIX_DID_COMPLETE_ASSIGNMENT]){
        if([[activeAssignment valueForKey:@"id"] integerValue] == [[notif.userInfo valueForKey:@"id"] integerValue]){
            [activeAssignment setValue:[NSNumber numberWithBool:YES] forKey:@"completed"];
            self.tableView.tableFooterView.hidden = YES;
            [self.tableView reloadData];
        }
            
    }
    else if([notif.name isEqualToString:THIRTY_SIX_ASSIGNMENT_STATUS_DID_CHANGE]){
        [self.navigationController popViewControllerAnimated:NO];
    }
}
-(void)takeTest{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Take Test" message:@"Are you sure you would like to take this test? All your progress will be tracked, so make sure you are in a quiet, test-taking environment." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Take Test",nil];
    [alert show];
    [alert release];
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        __block TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:[NSString stringWithFormat:@"hw/%@/start_or_continue/",[activeAssignment valueForKey:@"id"]]];
        //request.requestContainer = self;
        request.useSVProgressHUD = YES;
        request.responseStringAsErrorMessage = YES;
        request.progressFailureText = @"Connection Error. You will be unable to take this test without a valid internet connection.";
        request.progressMaskType = SVProgressHUDMaskTypeClear;
        request.completionBlock = ^{
            NSDictionary *dict = [[request responseData] JSONValue];
            UIViewController *vc = testTakingViewControllerFromJson(dict,[activeAssignment dictionaryWithValuesForKeys:[NSArray arrayWithObjects:@"textLabel",@"detailTextLabel", nil]]);
            
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
            [vc release];
            
            nc.navigationBar.barStyle = UIBarStyleBlackTranslucent;
            nc.navigationBar.tintColor = nil;
            nc.modalPresentationStyle = UIModalPresentationPageSheet;
            [self presentViewController:nc animated:YES completion:NULL];
            
            [nc release];

        };
        request.failedBlock = ^{
            [self.navigationController popViewControllerAnimated:YES];  
        };
        
        [request startAsynchronous];

    }
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if(object == activeAssignment){
        dirtyFlag = YES;
        if([keyPath isEqualToString:@"textLabel"])
            self.navigationItem.rightBarButtonItem.enabled = YES;
        [self.tableView reloadData];
    }
}
-(void)previousPage {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [[NSNotificationCenter defaultCenter] postNotificationName:MC_GRADES_SHOULD_DISMISS_POPOVER object:nil];
    else
        [self.parentViewController dismissModalViewControllerAnimated:YES];
}
-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    //NSLog(@"%@",activeAssignment);
    if(!editing && [self isDirty]){
        __block TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:[NSString stringWithFormat:@"hw/%@/",[activeAssignment valueForKey:@"id"]]];
        //request.requestContainer = self;
        request.useSVProgressHUD = YES;
        request.cachePolicy = ASIDoNotReadFromCacheCachePolicy | ASIDoNotWriteToCacheCachePolicy;
        request.progressFailureText = [NSString stringWithFormat:@"Oops! It looks like %@ has already started this assignment. You can no longer edit it.",[student valueForKey:@"name"]];
        request.progressMaskType = SVProgressHUDMaskTypeClear;
        [request addPostValue:[[activeAssignment valueForKey:@"content_type"] description] forKey:@"content_type"];
        [request addPostValue:[[activeAssignment valueForKey:@"object_id"] description] forKey:@"object_id"];
        [request addPostValue:[[activeAssignment valueForKey:@"timed"] description] forKey:@"timed"];
        if([activeAssignment valueForKey:@"subset"])
            [request addPostValue:[[activeAssignment valueForKey:@"subset"] JSONRepresentation] forKey:@"subset"];
        
        id dueDate = [activeAssignment valueForKey:@"due_date"];
        if(dueDate != nil && dueDate != [NSNull null]){
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[dueDate intValue]];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateStyle = NSDateFormatterShortStyle;
            [request addPostValue:[df stringFromDate:date] forKey:@"due_date"];
            [df release];
        }
        NSString *notes = [activeAssignment valueForKey:@"notes"];
        if(notes != nil){//cannot be NSNull because db field in django is not nullable
            [request addPostValue:notes forKey:@"notes"];
        }
        request.completionBlock = ^{
            dirtyFlag = NO;
            
            [self setEditing:NO animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:THIRTYSIX_ED_DID_CHANGE_ASSIGNMENT object:nil userInfo:[NSDictionary dictionaryWithObject:activeAssignment forKey:@"assignment"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:MC_GRADES_SHOULD_DISMISS_POPOVER object:nil];
            
        };
        request.failedBlock = ^{
         [self.navigationController popViewControllerAnimated:YES];
        };
        [request startAsynchronous];
        //request.userInfo = indexPath;
        
        
        return;
    }
    self.tableView.tableFooterView.hidden = editing;
    NSInteger notesRowNumberBefore = self.notesRowNumber;
    NSInteger dueDateRowNumberBefore = self.dueDateRowNumber;
    [super setEditing:editing animated:animated];
    NSInteger notesRowNumber = self.notesRowNumber;
    NSInteger dueDateRowNumber = self.dueDateRowNumber;
    if([self isNewAssignment])
        return;
    
    [self.tableView beginUpdates];
    self.navigationItem.hidesBackButton = editing;
    NSMutableArray *insertionsAndDeletions = [NSMutableArray array];
    
    NSMutableArray *reloadPaths = [NSMutableArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],nil];
    if(dueDateRowNumberBefore >0 && dueDateRowNumber > 0)
        [reloadPaths addObject:[NSIndexPath indexPathForRow:dueDateRowNumberBefore inSection:0]];
    else if(dueDateRowNumberBefore < 0 || dueDateRowNumber < 0){
        NSInteger rowNumber = dueDateRowNumberBefore;
        if(editing)
            rowNumber = dueDateRowNumber;
        [insertionsAndDeletions  addObject:[NSIndexPath indexPathForRow:rowNumber inSection:0]];
    }
    
    if(notesRowNumberBefore > 0  && notesRowNumber > 0)
        [reloadPaths addObject:[NSIndexPath indexPathForRow:notesRowNumberBefore inSection:0]];
    else if(notesRowNumberBefore < 0 || notesRowNumber < 0){
        NSInteger rowNumber = notesRowNumberBefore;
        if(editing)
            rowNumber = notesRowNumber;
        [insertionsAndDeletions  addObject:[NSIndexPath indexPathForRow:rowNumber inSection:0]];
    }
    
    
    //[self.tableView reloadRowsAtIndexPaths:reloadPaths withRowAnimation:UITableViewRowAnimationFade];
    if(!editing){
        for(NSIndexPath *path in reloadPaths){
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        //delete potential rows
        if([insertionsAndDeletions count] >0)
            [self.tableView deleteRowsAtIndexPaths:insertionsAndDeletions withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        
//        if([self isDirty]){
//            
//            //post notification here
//        }
//        dirtyFlag = NO;
    }
    else {
        
        for(NSIndexPath *path in reloadPaths){
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];

            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
        if([insertionsAndDeletions count] >0)
            [self.tableView insertRowsAtIndexPaths:insertionsAndDeletions withRowAnimation:UITableViewRowAnimationFade];
        
        
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    if([[activeAssignment valueForKey:@"is_subset"] boolValue] && ENABLE_SUBSET_ASSIGNMENTS){
        UITableViewCell *firstCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        firstCell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
 
    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self timedRowNumber] inSection:0]];
    UISwitch *timedSwitch = (UISwitch*)cell.accessoryView;
    timedSwitch.userInteractionEnabled = editing;
    if(editing){
        timedSwitch.onTintColor = nil;
    }
    else {
        timedSwitch.onTintColor = [UIColor grayColor];
    }
		
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0 && indexPath.section == 0){
        CustomizeAssignmentViewController *vc = [[CustomizeAssignmentViewController alloc] init];
        vc.readOnly = self.studentBasedView || !self.editing;
        
        if(self.editing){
            self.dirtyFlag = YES;
        }
        
        vc.studentID=[student[@"id"] integerValue];
        vc.assignment = activeAssignment;
        vc.hashLookupTable = [NSMutableDictionary dictionary];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
        [vc release];
        nc.modalPresentationStyle = UIModalPresentationFormSheet;
        
//        if(vc.readOnly && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){//present in popover
//            UIPopoverController *pc = [[UIPopoverController alloc] initWithContentViewController:nc];
//            [nc release];
//            [pc presentPopoverFromBarButtonItem:<#(UIBarButtonItem *)#> permittedArrowDirections:<#(UIPopoverArrowDirection)#> animated:<#(BOOL)#>]
//        }
//        else{
        [self presentViewController:nc animated:YES completion:nil];
        //}
        
        
        [nc release];
    }
}
-(void)saveChanges {
	//save notes
	if([self isDirty]){
        //TODODODODODOOD!!!!!!
        
        __block TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:@"hw/add/"];
        //request.requestContainer = self;
        request.useSVProgressHUD = YES;
        request.progressMaskType = SVProgressHUDMaskTypeClear;
        request.cachePolicy = ASIDoNotReadFromCacheCachePolicy | ASIDoNotWriteToCacheCachePolicy;
        [request addPostValue:[[activeAssignment valueForKey:@"content_type"] description] forKey:@"content_type"];
        [request addPostValue:[[activeAssignment valueForKey:@"object_id"] description] forKey:@"object_id"];
        [request addPostValue:[[activeAssignment valueForKey:@"timed"] description] forKey:@"timed"];
        id dueDate = [activeAssignment valueForKey:@"due_date"];
        if(dueDate != nil && dueDate != [NSNull null]){
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[dueDate intValue]];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateStyle = NSDateFormatterShortStyle;
            [request addPostValue:[df stringFromDate:date] forKey:@"due_date"];
            [df release];
        }
        
        if([activeAssignment valueForKey:@"subset"])
            [request addPostValue:[[activeAssignment valueForKey:@"subset"] JSONRepresentation] forKey:@"subset"];
        
        NSString *notes = [activeAssignment valueForKey:@"notes"];
        if(notes != nil){//cannot be NSNull because db field in django is not nullable
            [request addPostValue:notes forKey:@"notes"];
        }
        
        [request addPostValue:[[student valueForKey:@"id"] description] forKey:@"student_id"];
        
        request.completionBlock = ^{
            NSDictionary *dict = [[request responseData] JSONValue];
            [activeAssignment setValue:[dict valueForKey:@"id"] forKey:@"id"];
            [[NSNotificationCenter defaultCenter] postNotificationName:THIRTYSIX_ED_DID_ADD_ASSIGNMENT object:nil userInfo:[NSDictionary dictionaryWithObject:activeAssignment forKey:@"assignment"]];
            
            
            [self previousPage];
        };
        
        [request startAsynchronous];
        
        
        

        
        
        
    }
	
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.rightBarButtonItem.enabled = [[activeAssignment valueForKey:@"editable"] boolValue] && ![[activeAssignment valueForKey:@"completed"] boolValue];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.contentSizeForViewInPopover=self.tableView.contentSize;
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

// Override to allow orientations other than the default portrait orientation.
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = 1;
    if([self isEditing])
        return 1;
    else{
        if(![[activeAssignment valueForKey:@"editable"] boolValue] && ![[activeAssignment valueForKey:@"completed"] boolValue] && ![self isStudentBasedView])
            sections++;
        if(![self isStudentBasedView] && ![[activeAssignment valueForKey:@"completed"] boolValue])
            sections++;
        return sections;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == 0){
        if([self isEditing])
            return 4;
        else{
            NSInteger numRows = 2;
            if([activeAssignment valueForKey:@"due_date"] != [NSNull null] && [activeAssignment valueForKey:@"due_date"] != nil)
                numRows++;
            if(![[activeAssignment valueForKey:@"notes"] isEqualToString:@""] && [activeAssignment valueForKey:@"notes"] != nil)
                numRows++;
            return numRows;
        }
    }
    else{
        return 1;
    }
}
-(NSInteger)notesRowNumber{
    
    if(![self isEditing]){
        //NSLog(@"%@",[activeAssignment valueForKey:@"notes"]);
        if([[activeAssignment valueForKey:@"notes"] isEqualToString:@""] || [activeAssignment valueForKey:@"notes"] == nil){
            return -1;
        }
        else if(self.dueDateRowNumber !=-1){
            return self.dueDateRowNumber+1;
        }
        else
            return 1;
        
    }
    else{
        return self.dueDateRowNumber+1;
    }

}
-(NSInteger)timedRowNumber{
    
    if(self.notesRowNumber != -1)
        return self.notesRowNumber+1;
    if(self.dueDateRowNumber != -1)
        return self.dueDateRowNumber +1;
    return 1;
}
-(NSInteger)dueDateRowNumber{
    if([self isEditing]){
        return 1;
    }
    else{
        if([activeAssignment valueForKey:@"due_date"] == [NSNull null] || [activeAssignment valueForKey:@"due_date"] == nil)
            return -1;
        return 1;
            
    }
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {

	if(indexPath.section == 0 && indexPath.row == [self notesRowNumber]){
		NSString *Text = [activeAssignment valueForKey:@"notes"];
		UIFont *cellFont = [UIFont systemFontOfSize:14.0f];
        CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
		CGSize labelSize = [Text sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
		CGFloat height = labelSize.height +15;
		if(height >=45)
			return height;
	}
    else if(indexPath.section == 0 && indexPath.row == 0){
        return 53;
    }
	return 45;
}
/*
-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if(section == 1 && ![[activeAssignment valueForKey:@"editable"] boolValue]){
        if([self isStudentBasedView])
            return @"Note: You have already begun this assignment.";
        else
            return [NSString stringWithFormat:@"Note: %@ has already begun this assignment.",[student valueForKey:@"name"]];
    }
    return nil;
}*/

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0)
        return @"Assignment";
    else if(section == 1 && ![self isStudentBasedView] && [self numberOfSectionsInTableView:tableView] ==3)
        return @"Attempt";
    else
        return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if(indexPath.section == 0){
			static NSString *CellIdentifier = @"TVCell";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                
			}
            if([tableView isEditing]){
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            }
            else{
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            if(indexPath.row == 0){
                if([[activeAssignment valueForKey:@"is_subset"] boolValue] && ENABLE_SUBSET_ASSIGNMENTS){
                    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
                }
                cell.accessoryView = nil;
                cell.textLabel.numberOfLines = 1;
                if([[activeAssignment valueForKey:@"completed"] boolValue])
                    cell.imageView.image = [UIImage imageNamed:@"checkmark"];
                else
                    cell.imageView.image = [UIImage imageNamed:@"chalkboard"];
                cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0f];
                cell.textLabel.textColor = [UIColor blackColor];
                if([activeAssignment valueForKey:@"textLabel"] == [NSNull null] || [activeAssignment valueForKey:@"textLabel"] == nil){
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    cell.textLabel.text = @"Title";
                }
                else {
                    cell.textLabel.textColor = [UIColor blackColor];
                    cell.textLabel.text = [activeAssignment valueForKey:@"textLabel"];
                    id detailTextLabl = [activeAssignment valueForKey:@"detailTextLabel"];
                    if(detailTextLabl == [NSNull null])
                        detailTextLabl = nil;
                    cell.detailTextLabel.text = detailTextLabl;
                }

            }
            else if(indexPath.row == [self timedRowNumber]){
                cell.detailTextLabel.text = nil;
                cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
                cell.textLabel.text = @"Timed test";
                UISwitch *timedSwitch = [[UISwitch alloc] init];
                cell.accessoryView = timedSwitch;
                timedSwitch.on = [[activeAssignment valueForKey:@"timed"] boolValue];
                [timedSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
                [timedSwitch release];
                cell.imageView.image = [UIImage imageNamed:@"stopwatch"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryView.userInteractionEnabled = [tableView isEditing];
                if(cell.accessoryView.userInteractionEnabled){
                    timedSwitch.onTintColor = nil;
                }
                else {
                    timedSwitch.onTintColor = [UIColor grayColor];
                }
                
            }
            else{
                cell.accessoryView = nil;
                cell.detailTextLabel.text = nil;
                cell.textLabel.font = [UIFont systemFontOfSize:14];
                if(indexPath.row == [self dueDateRowNumber]){
                    cell.textLabel.numberOfLines = 1;
                    cell.imageView.image = [UIImage imageNamed:@"calendar"];
                    if([activeAssignment valueForKey:@"due_date"] == [NSNull null] || [activeAssignment valueForKey:@"due_date"] == nil){
                        cell.textLabel.textColor = [UIColor lightGrayColor];
                        cell.textLabel.text = @"Due Date";
                    }
                    else {
                        
                        NSDate *dueDate = [NSDate dateWithTimeIntervalSince1970:[[activeAssignment valueForKey:@"due_date"] intValue]];
                        cell.textLabel.text = [dueDate dueDateString];
                        NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
                        NSDate *today = [NSDate date];
                        NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
                        today = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:today]];
                        if([dueDate timeIntervalSinceReferenceDate] <= [today timeIntervalSinceReferenceDate])
                            cell.textLabel.textColor = [UIColor colorWithRed:.5 green:.0824 blue:.1137 alpha:1];
                        else
                            cell.textLabel.textColor = [UIColor blackColor];
                    }
                }
                else if(indexPath.row == [self notesRowNumber]){
                    cell.textLabel.numberOfLines = 0;
                    cell.imageView.image = [UIImage imageNamed:@"note"];
                    id notes = [activeAssignment valueForKey:@"notes"];
                    if(notes == [NSNull null] || [notes isEqualToString:@""] || notes == nil){
                        cell.textLabel.textColor = [UIColor lightGrayColor];
                        cell.textLabel.text = @"Notes";
                    }
                    else {
                        cell.textLabel.textColor = [UIColor blackColor];
                        cell.textLabel.text = notes;
                    }
                }
            }

	}
    else if((indexPath.section ==1 && [self numberOfSectionsInTableView:tableView] ==3) || [self isStudentBasedView]){
        static NSString *CellIdentifier2 = @"value2 cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.text = @"View Answers...";
    }
    else{
        static NSString *CellIdentifier2 = @"email Cell2";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier2] autorelease];
            UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width/320*300,44)];
            date.backgroundColor = [UIColor clearColor];
            date.center = CGPointMake(self.view.bounds.size.width/2, 22);
            date.tag = 18;
            date.textAlignment = UITextAlignmentCenter;
            date.highlightedTextColor = [UIColor whiteColor];
            date.font = [UIFont boldSystemFontOfSize:14];
            date.textColor = [UIColor colorWithRed:0.22 green:.33 blue:.53 alpha:1];
            date.text = @"Send Reminder";
            [cell addSubview:date];
            [date release];
        }
        
        return cell;
    }
    

    // Configure the cell...
    
    return cell;
}

-(void)valueChanged:(UISwitch*)value{
    [activeAssignment setValue:[NSNumber numberWithBool:value.on] forKey:@"timed"];
    dirtyFlag = YES;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}



/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 && [self isEditing]){
        if(indexPath.row == self.notesRowNumber){
            EditNotesViewController *vc = [[EditNotesViewController alloc] initWithStyle:UITableViewStyleGrouped];
            vc.assignment = activeAssignment;
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        }
        else if(indexPath.row == self.dueDateRowNumber){
            EditDueDateViewController*vc = [[EditDueDateViewController alloc] initWithStyle:UITableViewStyleGrouped];
            vc.assignment = activeAssignment;
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        }
        else if(indexPath.row == 0){
            SelectObjectViewController *vc =[[SelectObjectViewController alloc] initWithPastAssignments:allAssignments];
            vc.assignment = activeAssignment;
            
            vc.studentID = [[student valueForKey:@"id"] integerValue];
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
            //NSLog(@"%@",student);
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
            nc.modalPresentationStyle = UIModalPresentationFormSheet;
            //nc.navigationBar.tintColor = kDefaultToolbarColor;
            [vc release];
            
            [self presentModalViewController:nc animated:YES];
            [nc release];
        }
    }
    else if(indexPath.section ==1 && [self numberOfSectionsInTableView:tableView] ==3 && ![self isStudentBasedView]){
        
        __block TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:[NSString stringWithFormat:@"hw/%@/attempt_info/",[activeAssignment valueForKey:@"id"]]];
        //request.requestContainer = self;
        request.useSVProgressHUD = YES;
        request.progressMaskType = SVProgressHUDMaskTypeClear;
        request.completionBlock = ^{
            NSDictionary *attemptInfo = [request.responseData JSONValue];
            
            UIViewController *vc = attemptViewControllerForAttempt(attemptInfo);
            //vc.student = [student valueForKey:@"name"];
            [self.navigationController pushViewController:vc animated:YES];
        };
        
        [request startAsynchronous];
    }
    else if(((indexPath.section ==1 || indexPath.section == 0) && [self numberOfSectionsInTableView:tableView] ==3) || (indexPath.section == 0 && [self numberOfSectionsInTableView:tableView] ==2) || [self isStudentBasedView] || [[activeAssignment valueForKey:@"completed"] boolValue])
    {
        return;//all other possibilities   
    }
    else {
            
        
        __block TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:[NSString stringWithFormat:@"hw/%@/email_reminder/",[activeAssignment valueForKey:@"id"]]];
        //request.requestContainer = self;
        request.useSVProgressHUD = YES;
        request.progressMaskType = SVProgressHUDMaskTypeClear;
        request.progressSuccessText = @"Successfully Sent!";
        request.completionBlock = ^{
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
            
        };
        request.failedBlock = ^{
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        };
        [request startAsynchronous];
            
            
//        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
//        controller.navigationBar.tintColor = kDefaultToolbarColor;
//        controller.mailComposeDelegate = self;
//
//        [controller setSubject:[NSString stringWithFormat:@"%@ Homework",[[[NSBundle mainBundle] infoDictionary]  valueForKey:@"CFBundleName"]]];
//        [controller setMessageBody:@"This is a reminder email to do your practice!" isHTML:NO];
//        [self presentModalViewController:controller animated:YES];
//        [controller release];

	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    [self removeKVO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)removeKVO{
    if(!studentBasedView){
        [activeAssignment removeObserver:self forKeyPath:@"notes"];
        [activeAssignment removeObserver:self forKeyPath:@"due_date"];
        
        [activeAssignment removeObserver:self forKeyPath:@"textLabel"];
        [activeAssignment removeObserver:self forKeyPath:@"subset"];
        
    }
}

- (void)dealloc {
    [self removeKVO];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[activeAssignment release];
    [student release];
    [allAssignments release];
    
    
    [super dealloc];
}

@end

