//
//  GenericAttemptViewController.m
//  MC HW
//
//  Created by Eric Lubin on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GenericAttemptViewController.h"
#import "AssignmentInfoViewController.h"
#import "GenericAggregationViewController.h"
#import "UIViewController+AttemptLogic.h"
#import "AttemptCell.h"
//#import "ScatterPlotViewController.h"
#import "ChangeAnswerViewController.h"
#import "AttemptTableViewCell.h"
#import "FilterTimeLimitView.h"
#import "ErrorInfoViewController.h"

@interface GenericAttemptViewController ()
@property (nonatomic,strong) NSArray *subListing;
@property (nonatomic,strong) UIPopoverController *activePopover;
@property (nonatomic,retain) UISwitch *enforceTimeLimitSwitch;
@property (nonatomic,retain) WEPopoverController *activeiPhonePopover;
@end

@implementation GenericAttemptViewController
@synthesize objectInfo,subListing,hideAggregationFeature,subListingCellClassName,activePopover,activeiPhonePopover,enforceTimeLimitSwitch,enforceTimeLimit;
- (id)init
{
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        enforceTimeLimit = YES;
        self.contentSizeForViewInPopover= CGSizeMake(320,450);
        //shouldHideToolbar = YES;
        // Custom initialization
    }
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [activePopover release];
    [subListingCellClassName release];
    [activeiPhonePopover release];
    [objectInfo release];
    [subListing release];
    
    [super dealloc];
}

-(BOOL)assignmentWasTimed{
    return [[objectInfo valueForKey:@"timed"] boolValue];
}

-(BOOL)allowsSubListingEditing{
    return NO;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self allowsSubListingEditing] && indexPath.section == 1 && [self completeAttempt];
}
-(BOOL)isOverTimeLimit{
    return [[objectInfo valueForKey:@"is_over_time_limit"] boolValue] && [self completeAttempt];
}
-(BOOL)enforceTimeLimitInUI{
    return ![self isOverTimeLimit] || self.enforceTimeLimitSwitch.isOn;
}

-(BOOL)enforceTimeLimit{
    if(enforceTimeLimitSwitch){
        return enforceTimeLimitSwitch.isOn;
    }
    else
        return enforceTimeLimit;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(IS_IOS_7 && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        self.tableView.backgroundColor = kDefaultTableViewBackgroundColor;
    if([self isOverTimeLimit]){
        FilterTimeLimitView *view = [[FilterTimeLimitView alloc] initWithFrame:CGRectMake(0, 0, MIN(self.view.bounds.size.width-26,400), 44)];
        view.title.text = @"Enforce time limit";
        UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithCustomView:view] autorelease];
        UIBarButtonItem *flexibleSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        view.onOff.on = self.enforceTimeLimit;
        enforceTimeLimitSwitch = view.onOff;
        
        [enforceTimeLimitSwitch addTarget:self.tableView action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
        self.toolbarItems = [NSArray arrayWithObjects:flexibleSpace,item,flexibleSpace, nil];
        [view release];
        if([self allowsSubListingEditing]){
            UIView *container = [[UIView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-320)/2, 0, 320,50)];
            //container.backgroundColor = [UIColor whiteColor];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"78-stopwatch"]];
            [imageView sizeToFit];
            [container addSubview:imageView];
            [imageView release];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont boldSystemFontOfSize:18.0];
            
            label.text = @"= answered after time ran out";
            [label sizeToFit];
            imageView.center = CGPointMake(32,25);
            label.left = imageView.right+6;
            label.centerY = 25;
            [container addSubview:label];
            [label release];
            
            self.tableView.tableFooterView = container;
            [container release];
        }
    }
    
    //self.tableView.backgroundColor = kDefaultTableViewBackgroundColor;
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    
    if([self completeAttempt] && !hideAggregationFeature)
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(viewAll:)] autorelease];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@ Attempt",[objectInfo valueForKey:@"type"]];
    
    
    //if([self allowsSubListingEditing]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:THIRTY_SIX_DID_MODIFY_ANSWER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:MC_GRADES_SHOULD_DISMISS_POPOVER object:nil];

    //}
    //self.navigationItem.prompt = [NSString stringWithFormat:@"Student: %@",[objectInfo valueForKey:@"student"]];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)receivedNotification:(NSNotification*)notif{
    if([notif.name isEqualToString:THIRTY_SIX_DID_MODIFY_ANSWER]){
        //ASIDownloadCache *cache = [ASIDownloadCache sharedCache];
        [TSHTTPRequest removeCachedItemWithPath:[self uniqueURLPath]];
        [self loadData:NO extraInfo:YES];
    }
    else if([notif.name isEqualToString:MC_GRADES_SHOULD_DISMISS_POPOVER]){
        [activeiPhonePopover dismissPopoverAnimated:YES];
        self.activeiPhonePopover = nil;
    }
}
-(void)viewAll:(UIBarButtonItem*)button{
    if(showingActionSheet)
        return;
    if([activePopover isPopoverVisible]){
        [activePopover dismissPopoverAnimated:YES];
        self.activePopover = nil;
    }
    
    NSString *errors = nil;
    if([self canShowErrors])
        errors = @"View Errors";
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Original Assignment...",@"Aggregate Results",errors,nil];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        showingActionSheet = YES;
        [sheet showFromBarButtonItem:button animated:YES];
    }
    else{
        if([self isOverTimeLimit])
            [sheet showFromToolbar:self.navigationController.toolbar];
        else
            [sheet showInView:self.view];
    }
    [sheet release];
}

