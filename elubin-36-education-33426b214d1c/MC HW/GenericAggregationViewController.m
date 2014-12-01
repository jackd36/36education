//
//  GenericAggregationViewController.m
//  MC HW
//
//  Created by Eric Lubin on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GenericAggregationViewController.h"
#import "ASINetworkQueue.h"
#import "AddQuestionTagViewController.h"
#import "SectionTagViewController.h"
#import "AggregationFilterViewController.h"
#import "ELAppDelegate.h"
@interface GenericAggregationViewController ()

@property (nonatomic,strong) NSArray *attempts;
@property (nonatomic,strong) NSArray *subListing;
@property (nonatomic,retain) UISegmentedControl *segmentedControl;
@property (nonatomic,retain) ASINetworkQueue *queue;
@property (nonatomic,retain) UIPopoverController *activePopover;
-(void)doNetworkOperations:(TSHTTPRequest*)firstRequest,...NS_REQUIRES_NIL_TERMINATION;
@end

@implementation GenericAggregationViewController
@synthesize objectInfo,attempts,numberOfRowsInGrid,attemptReferrerID,segmentedControl,studentsIDs,queue,subListing,keyForObjectInfoDidLoad,numberOfRowsInSectionOne,activePopover,tutorAided;
UITableViewRowAnimation rowAnimation = UITableViewRowAnimationNone;

-(NSString*)headerTitleForSecondSection{
    return nil;
}
- (void)dealloc
{
    [activePopover release];
    [objectInfo release];
    [attempts release];
    [segmentedControl release];
    [studentsIDs release];
    [queue release];
    [subListing release];
    [keyForObjectInfoDidLoad release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
- (id)init
{
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.keyForObjectInfoDidLoad = @"num_attempts";
        numberOfRowsInSectionOne=1;
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        numberOfRowsInGrid =1;
        ELAppDelegate *delegate = [ELAppDelegate sharedDelegate];
        
        NSString *key= [NSString stringWithFormat:@"selectedStudent__%d",delegate.activeUser.object_id];
        NSNumber *object = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        self.hidesBottomBarWhenPushed = NO;
        UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"filter-white"] style:UIBarButtonItemStyleBordered target:self action:@selector(showFilterView:)] autorelease];
        
        self.toolbarItems = [NSArray arrayWithObjects:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],button,nil];
        tutorAided = -1;
        //NSLog(@"%@",[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
        //NSLog(@"%@",object);
        
        
        self.studentsIDs =[NSSet setWithObject:object ];
        //self.studentsIDs = [NSSet setWithObjects:[NSNumber numberWithInt:3],[NSNumber numberWithInt:15],nil];
        
        // Custom initialization
    }
    return self;
}
-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    return NO;
}
-(void)showFilterView:(UIBarButtonItem*)button{
    if([activePopover isPopoverVisible]){
        return;
    }
    AggregationFilterViewController *vc = [[AggregationFilterViewController alloc] initWithStudents:studentsIDs tutorAided:tutorAided+1];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    //nc.navigationBar.tintColor = kDefaultToolbarColor;
    //nc.toolbar.tintColor = kDefaultToolbarColor;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()){
        UIPopoverController *pc = [[UIPopoverController alloc] initWithContentViewController:nc];
        self.activePopover = pc;
        pc.delegate = self;
        [pc presentPopoverFromBarButtonItem:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        [pc release];
    }
    else{
        [self presentViewController:nc animated:YES completion:nil];
    }
    [nc release];
    [vc release];
}

-(NSString*)headerTitleForAggregates{
    return nil;
}
-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    self.attempts = nil;
    self.subListing = nil;
    //self.objectInfo = nil;
    //has the ability to reload all of these when needed
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if(IS_IOS_7 && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        self.tableView.backgroundColor = kDefaultTableViewBackgroundColor;
    //self.tableView.backgroundColor = kDefaultTableViewBackgroundColor;
    NSString *type = [objectInfo valueForKey:@"type"];
    if([type isEqualToString:@"Question"]){
        NSString *question = [objectInfo valueForKey:@"question"];
        if(question == nil)
            self.navigationItem.title = @"Question Info";
        else
            self.navigationItem.title = question;
    }
    else {
        UISegmentedControl *sc = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Attempts",@"Aggregate", nil]];
        [sc addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
        sc.segmentedControlStyle  = UISegmentedControlStyleBar;
        sc.selectedSegmentIndex = 0;
        self.navigationItem.titleView = sc;
        segmentedControl = sc;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:MC_GRADES_SHOULD_DISMISS_POPOVER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:@"DID_MODIFY_FILTER_PARAMS_FOR_AGGREGATION" object:nil];
    //self.navigationItem.title = ;
	// Do any additional setup after loading the view.
}
-(void)notificationReceived:(NSNotification*)notif{
    if([notif.name isEqualToString:MC_GRADES_SHOULD_DISMISS_POPOVER]){
        
        [activePopover dismissPopoverAnimated:YES];
        self.activePopover = nil;
    }
    else if([notif.name isEqualToString:@"DID_MODIFY_FILTER_PARAMS_FOR_AGGREGATION"]){
        
        NSSet *newStudentIDs = [notif.userInfo valueForKey:@"students"];
        NSInteger newTutorAided = [[notif.userInfo valueForKey:@"tutorAided"] integerValue]-1;
        if(![newStudentIDs isEqualToSet:studentsIDs] || newTutorAided != tutorAided){
            self.studentsIDs = newStudentIDs;
            tutorAided = newTutorAided;
            self.attempts = nil;
            self.subListing = nil;
            self.objectInfo = [NSDictionary dictionaryWithObjectsAndKeys:[objectInfo valueForKey:@"object_content_type"],@"object_content_type",[objectInfo valueForKey:@"object_id"],@"object_id",nil];
            [self loadRequestsOnViewDidLoad];
        }
        //[self reloadTableViewDataSource];
    }
}
-(void)updateTopRightButton{
    
    if([objectInfo valueForKey:@"section_tag"])
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:[self.objectInfo valueForKey:@"section_type"] style:UIBarButtonItemStyleBordered target:self action:@selector(pushSectionTagAggregationVC)] autorelease];
    else
        self.navigationItem.rightBarButtonItem = nil;
}

