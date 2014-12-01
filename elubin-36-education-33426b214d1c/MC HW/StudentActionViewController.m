//
//  StudentActionViewController.m
//  MC HW
//
//  Created by Eric Lubin on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StudentActionViewController.h"
#import "SORelativeDateTransformer.h"
#import "SVSegmentedControl.h"
#import "AssignHomeworkViewController.h"
#import "StudentPickerView.h"
#import "UIImage+extensions.h"
#import "PassageAttemptTableViewCell.h"
#import "SectionAttemptTableView.h"
#import "TestAttemptTableViewCell.h"
#import "AttemptFilterViewController.h"
#import "UIViewController+AttemptLogic.h"
#import "GenericAttemptViewController.h"
#import "TestTakingViewController.h"
#import "ChangePasswordViewController.h"
#import "StudentPickerViewController.h"
#import "ChangeAnswerViewController.h"
#import "ELMoreTableViewCell.h"
#import "SVProgressHUD.h"
@interface StudentActionViewController()
-(void)reloadTableViewDataSource;
//-(void)showPicker;
@property (nonatomic) BOOL loadedOnceForUser;
@property (nonatomic,strong) id pickerView; //may either be StudentPickerView or StudentPickerViewController
@property (nonatomic,strong) UILabel *filterLabel;
@property (nonatomic,assign) NSDictionary *attemptSelectedForDeletion;


@property (nonatomic,retain) UIPopoverController *activePopover;

@property (nonatomic,strong) NSMutableArray *attempts;

@property (nonatomic) BOOL nextPageAvailable;
@property (nonatomic) NSInteger nextPage;
@property (nonatomic) NSInteger totalNumberOfAttempts;//since we support pagination, not all may be loaded

@end


@implementation StudentActionViewController
@synthesize tutor,student,attempts,pickerView,loadedOnceForUser,nextPageAvailable,nextPage,totalNumberOfAttempts,attemptFilterController,filterLabel,activePopover,attemptSelectedForDeletion;

