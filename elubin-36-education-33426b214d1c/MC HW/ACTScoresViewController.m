//
//  ACTScoresViewController.m
//  MC HW
//
//  Created by Eric Lubin on 11/9/12.
//
//

#import "ACTScoresViewController.h"
#import "EditACTScoreViewController.h"
#import "ACTScoreiPadTableViewCell.h"
#import "ACTResult.h"
@interface ACTScoresViewController ()
@property (nonatomic,strong) NSMutableArray *actScores;
@property (nonatomic,strong) NSArray *sectionNames;
@property (nonatomic,strong) NSArray *verboseNames;
@property (nonatomic,strong) NSArray *allowedRanges;

@property (nonatomic,strong) UIPopoverController *activePopover;

@property (nonatomic) NSInteger objectIDOfPreviouslySelectedACTScore;;


@property (nonatomic,strong) NSIndexSet *validMonths;
@property (nonatomic,strong) NSIndexPath *selectedIndexPath;
@end

@implementation ACTScoresViewController
NSString * sectionNameKey = @"section_names";
NSString * verboseNamesKey = @"sub_score_verbose_names";
NSString * allowedRangesKey = @"allowed_ranges";
- (id)init
{
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
        _objectIDOfPreviouslySelectedACTScore = NSNotFound;
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"ACT Scores";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewACTScore:)];
    self.navigationItem.rightBarButtonItem.enabled = NO; //we will enable it the first time a web request loads successfully
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.verboseNames = [[NSUserDefaults standardUserDefaults] objectForKey:verboseNamesKey];
    self.sectionNames = [[NSUserDefaults standardUserDefaults] objectForKey:sectionNameKey];
    self.allowedRanges = [self convertTuplesToRangeObjects:[[NSUserDefaults standardUserDefaults] objectForKey:allowedRangesKey]];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:SHOULD_DISMISS_POPOVER_FOR_ACTS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:DID_MODIFY_ACT_SCORE_OBJECT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:DID_ADD_ACT_SCORE_OBJECT object:nil];
}

-(void)receivedNotification:(NSNotification*)notification{
    if([notification.name isEqualToString:SHOULD_DISMISS_POPOVER_FOR_ACTS_NOTIFICATION ]){
        [self.activePopover dismissPopoverAnimated:YES];
        [self popoverControllerDidDismissPopover:self.activePopover];
        
    }
    else if([notification.name isEqualToString:DID_MODIFY_ACT_SCORE_OBJECT]){
        _objectIDOfPreviouslySelectedACTScore = [notification.userInfo[@"id"] integerValue];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            [self sortScores];
            [self.tableView reloadData];
        }
    }
    else if([notification.name isEqualToString:DID_ADD_ACT_SCORE_OBJECT]){
        ACTResult *newEntry = notification.userInfo[@"object"];
        [self.actScores addObject:newEntry];
        [self sortScores];
        [self.tableView reloadData];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    if(_objectIDOfPreviouslySelectedACTScore != NSNotFound && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        [self sortScores];
        [self.tableView reloadData];
        [self.actScores enumerateObjectsUsingBlock:^(ACTResult *obj, NSUInteger idx, BOOL *stop) {
            if(obj.objectID == _objectIDOfPreviouslySelectedACTScore){
                
                
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
                _objectIDOfPreviouslySelectedACTScore = NSNotFound;
                *stop = YES;
            }
        }];
        
    }
    [super viewWillAppear:animated];
    if(_actScores == nil){
        [self reloadTableViewDataSource];
    }
    
}
//-(BOOL)verifyCanEdit{//returns yes if we can proceed, if not no
//    if([_validMonths count] == 0){
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please wait" message:@"Please wait until the main ACT page loads once before proceeding" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
//        [alert show];
//        return NO;
//        
//    }
//    return YES;
//}

-(void)addNewACTScore:(UIBarButtonItem*)button{
    if([_activePopover isPopoverVisible])
        return;
    
    
    EditACTScoreViewController * vc = [[EditACTScoreViewController alloc] initWithVerboseNames:self.verboseNames sectionNames:self.sectionNames allowedRanges:self.allowedRanges validMonths:_validMonths actResult:nil];
    vc.studentID = _studentID;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        
        [self presentViewController:nc animated:YES completion:nil];
    }
    else{
        UIPopoverController *pc = [[UIPopoverController alloc] initWithContentViewController:nc];
        pc.delegate = self;
        _activePopover = pc;
        //_showingNewACTPopover = YES;
        [pc presentPopoverFromBarButtonItem:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
}

-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    return NO;
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{

    self.activePopover = nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}
-(void)viewDidUnload{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_actScores count];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait) || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}
-(NSString*)uniqueURLPath{
    return [NSString stringWithFormat:@"students/%d/act_scores/",_studentID];
}