-(void)pushSectionTagAggregationVC{
    SectionTagViewController *vc = [[SectionTagViewController alloc] init];
    NSMutableDictionary *newInfo = [[objectInfo valueForKey:@"section_tag"] mutableCopy];
    [newInfo setValue:[objectInfo valueForKey:@"section_type"] forKey:@"section_type"];
    vc.objectInfo = newInfo;
    vc.studentsIDs = self.studentsIDs;
    [newInfo release];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
    
    [self loadRequestsOnViewDidLoad];
}

-(void)loadRequestsOnViewDidLoad{
    if([self needsLoad]){
        TSHTTPRequest *secondRequest = nil;
        if([objectInfo valueForKey:keyForObjectInfoDidLoad] == nil)
            secondRequest = [self loadObjectInfoRequest];
        TSHTTPRequest *firstRequest = [self requestForActivelySelectedSegment];
        
        [self doNetworkOperations:firstRequest,secondRequest, nil];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
}
-(BOOL)needsLoad{
    return ([self onAttemptsTab] && [attempts count] == 0) || (![self onAttemptsTab] && [subListing count] == 0) || [objectInfo valueForKey:keyForObjectInfoDidLoad] == nil;
}
-(void)valueChanged{
    [self refreshLastUpdated];
    if([self needsLoad]){
        TSHTTPRequest *secondRequest = nil;
        if([objectInfo valueForKey:keyForObjectInfoDidLoad] == nil)
            secondRequest = [self loadObjectInfoRequest];
        TSHTTPRequest *firstRequest = [self requestForActivelySelectedSegment];
        
        [self doNetworkOperations:firstRequest,secondRequest, nil];
    }
    else {
        [self.tableView reloadData];
    }
}

-(NSString*)uniqueURLPath{
    return [self pathWithSelectedIndex:segmentedControl.selectedSegmentIndex];
}

-(NSString*)pathWithSelectedIndex:(NSInteger)index{
    NSString *slug=nil;
    if(index == 1)
        slug = @"attempts";
    else
        slug = @"children";
    return [[self baseURL] stringByAppendingFormat:@"%@/%@",slug,[self userFilter]];
}

-(NSString*)userFilter{
    return [NSString stringWithFormat:@"?user_filter=%@&tracking_info=%d",[[studentsIDs allObjects] componentsJoinedByString:@","],tutorAided];
}
-(NSString*)baseURL{
    return [NSString stringWithFormat:@"aggregate/ct/%@/id/%@/",[objectInfo valueForKey:@"object_content_type"],[objectInfo valueForKey:@"object_id"]];
}

-(NSString*)URLForObjectInfo{
    return [[self baseURL] stringByAppendingString:[self userFilter]];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0 && [objectInfo valueForKey:@"testID"]){
        NSMutableString *path = [NSMutableString stringWithString:[objectInfo valueForKey:@"testID"]];
        NSString *sectionType = [objectInfo valueForKey:@"section_type"];
        if(sectionType != nil){
            [path appendFormat:@" \u2192 %@",sectionType];
            if([sectionType isEqualToString:@"Math"])
                return path;
            NSString *passageName = [objectInfo valueForKey:@"passage"];
            if(passageName != nil){
                [path appendFormat:@" \u2192 %@",passageName];
                
            }
        }
        
        return path;
        
        
    }
    else if(section == 2){
        if([self onAttemptsTab])
            return @"Attempts";
        else{
            return [self headerTitleForAggregates];
        }
    }
    else if(section == 1 && [self isSecondSectionVisible]){
        return [self headerTitleForSecondSection];
    }
    return nil;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *array = [self arrayOfActiveSegment];
    return 2+(int)([array count] >0);
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(section == 0)
        return numberOfRowsInSectionOne;//([objectInfo valueForKey:keyForObjectInfoDidLoad] != nil)*numberOfRowsInSectionOne;
    else if(section ==1)
        return [self isSecondSectionVisible] > 0;
    else {
        
        return [[self arrayOfActiveSegment] count];
    }
}
-(BOOL)onAttemptsTab{
    return segmentedControl.selectedSegmentIndex == 0;
}
-(NSArray*)arrayOfActiveSegment{
    
    if(![self onAttemptsTab])
        return subListing;
    else
        return attempts;
}
-(BOOL)isSecondSectionVisible{
    //[NSException raise:@"Method Must Be Overriden" format:nil];
    return NO;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 70*numberOfRowsInGrid;
	}
	if(indexPath.section == 1){
        return [self heightForRowInSecondSection];
    }
	return 44;
}
-(CGFloat)heightForRowInSecondSection{
    return 44.0f;
}
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return queue.requestsCount > 0;
}