-(BOOL)canShowErrors{
    return YES;
}
-(BOOL)popoverControllerShouldDismissPopover:(id)popoverController{
    return YES;
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
    if([subListing count] == 0)
        [self loadData:YES];
    
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.activePopover = nil;
    self.activeiPhonePopover = nil;
    enforceTimeLimitSwitch = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


-(NSString*)uniqueURLPath{
    return [NSString stringWithFormat:@"attempt/%@/id/%@/",[objectInfo valueForKey:@"content_type"],[objectInfo valueForKey:@"attempt_id"]];
}

-(void)loadAssignment{
    __block TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:[NSString stringWithFormat:@"%@assignment/",[self uniqueURLPath]]];
    request.progressMaskType = SVProgressHUDMaskTypeClear;
    request.useSVProgressHUD = YES;
    request.cachePolicy = ASIAskServerIfModifiedWhenStaleCachePolicy;
    request.completionBlock = ^{
        AssignmentInfoViewController *vc = [[AssignmentInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
        
        //vc.attempsIDs = attemptIDs;
        //vc.studentBasedView = YES;
        vc.activeAssignment = [NSMutableDictionary dictionaryWithDictionary:[request.responseData JSONValue]];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
            UIPopoverController *pc = [[UIPopoverController alloc] initWithContentViewController:nc];
            pc.delegate = self;
            self.activePopover = pc;
            [pc presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            [pc release];
            [nc release];
        }
        else
            [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    };
    [request startAsynchronous];
}

-(void)popoverControllerDidDismissPopover:(id)popoverController{
    if([popoverController isKindOfClass:[UIPopoverController class]])
        self.activePopover = nil;
    else if([popoverController isKindOfClass:[WEPopoverController class]])
        self.activeiPhonePopover = nil;
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    showingActionSheet = NO;
    if(buttonIndex == 0){
        [self loadAssignment];
    }
    else if(buttonIndex == 1){
        
        
        NSDictionary *info = [objectInfo dictionaryWithValuesForKeys:[NSArray arrayWithObjects:@"type",@"object_content_type",@"object_id", nil]];
        
        
        GenericAggregationViewController *vc = aggregationViewControllerForAttempt(info);
        //vc.attemptReferrerID = [[objectInfo valueForKey:@"attempt_id"] integerValue];
        [self.navigationController pushViewController:vc animated:YES];
        //vc.objectInfo = info;
        
    }
//    else if(buttonIndex == 2){
//        ScatterPlotViewController *vc = [[ScatterPlotViewController alloc] init];
//        [self.navigationController pushViewController:vc animated:YES];
//        [vc release];
//    }
    else if(buttonIndex == 2 && [self canShowErrors]){
        ErrorInfoViewController *vc = [[ErrorInfoViewController alloc] init];
        vc.objectInfo = objectInfo;
        
        vc.enforceTimeLimit = self.enforceTimeLimitInUI;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
            UIPopoverController *pc = [[UIPopoverController alloc] initWithContentViewController:nc];
            [pc presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            self.activePopover = pc;
            [nc release];
            [pc release];
        }
        else{
            vc.navigationItem.prompt = [self tableView:self.tableView titleForHeaderInSection:0];
            [self.navigationController pushViewController:vc animated:YES];
        }
        [vc release];
    }
}

-(BOOL)completeAttempt{
    return [objectInfo valueForKey:@"date_completed"] != nil && [objectInfo valueForKey:@"date_completed"] != [NSNull null];
}
-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    self.subListing = nil;
    //self.objectInfo = nil;
    //has the ability to reload all of these when needed
}
-(void)loadData:(BOOL)cached extraInfo:(BOOL)extraInfo{
    NSString *path = [self uniqueURLPath];
    if(extraInfo){
        path = [path stringByAppendingFormat:@"?extra_info=1"];
    }
    __block TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:path];
    //request.requestContainer = self;
    
    if(cached && [self completeAttempt] && !extraInfo){
        request.cachePolicy = ASIAskServerIfModifiedWhenStaleCachePolicy; //since the chances of an attempt actually changing is extremely slim and the call is somewhat expensive, dont reload unless the cache expires
        
    }
    else{
        request.cachePolicy = ASIDoNotReadFromCacheCachePolicy;
        if(extraInfo){
            request.cachePolicy |=ASIDoNotWriteToCacheCachePolicy;
        }
    }
    
    
    //request.cachePolicy |= ASIDoNotWriteToCacheCachePolicy;
    
    //request.secondsToCache = 7*86400;
    request.completionBlock = ^{
        [self doneLoadingTableViewDataWithSuccess:request.didLoadFromWeb];
        
        if(!extraInfo){
            NSArray *array = [request.responseData JSONValue];
            
            
            
            self.subListing = array;
            
            if([self numberOfSectionsInTableView:self.tableView] == 2){
                if([self.tableView numberOfSections] == 1)
                    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
                else {
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
                }
            }
        }
        else{
            NSDictionary *dict = [request.responseData JSONValue];
            self.subListing = [dict valueForKey:@"children"];
            NSMutableDictionary *mutableCopy = [objectInfo mutableCopy];
            [mutableCopy addEntriesFromDictionary:[dict valueForKey:@"info"]];
            self.objectInfo = mutableCopy;
            [mutableCopy release];
            [self.tableView reloadData];
        }
    };
    request.failedBlock = ^{
        [self doneLoadingTableViewDataWithSuccess:NO];
    };
    [request startAsynchronous];
}
-(void)loadData:(BOOL)cached{
    [self loadData:cached extraInfo:NO];
}
#pragma mark - Table view data source
-(void)reloadTableViewDataSource{
    [self loadData:NO];
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0){
        NSMutableString *path = [NSMutableString stringWithString:[objectInfo valueForKey:@"testID"]];
        NSString *sectionType = [objectInfo valueForKey:@"section_type"];
        if(sectionType != nil){
            [path appendFormat:@" \u2192 %@",sectionType];
            NSString *passageName = [objectInfo valueForKey:@"passage"];
            if(passageName != nil){
                [path appendFormat:@" \u2192 %@",passageName];
            }
        }
        
        return path;
        
        
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        NSDictionary *attempt = [subListing objectAtIndex:indexPath.row];
        NSInteger numChoices = [[attempt valueForKey:@"num_choices"] integerValue];
        if(numChoices == 0){
            [self loadData:NO];
            return;
        }
       
        ChangeAnswerViewController *vc = [[ChangeAnswerViewController alloc] initWithNumberOfChoices:numChoices];
        vc.attemptID = [[attempt valueForKey:@"attempt_id"] integerValue];
        vc.previousChoice = [[attempt valueForKey:@"choice_idx"] intValue];
        vc.correctAnswer = [[attempt valueForKey:@"correct_answer_idx"] intValue];
        
        vc.numberOfChoices = numChoices;
        NSInteger questionIndex =[[attempt valueForKey:@"_order"] integerValue]; 
        vc.questionIndex = questionIndex;
        vc.parentString = [self tableView:self.tableView titleForHeaderInSection:0];
        
        
        
        
        

        
        WEPopoverController *popover = [[WEPopoverController alloc] initWithContentViewController:vc];
        AttemptTableViewCell *cell = (AttemptTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        CGRect rect = cell.badge.frame;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            
            rect.origin.x+=105;
        }
        else {
            rect = CGRectMake((self.view.bounds.size.width-20)/2, 22.0, 1, 1);
        }
        [popover presentPopoverFromRect:rect
                                           inView:cell.contentView
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                          animated:YES];
        
        popover.delegate = self;
        self.activeiPhonePopover = popover;
        [popover release];
        [vc release];
        
        
    }
}

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if(section == 0){
        id date_completed = [objectInfo valueForKey:@"date_completed"];
        NSString *description = @"Completed";
        if(date_completed == [NSNull null] || date_completed == nil){
            date_completed = [objectInfo valueForKey:@"date_created"];
            description = @"Started";
        }
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[date_completed integerValue]];
        NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
        df.dateFormat = nil;
        df.dateStyle = NSDateFormatterFullStyle;
        
        return [NSString stringWithFormat:@"%@: %@",description,[df stringFromDate:date]];
        
    }
    else if([self tableView:tableView canEditRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]]){
        return @"Swipe to modify an answer";
    }
    return nil;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1+(int)([subListing count] >0);

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if(section == 0)
        return 1;
    else {
        return [subListing count];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 70;
	}
	
	return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell2";
    Class className = NSClassFromString(subListingCellClassName);
    
    AttemptTableViewCell <AttemptCell> * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[[className alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.enforceTimeLimit = [self enforceTimeLimitInUI];
    cell.object = [self.subListing objectAtIndex:indexPath.row];
    
    // Configure the cell...
    
    return cell;
}
-(NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"Modify Answer";
}


//-(void)setStudent:(NSString*)studentName{
//    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:objectInfo];
//    [dict setValue:studentName forKey:@"student"];
//    self.objectInfo = dict;
//}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1){
        NSDictionary *attempt = [subListing objectAtIndex:indexPath.row];
        GenericAttemptViewController *vc = (GenericAttemptViewController*)attemptViewControllerForAttempt(attempt);
        if([vc isKindOfClass:[GenericAttemptViewController class]])
           vc.enforceTimeLimit = self.enforceTimeLimit;
        //vc.student = [self.objectInfo valueForKey:@"student"];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}


@end