-(id)init{
    if (self = [super init]){
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        else
            self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        self.attempts = [NSMutableArray array];
        nextPage = 1;
        self.hidesBottomBarWhenPushed = NO;
        //shouldHideToolbar = YES;
        
    }
    return self;
}
- (void)dealloc {
    [student release];
    [tutor release];
    [activePopover release];
    [filterLabel release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [attempts release];
    [attemptFilterController release];
    [pickerView release];
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    self.attemptFilterController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.attempts = nil;
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
-(void)loadView{
    [super loadView];
    
//    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
//    [toolbar setBackgroundImage:[UIImage imageNamed:@"GlossyBarBackgroundSmall"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
//    UIBarButtonItem *homework = [[UIBarButtonItem alloc] initWithTitle:@"Homework" style:UIBarButtonItemStyleBordered target:self action:@selector(assignHW)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    UIBarButtonItem *tag = [[UIBarButtonItem alloc] initWithTitle:@"      Tag      " style:UIBarButtonItemStyleBordered target:self action:nil];
//    UIBarButtonItem *analyze = [[UIBarButtonItem alloc] initWithTitle:@"  Analyze   " style:UIBarButtonItemStyleBordered target:self action:nil];
//    homework.tintColor = [UIColor lightGrayColor];
//    analyze.tintColor = [UIColor lightGrayColor];
//    tag.tintColor = [UIColor lightGrayColor];
//    toolbar.items = @[flexibleSpace,homework,flexibleSpace,tag,flexibleSpace,analyze,flexibleSpace];
    
//    TTButtonBar *bar = [[TTButtonBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
//    TTStyle *style = [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(255, 255, 255) color2:RGBCOLOR(226, 229, 236) next:[TTFourBorderStyle styleWithTop:nil right:nil bottom:RGBCOLOR(185, 188, 193) left:nil width:0.5 next:[TTFourBorderStyle styleWithTop:nil right:nil bottom:RGBCOLOR(200, 203, 209) left:nil width:0.5 next:nil]]];
//    bar.style = style;
//    bar.buttonStyle = @"silverToolbarButton:";
//    [bar addButton:@"Homework" target:self action:@selector(assignHW)];
//    [bar addButton:@"Tag" target:nil action:nil];
//    [bar addButton:@"Analyze" target:self action:nil];

    //[self.view addSubview:bar];
    
//    self.headerView = toolbar;
//    [toolbar release];
//    [homework release];
//    [tag release];
//    [analyze release];
    
    //    UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height-132) style:UITableViewStylePlain];
//    tv.delegate = self;
//    tv.dataSource = self;
//    self.tableView = tv;
//    [self.view addSubview:tv];
    
    
    //UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 44+tv.bounds.size.height, self.view.bounds.size.width, 44)];
    //all passages, sections,test psets
    UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"filter-white"] style:UIBarButtonItemStyleBordered target:self action:@selector(showFilterVC:)] autorelease];
    //SVSegmentedControl *control = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"All",@"Math",@"Science",@"Reading",@"Writing", nil]];
    //create filter view controller, similar to yelp
    //will allow filtering by passage/section/test/pset
    //reading/writing/science/math
    //student/tutor-aided
    //etc
    //control.titleEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 7);
    //control.font = [UIFont boldSystemFontOfSize:11.0f];
    //control.thumb.tintColor =[[UIColor colorWithRed:79.0f/255.0f green:145.0f/255.0f blue:205.0f/255.0f alpha:1.0f] retain];
    //control.tintColor = [UIColor lightGrayColor];
    //control.tintColor = [UIColor grayColor];
   // toolbar.tintColor = kDefaultToolbarColor;
    
    
    
    
    
    
    UILabel *filterUIlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-113, 44)];
    filterUIlabel.textAlignment = UITextAlignmentCenter;
    
    filterUIlabel.backgroundColor = [UIColor clearColor];
    if(IS_IOS_7) {
        filterUIlabel.textColor = kDefaultToolbarColor;
        filterUIlabel.font = [UIFont systemFontOfSize:22.0];
    } else {
        filterUIlabel.textColor = [UIColor whiteColor];
        filterUIlabel.shadowColor = [UIColor colorWithWhite:0 alpha:.5];
        filterUIlabel.shadowOffset = CGSizeMake(0, -1);
        filterUIlabel.font = [UIFont boldSystemFontOfSize:22.0];
    }
    
    
    
    filterUIlabel.adjustsFontSizeToFitWidth = YES;
    
    UIBarButtonItem *filterLabelButton = [[[UIBarButtonItem alloc] initWithCustomView:filterUIlabel] autorelease];
    [filterUIlabel release];
    NSString *buttonTitle = nil;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        buttonTitle = @"Homework";
    }
    else{
        buttonTitle = @"HW";
    }
    
    
    //UIBarButtonItem *hw = [[UIBarButtonItem alloc] initWithTitle:buttonTitle style:UIBarButtonItemStyleBordered target:self action:@selector(assignHW)];
    

    
    self.filterLabel = filterUIlabel;
    self.toolbarItems = [NSArray arrayWithObjects:flexibleSpace,filterLabelButton,flexibleSpace,button,nil];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotif:) name:MC_GRADES_SHOULD_DISMISS_POPOVER object:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotif:) name:THIRTY_SIX_DID_COMPLETE_ASSIGNMENT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotif:) name:THIRTY_SIX_DID_MODIFY_ANSWER object:nil];
    [flexibleSpace release];
    //[hw release];
    //[self.view addSubview:toolbar];
    //[toolbar release];
    //[tv release];
}
-(id)pickerView{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        return [pickerView pickerView];
    }
    else
        return pickerView;
}
-(void)showFilterVC:(UIBarButtonItem*)button{
//    if(student == nil){
//        [self showPicker];
//        return;
//    }
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if([activePopover isPopoverVisible]){
            [activePopover dismissPopoverAnimated:YES];
            self.activePopover = nil;
        }
        else{
            UIPopoverController *pc = [[UIPopoverController alloc] initWithContentViewController:self.attemptFilterController];
            [pc presentPopoverFromBarButtonItem:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            self.activePopover = pc;
            [pc release];
        }
    }
    else{
        if(self.modalViewController){
            [self dismissModalViewControllerAnimated:YES];
        }
        else{
            
            [self presentModalViewController:self.attemptFilterController animated:YES];

            
        }
    }
    
}
-(void)receivedNotif:(NSNotification*)notif{
    if([notif.name isEqualToString:THIRYSIX_DID_CHANGE_FILTER_PARAMS]){
        self.filterLabel.text = [attemptFilterController prettyFilterString];
        //;
        //attemptFilterController.cachedFilterString = [attemptFilterController filterGetRequest];;
        [self reloadTableViewDataSource:YES];
        NSString *key = [NSString stringWithFormat:@"user__%@__FILTERSETTINGS",[student valueForKey:@"id"]];
        [[NSUserDefaults standardUserDefaults] setInteger:attemptFilterController.activeState forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        
    }
    else if([notif.name isEqualToString:THIRTY_SIX_DID_COMPLETE_ASSIGNMENT]){
        [self reloadTableViewDataSource:YES];
    }
    else if([notif.name isEqualToString:MC_GRADES_SHOULD_DISMISS_POPOVER]){
        [activePopover dismissPopoverAnimated:YES];
        self.activePopover = nil;
    }
    else if([notif.name isEqualToString:THIRTY_SIX_DID_MODIFY_ANSWER]){
        [self reloadTableViewDataSource:YES];
    }
}
-(void)assignHW{
//    if(student == nil){
//        [self showPicker];
//        return;
//    }
    AssignHomeworkViewController *assignmentsController  =[[AssignHomeworkViewController alloc] initWithStyle:UITableViewStylePlain];
    
    //assignmentsController.objects = [NSMutableArray arrayWithArray:assignments];
    assignmentsController.student = student;
    assignmentsController.tutor = tutor;
    /*NSArray *contentIDs = [attempts valueForKey:@"content_type"];
    NSArray *objectIDs = [attempts valueForKey:@"object_id"];
    NSMutableArray *atts = [NSMutableArray arrayWithCapacity:[objectIDs count]];
    NSMutableArray *emptyValues = [NSMutableArray arrayWithCapacity:[objectIDs count]];
    for(int x=0;x<[objectIDs count];x++){
        [atts addObject:[NSString stringWithFormat:@"%@__%@",[contentIDs objectAtIndex:x],[objectIDs objectAtIndex:x]]];
        [emptyValues addObject:[[attempts objectAtIndex:x] valueForKey:@"completed"]];
    }
    assignmentsController.attemptIDs = [NSDictionary dictionaryWithObjects:atts forKeys:emptyValues];*/
    [self.navigationController pushViewController:assignmentsController animated:YES];
    [assignmentsController release];
    
}
//-(void)analyzeUser{
//    return;
//    DataTrackerHomeVC *vc = [[DataTrackerHomeVC alloc] init];
//    vc.individualUser = YES;
//    vc.userScope =[NSSet setWithObject:student];
//    
//    [self.navigationController pushViewController:vc animated:YES];
//    [vc release];
//}
-(void)loadFilterPersistentSettings{
    if([student valueForKey:@"id"]){
        //self.filterString = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"user__%@__FILTERSETTINGS",[student valueForKey:@"id"]]];
        self.filterLabel.text = [self.attemptFilterController prettyFilterString];
       
    }
    
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        self.navigationItem.title = @"Homework";
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
    }
    else
        self.navigationItem.title = @"Homework";
    
    self.tableView.rowHeight = 55.0f;

    [self loadFilterPersistentSettings];
    //self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"19-gear" withColor:[UIColor whiteColor]] style:UIBarButtonItemStyleBordered target:self action:@selector(showActionSheet:)] autorelease];
//    
//    [[[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleDone target:self action:@selector(logout)] autorelease];
//    UIBarButtonItem *picker =  [[[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(showPicker)] autorelease];
//
//    self.navigationItem.rightBarButtonItems = @[picker];
//   
//    
//    
//    
//    if (pickerView == nil){
//        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//            pickerView = [[StudentPickerViewController alloc] initWithObjects:tutor.students];
//        else
//            pickerView = [[StudentPickerView alloc] initWithObjects:tutor.students];
//        if(student != nil)
//            [[self pickerView] selectUser:student];
//        [[self pickerView] addTarget:self action:@selector(chooseUser) forControlEvents:UIControlEventValueChanged];
//        /*UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:pickerView action:@selector(resignFirstResponder)];
//        tap.numberOfTapsRequired=1;
//        [self.tableView addGestureRecognizer:tap];
//        [tap release];*/
//    }
//    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}




-(void)showActionSheet:(UIBarButtonItem*)button{
    
    
    
    if([activePopover.contentViewController isKindOfClass:[UINavigationController class]] && [((UINavigationController*)activePopover.contentViewController).topViewController isKindOfClass:[ChangePasswordViewController class]] ){
        return;
    }
    if(actionSheetVisible)
        return;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Log Out" otherButtonTitles:@"Change Password", nil];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [actionSheet showFromBarButtonItem:button animated:YES];
        actionSheetVisible = YES;
    }
    else
        [actionSheet showFromToolbar:self.navigationController.toolbar];
    [actionSheet release];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag == -100){
        if(buttonIndex == 0){
            
            TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:[NSString stringWithFormat:@"attempt/%@/id/%@/remove/",[attemptSelectedForDeletion valueForKey:@"content_type"],[attemptSelectedForDeletion valueForKey:@"attempt_id"]]];
            request.useSVProgressHUD = YES;
            request.progressMaskType = SVProgressHUDMaskTypeClear;
            request.completionBlock = ^{
                NSInteger index = [attempts indexOfObject:attemptSelectedForDeletion];
                [attempts removeObject:attemptSelectedForDeletion];
                totalNumberOfAttempts--;
                attemptSelectedForDeletion = nil;
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:attempts.count inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                
            };
            [request startAsynchronous];
        }
    }
    else{
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
    }
}
-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    return NO;
}