-(TSHTTPRequest*)requestWithURL:(NSString*)url callback:(void (^)(id rootObject)) block{
    __block TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:url];
    //request.requestContainer = self;
    request.cachePolicy = ASIAskServerIfModifiedCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy;
    request.completionBlock = ^{
        //[self doneLoadingTableViewDataWithSuccess:request.didLoadFromWeb];
        id rootObject = [request.responseData JSONValue];
        //NSLog(@"cached=%d",[request didUseCachedResponse]);
        block(rootObject);
    };
    request.failedBlock = ^{
        [self doneLoadingTableViewDataWithSuccess:NO];
    };
    return request;
}
-(TSHTTPRequest*)loadAttemptsRequest{
    return [self requestWithURL:[self pathWithSelectedIndex:1] callback:^(id rootObject){
        self.attempts = [rootObject valueForKey:@"attempts"];
        [self.tableView reloadData];
//        if([self numberOfSectionsInTableView:self.tableView] == 3){
//            if([self.tableView numberOfSections] == 2)
//                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:rowAnimation];
//            else {
//                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:rowAnimation];
//            }
//        }
        //[self.tableView reloadData];
    }];
}

-(TSHTTPRequest*)loadAggregatesRequest{
    return [self requestWithURL:[self pathWithSelectedIndex:0] callback:^(id rootObject){
        self.subListing = [rootObject valueForKey:@"children"];
        [self.tableView reloadData];
//        if([self numberOfSectionsInTableView:self.tableView] == 3){
//            if([self.tableView numberOfSections] == 2)
//                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:rowAnimation];
//            else {
//                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:rowAnimation];
//            }
//        }
        //[self.tableView reloadData];
    }];
}

-(TSHTTPRequest*)requestForActivelySelectedSegment{
    if(![self onAttemptsTab])
        return [self loadAggregatesRequest];
    else
        return [self loadAttemptsRequest];
}
-(TSHTTPRequest*)loadObjectInfoRequest{
    return [self requestWithURL:[self URLForObjectInfo] callback:^(id rootObject){
        NSLog(@"%@",rootObject);
        self.objectInfo = rootObject;
        
        //self.attempts = [rootObject valueForKey:@"attempts"];
        if([[objectInfo valueForKey:@"type"] isEqualToString:@"Question"])
            self.navigationItem.title = [objectInfo valueForKey:@"question"];
        [self updateTopRightButton];
//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:rowAnimation];
        [self.tableView reloadData];
    }];
}
-(void)reloadTableViewDataSource{
    TSHTTPRequest *otherRequest = nil;
    if([self onAttemptsTab])
        otherRequest = [self loadAttemptsRequest];
    else
        otherRequest = [self loadAggregatesRequest];
    
    [self doNetworkOperations:[self loadObjectInfoRequest],otherRequest, nil];
    
}

-(void)doNetworkOperations:(TSHTTPRequest*)firstRequest,...{
    //[queue cancelAllOperations];
    self.queue = [ASINetworkQueue queue];
    queue.delegate =self;
    queue.queueDidFinishSelector = @selector(queueFinished:);
    queue.requestDidFinishSelector = @selector(requestFinished:);
    va_list args;
    va_start(args, firstRequest);
    for (TSHTTPRequest *arg = firstRequest; arg != nil; arg = va_arg(args, TSHTTPRequest*))
    {
        [queue addOperation:arg];
    }
    va_end(args);
    
    
    [queue go];
}

-(void)queueFinished:(ASINetworkQueue*)qu{
    if ([queue requestsCount] == 0) {
        self.queue = nil;
    }
[UIApplication sharedApplication].networkActivityIndicatorVisible= NO;
}
- (void)requestFinished:(TSHTTPRequest *)request
{
	
    [self updateTopRightButton];
    [self doneLoadingTableViewDataWithSuccess:request.didLoadFromWeb];
     // You could release the queue here if you wanted
     
    
	//... Handle success
	NSLog(@"Request finished");
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.segmentedControl=nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // Release any retained subviews of the main view.
}


@end