-(NSArray*)convertTuplesToRangeObjects:(NSArray*)input{
    
    NSArray *allowedRanges = input; //currently, each allowed range is listed as an array of two integers, we iterate through all and change to an array of NSValue objects
    
    NSMutableArray *finalRanges = [NSMutableArray arrayWithCapacity:[allowedRanges count]];
    for(NSArray *sectionlist in allowedRanges){
        NSMutableArray *sublistings = [NSMutableArray array];
        for(NSArray *rangeTuple in sectionlist) {
            NSInteger low = [rangeTuple[0] integerValue];
            NSInteger high = [rangeTuple[1] integerValue];
            NSRange acceptedRange = NSMakeRange(low,high-low);
            [sublistings addObject:[NSValue valueWithRange:acceptedRange]];
        }
        [finalRanges addObject:sublistings];
    }
    return finalRanges;
}


-(void)reloadTableViewDataSource{
    //NSLog(@"Starting important web request with URL %@",[self uniqueURLPath]);
    TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:[self uniqueURLPath]];
    //request.requestContainer = self;
    request.useSVProgressHUD = _actScores == nil;
    request.timeOutSeconds = 10;
    request.cachePolicy = ASIFallbackToCacheIfLoadFailsCachePolicy | ASIAskServerIfModifiedCachePolicy;
    
    __weak TSHTTPRequest *weakRequest = request;
    request.completionBlock = ^{
        NSDictionary *dict = [[weakRequest responseData] JSONValue];
        NSArray *array = [dict valueForKey:@"scores"];
        
        self.sectionNames = dict[sectionNameKey];
        
        
        self.allowedRanges = [self convertTuplesToRangeObjects:dict[allowedRangesKey]];
        [[NSUserDefaults standardUserDefaults] setObject:dict[allowedRangesKey] forKey:allowedRangesKey];
        [[NSUserDefaults standardUserDefaults] setObject:self.sectionNames forKey:sectionNameKey];
        
        //we need to make copies of each dictionary to make them mutable, overall we have a mutable array of ACTResult objects
        NSMutableArray *newListarray = [NSMutableArray arrayWithCapacity:[array count]];
        for (NSDictionary *assignment in array){
            [newListarray addObject:[[ACTResult alloc] initWithDictionaryRepresentation:assignment allowedRanges:self.allowedRanges]];
        }
        
        
        self.verboseNames = dict[verboseNamesKey];
        [[NSUserDefaults standardUserDefaults] setObject:self.verboseNames forKey:verboseNamesKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.actScores = newListarray;
        
        
        NSMutableIndexSet *validMonths = [NSMutableIndexSet indexSet];
        for(NSNumber *month in dict[@"valid_months"]){
            [validMonths addIndex:[month integerValue]-1];
        }
        self.validMonths = validMonths;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self.tableView reloadData];
        [self doneLoadingTableViewDataWithSuccess:weakRequest.didLoadFromWeb];
    };
    request.failedBlock = ^{
        [self doneLoadingTableViewDataWithSuccess:NO];
    };
    
    [request startAsynchronous];
    
    
    
    
    //NSLog(@"%@",url);
}

-(void)sortScores{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [self.actScores sortUsingComparator:^NSComparisonResult(ACTResult *obj1, ACTResult *obj2) {
        NSDate *date1 = [calendar dateFromComponents:obj1.dateTaken];
        NSDate *date2 = [calendar dateFromComponents:obj2.dateTaken];
        
        return [date2 compare:date1];
    }];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ACTScoreiPadTableViewCell heightForInfo:_actScores[indexPath.row]];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ACTScoreiPadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
        cell = [[ACTScoreiPadTableViewCell alloc] initWithReuseIdentifier:CellIdentifier sectionNames:self.sectionNames];
    }
    
    cell.sectionScoreInfo = _actScores[indexPath.row];
    // Configure the cell...
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the row from the data source
        
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure? This action cannot be undone." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove" otherButtonTitles:nil];
        sheet.tag = indexPath.row;
        sheet.delegate = self;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [sheet showFromRect:[tableView rectForRowAtIndexPath:indexPath] inView:self.tableView animated:YES];
        else{
            [sheet showInView:self.view];
        }
        
        
        
        
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        ACTResult *result = _actScores[actionSheet.tag];
        TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:[NSString stringWithFormat:@"act_scores/%d/",result.objectID]];
        //request.requestContainer = self;
        request.useSVProgressHUD = YES;
        request.progressMaskType = SVProgressHUDMaskTypeClear;
        request.requestMethod = @"DELETE";
        
        
        request.completionBlock = ^{
            [_actScores removeObject:result];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:actionSheet.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        };
        
        
        [request startAsynchronous];
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
    
    ACTResult *score = _actScores[indexPath.row];
    
    EditACTScoreViewController *vc = [[EditACTScoreViewController alloc] initWithVerboseNames:self.verboseNames sectionNames:self.sectionNames allowedRanges:self.allowedRanges validMonths:_validMonths actResult:score];
    vc.studentID = _studentID;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
        UIPopoverController *pc = [[UIPopoverController alloc] initWithContentViewController:nc];
        CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
        self.activePopover = pc;
        pc.delegate = vc;
        [pc presentPopoverFromRect:cellRect inView:self.tableView permittedArrowDirections:UIPopoverArrowDirectionLeft|UIPopoverArrowDirectionRight|UIPopoverArrowDirectionDown animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    }
    else
        [self.navigationController pushViewController:vc animated:YES];

}

@end