//            __block TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:@"change_password/"];
//            [request addPostValue:[alertView textFieldAtIndex:0].text forKey:@"new_password2"];
//            [request addPostValue:firstChangePasswordInstance forKey:@"new_password1"];
//[request addPostValue:@"old_password" forKey:@"old_password"];
//            request.useSVProgressHUD = YES;
//            request.responseStringAsErrorMessage = YES;
//            request.requestContainer = self;
//            request.cachePolicy = ASIDoNotReadFromCacheCachePolicy | ASIDoNotWriteToCacheCachePolicy;
//            request.progressSuccessText = @"Password successfully changed";
//            request.completionBlock = ^{
//                [request clearSessionCredentials];
//                [TSHTTPRequest removeKeychainCredentials];
//            };
//            [request startAsynchronous];

-(void)logout{
    [TSHTTPRequest logout];
    [self dismissViewControllerAnimated:YES completion:nil];
}


//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    [self showPicker];
//    [super touchesEnded:touches withEvent:event];
//    
//}
//- (void)showPicker{
//    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
//        if(![pickerView isFirstResponder]){
//            if(![pickerView isDescendantOfView:self.view]){
//                
//                
//                [self.view addSubview:pickerView];
//            }
//            //self.view.userInteractionEnabled = NO;
//            self.tableView.userInteractionEnabled = NO;
//            self.headerView.userInteractionEnabled = NO;
//            [pickerView becomeFirstResponder];
//            
//        }
//        else{
//            [pickerView resignFirstResponder];
//            self.tableView.userInteractionEnabled = YES;
//            self.headerView.userInteractionEnabled = YES;
//        }
//    }
//    else{
//        if([activePopover isPopoverVisible] && [((UINavigationController*)activePopover.contentViewController).topViewController isKindOfClass:[StudentPickerViewController class]]){
//            [activePopover dismissPopoverAnimated:YES];
//            self.activePopover = nil;
//        }
//        else{
//            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:pickerView];
//            UIPopoverController *pc = [[UIPopoverController alloc] initWithContentViewController:nc];
//            //pc.delegate = self;
//            [pc presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItems[0] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//            self.activePopover = pc;
//            [nc release];
//            [pc release];
//        }
//    }
//    //self.navigationItem.leftBarButtonItem.enabled = NO;
//    
//}



-(AttemptFilterViewController*)attemptFilterController{
    if (attemptFilterController == nil){
        AttemptFilterViewController *vc = [[AttemptFilterViewController alloc] init];
        vc.oldStateBitMask = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"user__%@__FILTERSETTINGS",[student valueForKey:@"id"]]];
        
        
        attemptFilterController = vc;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotif:) name:THIRYSIX_DID_CHANGE_FILTER_PARAMS object:attemptFilterController];
    }
    return attemptFilterController;
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    self.filterLabel = nil;
    self.pickerView = nil;
    self.activePopover = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
//    if(student == nil)
//        [self showPicker];
//    else{
        //[self loadFilterPersistentSettings];
        if([attempts count] == 0)
            [self reloadTableViewDataSource:YES];
   // }
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
        //shouldHideToolbar = NO;
    
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [attempts count]+nextPageAvailable;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < [attempts count]){
        NSDictionary *attempt = [attempts objectAtIndex:indexPath.row];
        AttemptTableViewCell *cell = nil;
        NSString *type = [attempt valueForKey:@"type"];
        if([type isEqualToString:@"Section"]){
        
            static NSString *CellIdentifier = @"TestSection";
            
            cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[SectionAttemptTableView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
        }
        else if([type isEqualToString:@"Test"]){
            static NSString *CellIdentifierTest = @"Test";
            
            cell = [tv dequeueReusableCellWithIdentifier:CellIdentifierTest];
            if (cell == nil) {
                cell = [[[TestAttemptTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierTest] autorelease];
            }
        }
        else if([type isEqualToString:@"Passage"]){
            static NSString *CellIdentifierPassage = @"Passage";
            cell = [tv dequeueReusableCellWithIdentifier:CellIdentifierPassage];
            if (cell == nil) {
                cell = [[[PassageAttemptTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierPassage] autorelease];
            }
        }
        cell.sectionIsFactoredOut = [self.attemptFilterController isFilteredBySection];
        [cell setAttempt:attempt];
        
        return cell;
    }
    else{
        ELMoreTableViewCell *cell = [[[ELMoreTableViewCell alloc] initWithReuseIdentifier:nil] autorelease];
        
//        TTTableMoreButtonCell *cell = [[[TTTableMoreButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
//        
//        
//        
//        
//        cell.textLabel.textColor = RGBCOLOR(0, 109, 224);
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Showing %d of %d Attempts",[attempts count],totalNumberOfAttempts];
        
        BOOL animating = [ASIHTTPRequest sharedQueue].operationCount >0;
        cell.animating = animating;
//        if(animating){
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        }
//        else {
//            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
//        }
        cell.textLabel.text = @"Load More Attempts...";
        
        return cell;
    }
    // Configure the cell...
    
    
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return indexPath.row < [attempts count];
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSDictionary *attempt =[attempts objectAtIndex:indexPath.row];
        attemptSelectedForDeletion = attempt;
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure? This action cannot be undone." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove" otherButtonTitles:nil];
        sheet.tag = -100;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [sheet showFromRect:[tableView rectForRowAtIndexPath:indexPath] inView:self.tableView animated:YES];
        else{
            [sheet showFromToolbar:self.navigationController.toolbar];
        }
        
        [sheet release];
        
        
        //[sheet sho
        //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    if(indexPath.row < [attempts count]){
        NSDictionary *attempt = [attempts objectAtIndex:indexPath.row];
        UIViewController *vc = attemptViewControllerForAttempt(attempt);
        
        //shouldHideToolbar = ![[attempt valueForKey:@"is_over_time_limit"] boolValue];
        //vc.student = [student valueForKey:@"name"];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    else{
        ELMoreTableViewCell * cell = (ELMoreTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        if(!cell.animating){
            cell.animating = YES;
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [self reloadTableViewDataSource:NO];
        }

        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void) reloadTableViewDataSource:(BOOL)all{
    
//    if(student == nil){
//        //[self showPicker];
//        [self performSelector:@selector(doneLoadingTableViewDataWithSuccess:) withObject:@(NO) afterDelay:0.5];
//        //[self doneLoadingTableViewDataWithSuccess:NO];
//        return;
//        //[NSException raise:NSInvalidArgumentException format:@"student must not be nil"];
//    }
    if(all){
        nextPage = 1;
        //self.attempts = [NSMutableArray array];
    }
    NSString *path = [NSString stringWithFormat:@"students/%@/?page=%d",[student valueForKey:@"id"],nextPage];
    NSString *filterString = [self.attemptFilterController filterGetRequest];
    if([filterString length] > 0)
        path = [path stringByAppendingFormat:@"&%@",filterString];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        path = [path stringByAppendingString:@"&records_per_page=20"];
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && IS_IPHONE_5)
        path = [path stringByAppendingString:@"&records_per_page=15"];
    
    __block TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:path];
    
    //request.requestContainer = self;
    request.useSVProgressHUD = !loadedOnceForUser;
    //request.userInfo = [NSDictionary dictionaryWithObject:attempts forKey:@"attempts"];
    request.cachePolicy = ASIFallbackToCacheIfLoadFailsCachePolicy | ASIAskServerIfModifiedCachePolicy;
    request.completionBlock = ^{
        NSDictionary *dict = [request.responseData JSONValue];
        [super doneLoadingTableViewDataWithSuccess:request.didLoadFromWeb];
        loadedOnceForUser = YES;
        NSArray *currentAddition = [dict valueForKey:@"recents"];
        BOOL before = nextPageAvailable;
        nextPageAvailable = [[dict valueForKey:@"has_next"] boolValue];
        totalNumberOfAttempts = [[dict valueForKey:@"num_attempts"] integerValue];
        nextPage++;
        if(all){
            self.attempts = [NSMutableArray array];
        }
        
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:[currentAddition count]];
        for(int x = 0;x<[currentAddition count];x++){
            [indexPaths addObject:[NSIndexPath indexPathForRow:x+[attempts count] inSection:0]];
        }
        
        [attempts addObjectsFromArray:currentAddition];  
        
        
        if(all){
            
            [self.tableView reloadData];
            if(!IS_IOS_7)
                [self.tableView setContentOffset:CGPointZero animated:NO];
        }
        else{
            [self.tableView beginUpdates];
            
           
            if(before != nextPageAvailable){
                
                if(!nextPageAvailable){
                    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[attempts count]-[indexPaths count] inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                }
                else{
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[attempts count] inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                }
            }
            else if(nextPageAvailable){
                //update more button cell, same rule applies, reloads occur before insertions
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[attempts count]-[indexPaths count] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
            ///NOTE: because of the way UITableView runs its grouped updates, it does deletions THEN insertions, regardless of the actual order that you execute them
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            
        }
        
        
        //self.assignments = [dict valueForKey:@"assignments"];
        //[self.tableView reloadData];
    };
    request.failedBlock = ^{
        [self doneLoadingTableViewDataWithSuccess:NO];
    };
    
    [request startAsynchronous];

}
-(void)reloadTableViewDataSource{
    [self reloadTableViewDataSource:YES];
}

@end
