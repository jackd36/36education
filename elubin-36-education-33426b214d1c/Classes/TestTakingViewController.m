//
//  TestTakingViewController.m
//  MC HW
//
//  Created by Eric Lubin on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestTakingViewController.h"
#import "MCTableViewCell.h"
#import "TSTestTakingModel.h"
#import "TSTestAbstractBase.h"
#import "GenericTestUploadHTTPRequest.h"
#import "TSSection.h"
#import "TSQuestion.h"
#import "AddQuestionTagViewController.h"
#import "ELAppDelegate.h"
#import "UIImage+extensions.h"
#import "UnuploadedTestsViewController.h"
#import <AudioToolbox/AudioToolbox.h>
NSString * const THIRTY_SIX_DID_COMPLETE_ASSIGNMENT = @"36DID_CMPLETE_HW_ASSIGNMENT";
NSString * const THIRTY_SIX_ASSIGNMENT_STATUS_DID_CHANGE = @"36DID_CHANGE_HW_ASSIGNMENT";
NSString * const THIRTY_SIX_CONNECTION_ERROR_ASSIGNMENT = @"36 CONNECTION ERORR!";

NSInteger const minutesLeftForTimeWarning = 5;
@interface TestTakingViewController()
@property BOOL didAddNotificationObservers;
@property (nonatomic,strong) NSDate *testStarted;
@property (nonatomic) NSTimeInterval timeOnClock; //used if a user pauses a test and needs to resume
@property (nonatomic) NSTimeInterval timeForCurrentQuestion; //used only when a user pauses the test and needs to resume
@property (nonatomic,strong) NSDate *previousQuestionAnswered;
@property (nonatomic,strong) NSTimer *testTimer;
@property (nonatomic,strong) NSTimer *autosaveTimer; //will autosave testprogress every 15 seconds
-(NSTimeInterval)timeElapsedInAttempt;
-(NSTimeInterval)timeElapsedSinceLastQuestionWasAnswered;
@end
@implementation TestTakingViewController
@synthesize dataModel,testStarted,previousQuestionAnswered,testTimer,timeOnClock,timeForCurrentQuestion,partOfTest,didAddNotificationObservers=_didAddNotificationObservers;

-(id)initWithDataModel:(TSTestAbstractBase *)model{
    if(self = [self initWithStyle:UITableViewStyleGrouped]){
        dataModel = [model retain];
        if([dataModel isTimed]){
            timeOnClock = dataModel.totalTimeSpentThusFar;
            timeForCurrentQuestion = dataModel.unassignedTime;
        }
        self.modalPresentationStyle = UIModalPresentationPageSheet;
        //self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    return self;
}


- (void)dealloc {
    [dataModel release];
    [testStarted release];
    [previousQuestionAnswered release];
    [testTimer invalidate];
    [testTimer release];
    [_autosaveTimer invalidate];
    [_autosaveTimer release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
-(void)configureTableView{
    self.tableView.backgroundView = nil;
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.scrollsToTop = YES;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    //CGFloat cellHeight = 58.0f;
    
    
//    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
//        cellHeight = 85;
//        
//        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"chalkboard_ipad_portrait"]];
//        //self.tableView.backgroundColor = self.view.backgroundColor;
//    }
//    elsef
//        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"chalkboard-bg"]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //self.tableView.backgroundColor = [UIColor clearColor];
    if(!IS_IOS_7) {
        self.navigationController.navigationBar.tintColor = nil;
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    } else {
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;

    }
    
    
    
    
    if([dataModel isTimed]){
    
        NSString *buttonString = nil;
        NSInteger minutesInTest = [dataModel lengthOfTest];
        if(minutesInTest == 0)
            buttonString = @"0:00";
        else
            buttonString = [NSString stringWithFormat:@"%d:00",minutesInTest];
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 75, 35)];
        if(IS_IOS_7)
            title.textColor = [UIColor blackColor];
        else
            title.textColor = [UIColor whiteColor];
        title.backgroundColor = [UIColor clearColor];
        title.font = [UIFont boldSystemFontOfSize:16.0f];
        title.text = buttonString;
        title.textAlignment = UITextAlignmentCenter;
        
        UIBarButtonItem *pause = nil;
        if([dataModel isTutorBased]){
            pause = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"17-pause" withColor:[UIColor whiteColor]] style:UIBarButtonItemStyleBordered target:self action:@selector(playPausePressed:)] autorelease];
        }
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:[[[UIBarButtonItem alloc] initWithCustomView:title] autorelease],pause,nil];
        [title release];
        
        //NSInteger minutesInTest = [dataModel lengthOfTest];
        NSInteger timeElapsed = (int)[self timeElapsedInAttempt];
        
        if(minutesInTest != 0 && timeElapsed >= minutesInTest*60){
            title.text = @"0:00";
            timeRanOut = YES;
            if([dataModel isTutorBased]){
                [self disablePlayPauseAfterTimeExpires];
            }
            //[self disableUserInteractionWithAnsweredQuestions];
        }
        else{
            if(minutesInTest != 0 && minutesInTest*60-timeElapsed <= minutesLeftForTimeWarning*60)
                fiveMinuteWarningTriggered = YES;
            [self timerUpdated:nil];
        }
    }
    else{
        self.navigationItem.hidesBackButton = YES;
    }
   
    
    //self.navigationItem.leftBarButtonItem.userInter
    //self.navigationItem.leftBarButtonItem.enabled = NO;
    
    NSString *buttonText = @"Submit";
    //if([self isPartOfTest])
      //  buttonText = @"Continue";
    
    
    UIBarButtonItem *item = nil;
    UIBarButtonItem *rightButtonItem = nil;
    if([dataModel isTutorBased]){
        item = [[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(presentAlertToSaveForLater)] autorelease];
        if([dataModel isTimed]){
            rightButtonItem = item;
            
        }
        else{
            self.navigationItem.leftBarButtonItem = item;
        }
    }
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:[[[UIBarButtonItem alloc] initWithTitle:buttonText style:UIBarButtonItemStyleDone target:self action:@selector(submitAction)] autorelease],rightButtonItem,nil];

    
    
    [self configureNavTitles];
    [self configureTableView];
    
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    //self.navigationController.navigationBar.tintColor = nil;
    if(!_didAddNotificationObservers){
        _didAddNotificationObservers = YES;
        if([dataModel isTimed]){
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:@"SHOULD_RESTART_TIMER" object:nil];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:UIApplicationDidChangeStatusBarOrientationNotification object:[UIApplication sharedApplication]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
    }
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)configureNavTitles{
    NSString *title = [NSString stringWithFormat:@"%@ - %@",dataModel.sectionName,dataModel.testID];
    UIInterfaceOrientation newOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsPortrait(newOrientation)){
        self.navigationItem.prompt = title;
        self.navigationItem.title  = nil;
        if(!IS_IOS_7) {
            self.tableView.contentInset = UIEdgeInsetsMake(74, 0, 0, 0);
        }
        
    }
    else{
        self.navigationItem.prompt = nil;
        self.navigationItem.title = title;
        if(!IS_IOS_7) {
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                self.tableView.contentInset = UIEdgeInsetsMake(45, 0, 0, 0);
            //else
                //self.tableView.contentInset = UIEdgeInsetsMake(55, 0, 0, 0);
        }
        
    }
    
    self.tableView.rowHeight = [MCStyledControl paddingForNumChoices:dataModel.numChoices orientation:newOrientation]+[MCStyledControl sizeofCellForNumChoices:dataModel.numChoices orientation:newOrientation];
}

-(void)disablePlayPauseAfterTimeExpires{
    UIBarButtonItem *item = [self.navigationItem.leftBarButtonItems objectAtIndex:0];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObject:item];
}
-(void)presentAlertToSaveForLater{
    [self pauseTimer];
    alertViewPresent = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"This will close the test-taking view. You may open it again at any time and pick up where you left off." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Quit", nil];
    alert.tag=666;
    alert.delegate = self;
    [alert show];
    [alert release];
}
-(void)playPausePressed:(UIBarButtonItem*)button{
    
    if(!pauseButtonPressed){
        button.image = [UIImage imageNamed:@"16-play" withColor:[UIColor whiteColor]];
        button.style = UIBarButtonItemStyleDone;
        [self pauseTimer];
//        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(alertAboutPause)];
//        [self.view addGestureRecognizer:gesture];
//        [gesture release];
        pauseButtonPressed = YES;
        
    }
    else{
        button.image = [UIImage imageNamed:@"17-pause" withColor:[UIColor whiteColor]];
        button.style = UIBarButtonItemStyleBordered;
        pauseButtonPressed = NO;
        [self beginTimer];
        //self.view.gestureRecognizers=nil;
        
    }
    //self.tableView.userInteractionEnabled = !self.tableView.userInteractionEnabled;
    
}

//-(void)alertAboutPause{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"The timer is currently paused. Please unpause the timer to continue working." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show];
//    [alert release];
//    return;
//}
-(void)saveForLater{
    
    [self submitTest:NO hideUIAfterCompletion:YES];
    [self prepareUIApplicationForStart:NO];
    
}
-(void)submitAction{
    [self pauseTimer];
    [self prepareUIApplicationForStart:NO];
    NSInteger unanswered =dataModel.unansweredQuestions; 
    if (unanswered > 0){
        alertViewPresent = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning!" message:[NSString stringWithFormat:@"You have only answered %d of %d questions. Are you sure you want to continue? You will not be able to modify your answers anymore.",dataModel.numberOfRows-unanswered,dataModel.numberOfRows]  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Submit", nil];
        
        [alert show];
        [alert release];
    }
    else
        [self submitTest:YES];
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == 666 && buttonIndex == 1){
        [self saveForLater];
    }
    else if (buttonIndex == 1 || alertView.tag == 100001)
        [self submitTest:YES];
    else{
        alertViewPresent = NO;
        [self beginTimer];
    }
}


-(void)submitTest:(BOOL)completed hideUIAfterCompletion:(BOOL)hideUI{
    if(pauseButtonPressed){
        dataModel.unassignedTime = timeForCurrentQuestion;
        dataModel.totalTimeSpentThusFar=timeOnClock;
    }
    else
        [self pauseTimer];//this updates time properties of dataModel before submission
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    //return;
    
    self.tableView.userInteractionEnabled = NO;
    ELAppDelegate *delegate = [ELAppDelegate sharedDelegate];
    NSInteger uid = delegate.activeUser.object_id;
    
    
    NSDictionary *dictRepr = [dataModel dictionaryRepresentation];
    __block GenericTestUploadHTTPRequest *request = [GenericTestUploadHTTPRequest requestForUser:uid WithAssignmentID:dataModel.assignmentID jsonAnswerString:[dictRepr JSONRepresentation] completed:completed sectionName:dataModel.sectionName onRetry:0];
    
    
    //request.requestContainer = self;
    
    if([dataModel isTutorBased])
        request.progressSuccessText = @"Test upload successful.";
    else
        request.progressSuccessText = @"Test upload successful. Your tutor has been notified of the results.";
    request.showAlertMessages = NO; // only close test-taking view when an explicit submit was pushed, not after a background failur      
    if(completed){
        request.completionBlock = ^{
//            [self.parentViewController dismissModalViewControllerAnimated:YES];
//            return;
//            
//            
            
            if([self isPartOfTest]){
                TSSection *section = (TSSection*)dataModel;
                section.complete = YES;
                [_autosaveTimer invalidate];
                [testTimer invalidate];
                [self.navigationController popViewControllerAnimated:YES];
                
            }
            else {
                if(![request error])
                    [[NSNotificationCenter defaultCenter] postNotificationName:THIRTY_SIX_DID_COMPLETE_ASSIGNMENT object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:dataModel.assignmentID] forKey:@"id"]];
                else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:THIRTY_SIX_CONNECTION_ERROR_ASSIGNMENT object:nil userInfo:nil];
                }
                [_autosaveTimer invalidate];
                [testTimer invalidate];
                [self.parentViewController dismissModalViewControllerAnimated:YES];
            }
            
            
        };
    }
    else if(hideUI){
        request.completionBlock = ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:THIRTY_SIX_ASSIGNMENT_STATUS_DID_CHANGE object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:dataModel.assignmentID] forKey:@"id"]];
            if([self isPartOfTest]){
                TSSection *section = (TSSection*)dataModel;
                section.started = YES;
                [testTimer invalidate];
                [_autosaveTimer invalidate];
                [self.navigationController popViewControllerAnimated:YES];
                
            }
            else {
                
                [testTimer invalidate];
                [_autosaveTimer invalidate];
                [self.parentViewController dismissModalViewControllerAnimated:YES];
            }
        };
    }
    else{
        request.completionBlock = ^{
          self.tableView.userInteractionEnabled = YES;
        };
    }
    request.additionalFailureBlock = ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:THIRTY_SIX_ASSIGNMENT_STATUS_DID_CHANGE object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:DID_COMPLETE_UPLOADING_FALLBACKS object:nil];
        [testTimer invalidate];
        [_autosaveTimer invalidate];
        [self dismissModalViewControllerAnimated:YES];
    };
    [request startAsynchronous];

}
-(void)submitTest:(BOOL)completed{
    [self submitTest:completed hideUIAfterCompletion:NO];
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown|| UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

-(BOOL)shouldAutorotate{
    return YES;
}

//-(NSUInteger)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskAllButUpsideDown;
//}

-(void)beginTimer{
    if(pauseButtonPressed || alertViewPresent || ![dataModel isTimed] || timeRanOut || [testTimer isValid])
        return;
    self.testStarted = [NSDate date];
    self.previousQuestionAnswered = [NSDate date];
    
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    [testTimer invalidate];
    self.testTimer = [NSTimer timerWithTimeInterval:0.25f target:self selector:@selector(timerUpdated:) userInfo:nil repeats:YES];
    [runloop addTimer:testTimer forMode:NSRunLoopCommonModes];
    [runloop addTimer:testTimer forMode:UITrackingRunLoopMode];
}
-(void)notificationReceived:(NSNotification*)notif{
    if([notif.name isEqualToString:UIApplicationDidBecomeActiveNotification]){
        
        [self beginTimer];
        [self configureAutoSaveTimer];
    }
    else if([notif.name isEqualToString:UIApplicationWillResignActiveNotification]){
        [self pauseTimer];
        [_autosaveTimer invalidate];
    }
    else if([notif.name isEqualToString:UIApplicationDidEnterBackgroundNotification]){
        [self submitTest:NO];
    }
    else if([notif.name isEqualToString:@"SHOULD_RESTART_TIMER"]){
        alertViewPresent = NO;
        //[self beginTimer];
    }
    else if([notif.name isEqualToString:UIApplicationDidChangeStatusBarOrientationNotification]){
        [self configureNavTitles];
        [self.tableView reloadData];
        
        [self configureTableView];
    }
}
-(void)pauseTimer{
    [testTimer invalidate];
    self.testTimer = nil;
    if(pauseButtonPressed || alertViewPresent || ![dataModel isTimed] || timeRanOut)
        return;
    NSDate *now = [NSDate date];
    timeOnClock+=[now timeIntervalSinceDate:testStarted];
    timeForCurrentQuestion+=[now timeIntervalSinceDate:previousQuestionAnswered];
    dataModel.unassignedTime = timeForCurrentQuestion;
    dataModel.totalTimeSpentThusFar=timeOnClock;
    //these two ensure that the timer only updates once, not twice, if pausetimer is accidentally called a second time
    self.testStarted = [NSDate date];
    self.previousQuestionAnswered = [NSDate date];
    
}

-(void)timerUpdated:(NSTimer*)timer{
    if(![dataModel isTimed] || timeRanOut)
        return;
    NSInteger minutesInTest = [dataModel lengthOfTest];
    NSInteger timeElapsed = (int)[self timeElapsedInAttempt];
    
    if(minutesInTest != 0 && timeElapsed >= minutesInTest*60){ //time is up, alert something and invalidate timer
        [timer invalidate];
        timeRanOut = YES;
        //[self submitTest:YES];
        [self pauseTimer];
        NSInteger unanswered =dataModel.unansweredQuestions;
        if(unanswered == 0){
            self.tableView.userInteractionEnabled = NO;
            [self submitAction];
        }
        else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Time's up!" message:@"Warning! Unfortunately you have run out of time. You may continue working on unanswered questions to see what you would have gotten, but your tutor will be able to tell which questions were answered after the time ran out. " delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            //alert.tag = 100001;
            [alert show];
            [alert release];
            if([dataModel isTutorBased]){
                [self disablePlayPauseAfterTimeExpires];
            }
            [self.tableView reloadData];
            //[self disableUserInteractionWithAnsweredQuestions];
        }
    }
    else if(minutesInTest != 0 && !fiveMinuteWarningTriggered && minutesInTest*60 - timeElapsed <= minutesLeftForTimeWarning*60){//5 minute warning
        fiveMinuteWarningTriggered = YES;
        [self showTimeWarning];
        //[SVStatusHUD showWithImage:nil status:@"5 minutes left" duration:2.0];
        
    }
    //else{
    if(minutesInTest != 0)
        timeElapsed = minutesInTest*60-timeElapsed;
    //counting up
    NSInteger seconds = timeElapsed%60;
    NSInteger minutes = (timeElapsed-seconds)/60;
    
    UILabel *time = (UILabel*)self.navigationItem.leftBarButtonItem.customView;
    time.text = [NSString stringWithFormat:@"%d:%.2d",minutes,seconds];
        
    //}
    
}
-(void)showTimeWarning{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); 
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"5 minutes left" message:nil delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
    [alert release];
}
-(NSTimeInterval)timeElapsedInAttempt{
    if(testStarted != nil){
        NSDate *now = [NSDate date];
        return [now timeIntervalSinceDate:testStarted] + timeOnClock;
    }
    return timeOnClock;
}

-(NSTimeInterval)timeElapsedSinceLastQuestionWasAnswered{
    NSDate *now = [NSDate date];
    return [now timeIntervalSinceDate:previousQuestionAnswered] + timeForCurrentQuestion;
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated

{

    [self prepareUIApplicationForStart:YES];
    [super viewWillAppear:animated];
}

-(void)prepareUIApplicationForStart:(BOOL)starting{
     [UIApplication sharedApplication].idleTimerDisabled = starting;
    ELAppDelegate *delegate = (ELAppDelegate*)[UIApplication sharedApplication].delegate;
    if(starting)
        delegate.supportediPhoneOrientations = UIInterfaceOrientationMaskAllButUpsideDown;
    else{
        delegate.supportediPhoneOrientations = UIInterfaceOrientationMaskPortrait;
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

//    if([dataModel numberOfRows] == [[self.tableView indexPathsForVisibleRows] count])
//        self.tableView.scrollEnabled = NO;
    [self beginTimer];
    //scroll to first unanswered question. When just starting a test, we will find the first unanswered question to be the first row, so nothing will happen.
    [self scrollToFirstUnansweredQuestion];
    [self configureAutoSaveTimer];
}

-(void)scrollToFirstUnansweredQuestion{
    for(int section = 0; section< [self.dataModel numberOfSections];section++){
        for(int row = 0; row< [self.dataModel numberOfRowsInSection:section]; row++){
            NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
            TSQuestion *question = [dataModel questionAtIndexPath:path];
            if(question.choice == Choice_None){
                if(section != 0 || row != 0){
                    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
                }
                return;
            }
        }
    }
}

-(void)configureAutoSaveTimer{
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    [_autosaveTimer invalidate];
    self.autosaveTimer = [NSTimer timerWithTimeInterval:15.f target:self selector:@selector(backupProgressThusFar) userInfo:nil repeats:YES];
    [runloop addTimer:self.autosaveTimer forMode:NSRunLoopCommonModes];
    [runloop addTimer:self.autosaveTimer forMode:UITrackingRunLoopMode];
}
-(void)backupProgressThusFar{
    ELAppDelegate *delegate = [ELAppDelegate sharedDelegate];
    NSInteger uid = delegate.activeUser.object_id;
    
    
    
    [GenericTestUploadHTTPRequest saveProgressInTest:[[dataModel dictionaryRepresentation] JSONRepresentation] forUser:uid assignmentID:dataModel.assignmentID completed:NO sectionName:dataModel.sectionName];
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
    return [dataModel numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [dataModel numberOfRowsInSection:section];
}
- (NSArray *) sectionIndexTitlesForTableView: (UITableView *) tableView {
    if([dataModel numberOfRows] <= 10)
        return nil;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[dataModel numberOfRows]];
    
    for(TSQuestion *question in dataModel.questions){
        [array addObject:[NSString stringWithFormat:@"%d",question.questionNumber]];
    }
    return array;
} // sectionIndexTitles


- (NSInteger) tableView: (UITableView *) tableView
sectionForSectionIndexTitle: (NSString *) title
                atIndex: (NSInteger) index {
    //touchedTableIndex = YES;
    NSIndexPath *path = [dataModel indexPathOfQuestion:index];
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    return NSNotFound;
    //return [dataModel sectionOfQuestion:index];
} 

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    float height,fontSize;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        height = 45;
        fontSize = 29.0f;
    }
    else{
        height = 35;
        fontSize = 22.0f;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-40, height)];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.bounds.size.width-40, height)];
    title.backgroundColor = [UIColor clearColor];
    title.textColor = THIRTY_SIX_DEFAULT_BUBBLE_COLOR;
    //title.shadowOffset = CGSizeMake(1, 1);
    //title.shadowColor = [UIColor lightGrayColor];
    title.font = [UIFont systemFontOfSize:fontSize];
    title.text = [dataModel titleForSection:section];
    title.adjustsFontSizeToFitWidth = YES;
    title.textAlignment = UITextAlignmentLeft;
    [view addSubview:title];
    [title release];
    return [view autorelease];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if([dataModel titleForSection:section] == nil)
        return 0;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return 45;
    else
        return 35;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   
//    if(!indexModified){
//        for(UIView *view in [tableView subviews])
//        {
//            if([[[view class] description] isEqualToString:@"UITableViewIndex"])
//            {
//                [view performSelector:@selector(setIndexColor:) withObject:THIRTY_SIX_DEFAULT_BUBBLE_COLOR ];
//                [view performSelector:@selector(setFont:) withObject:[UIFont fontWithName:THIRTY_SIX_DEFAULT_FONT_NAME size:12.0]];
//                indexModified = YES;
//                break;
//            }
//        }
//    }
    NSInteger index = [dataModel questionIndexForIndexPath:indexPath];
    NSInteger questionNumber = [dataModel questionNumberForIndex:index];
    TSQuestion *question = [dataModel questionAtIndexPath:indexPath];
    
    
    MCTableViewCell *cell = nil;
    
    
    if(questionNumber % 2 != 0){
        static NSString *CellIdentifierEvenPortrait = @"EvenPortrait";
        static NSString *CellIdentifierEvenLandscape = @"EvenLandscape";
        NSString *identifier;
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            identifier = CellIdentifierEvenPortrait;
        } else {
            identifier = CellIdentifierEvenLandscape;
        }
        
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[[MCTableViewCell alloc] initWithNumberOfChoices:dataModel.numChoices offset:NO tutor:[dataModel isTutorBased] orientation:orientation reuseIdentifier:identifier] autorelease];
            //[cell.questionNumber addTarget:self action:@selector(tagQuestion:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    else {
        static NSString *CellIdentifierOddPortrait = @"OddPortrait";
        static NSString *CellIdentifierOddLandscape = @"OddLandscape";
        NSString *identifier;
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            identifier = CellIdentifierOddPortrait;
        } else {
            identifier = CellIdentifierOddLandscape;
        }
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[[MCTableViewCell alloc] initWithNumberOfChoices:dataModel.numChoices offset:YES tutor:[dataModel isTutorBased] orientation:orientation reuseIdentifier:identifier] autorelease];
            //[cell.questionNumber addTarget:self action:@selector(tagQuestion:) forControlEvents:UIControlEventTouchUpInside];
            
        }
    }
    if([dataModel isTutorBased])
        cell.multipleChoiceControl.correctAnswer = [[dataModel.correct_answers objectAtIndex:index] intValue];
    cell.multipleChoiceControl.tag = index;
    cell.questionNumber.tag = questionNumber-1;
    
    [cell.questionNumber setTitle:[NSString stringWithFormat:@"%d.",questionNumber] forState:UIControlStateNormal];
    //NSLog(@"%@, index = %d",[question dictionaryRepresentation],(dataModel.numChoices+[question choice])%(dataModel.numChoices+1));
    
    //remove target to make sure cell doesn't trigger when setting initial index
    [cell.multipleChoiceControl removeTarget:self action:@selector(choiceChanged:) forControlEvents:UIControlEventValueChanged];
    [cell.multipleChoiceControl moveThumbToChoice:[question choice] animate:NO];
//    [cell.multipleChoiceControl moveThumbToIndex:(dataModel.numChoices+[question choice])%(dataModel.numChoices+1) animate:NO];
    [cell.multipleChoiceControl addTarget:self action:@selector(choiceChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    cell.multipleChoiceControl.userInteractionEnabled = !timeRanOut || ([question choice] == Choice_None || question.uploadedAfterTimeLimit); 
    //if(!cell.multipleChoiceControl.userInteractionEnabled)
       //cell.multipleChoiceControl.thumb.tintColor = [UIColor grayColor];
    // Configure the cell...
    
    return cell;
}
-(void)tagQuestion:(UIButton*)button{
    NSInteger q_index = button.tag;
    AddQuestionTagViewController *vc = [[AddQuestionTagViewController alloc] init];
    vc.contentType = dataModel.contentType;
    vc.objectID = dataModel.objectID;
    vc.questionIndex = q_index;
    vc.sectionName = dataModel.sectionName;
    [self pauseTimer];
    alertViewPresent = YES;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    //navigationController.navigationBar.tintColor = kDefaultToolbarColor;
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navigationController animated:YES];
    [vc release];
    [navigationController release];
    
    
}
-(void)choiceChanged:(MCStyledControl*)control{
    TSQuestion *question =[dataModel.questions objectAtIndex:control.tag];

    
    
    self.tableView.userInteractionEnabled = NO;
    

//    NSInteger selectedIndex = control.selectedIndex;
//    selectedIndex=(selectedIndex+1)%(dataModel.numChoices+1);
//    NSInteger selectedindex = 
//    question.choice = selectedIndex;
    question.choice = [control selectedChoice];
    if([dataModel isTimed]/* && !timeRanOut*/){
        NSTimeInterval timeElapsed = [self timeElapsedSinceLastQuestionWasAnswered];
        self.previousQuestionAnswered = [NSDate date];
        timeForCurrentQuestion = 0;
        question.timeSpent+=timeElapsed;
    }
    if(timeRanOut){
        //if([dataModel isTimed]){
        //question.timeSpent+=timeForCurrentQuestion;
        //timeForCurrentQuestion=0;
        //}
        question.uploadedAfterTimeLimit = YES;
    }

    if([dataModel numberOfRows] == [[self.tableView indexPathsForVisibleRows] count]){
        self.tableView.userInteractionEnabled = YES;
        return;
    }
    
    [self backupProgressThusFar];
    


    
    //scroll
    self.tableView.userInteractionEnabled = YES;
    
    [self performSelector:@selector(scrollAfterChoiceSelected:) withObject:control afterDelay:0.6];
}

-(void)scrollAfterChoiceSelected:(MCStyledControl*)control{
    NSArray *visibleQuestions = [self.tableView indexPathsForVisibleRows];
    
    CGFloat threshold = 0.6f;
    NSInteger answeredQuestions = 0;
    NSIndexPath *unansweredQuestion = nil;
    NSIndexPath *start = [visibleQuestions objectAtIndex:0];
    bool stopSearching = FALSE;
    for(int section = start.section; section< [self.dataModel numberOfSections];section++){
        for(int row = start.row; row< [self.dataModel numberOfRowsInSection:section]; row++){
            NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
            TSQuestion *question = [dataModel questionAtIndexPath:path];
            if(question.choice == Choice_None){
                unansweredQuestion = path;
                stopSearching = TRUE;
                break;
            }
            else{
                
                    answeredQuestions++;
                
            }
        }
        if(stopSearching)
            break;
    }
    if(answeredQuestions > [visibleQuestions count]*threshold){
        
        
        NSInteger minIndex = MIN(control.tag,[dataModel questionIndexForIndexPath:unansweredQuestion]);
        NSInteger questionNumber = [dataModel questionNumberForIndex:minIndex];
        NSIndexPath *path = [dataModel indexPathOfQuestionNumber:questionNumber];
        [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
    }
    
    
    
//    if(unansweredQuestion != nil && [dataModel questionIndexForIndexPath:unansweredQuestion] > control.tag){
//        //if(unansweredQuestion.row == otherQuestion.row && unansweredQuestion.section == otherQuestion.section)
//        [self.tableView scrollToRowAtIndexPath:unansweredQuestion atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    }
//    else{
//        //need to get index of next cell
//        NSIndexPath *lastObject = [paths lastObject];
//        NSIndexPath *nextPath = nil;
//        if([self.tableView numberOfRowsInSection:lastObject.section] == lastObject.row+1){
//            if([self.tableView numberOfSections] == lastObject.section+1){
//                NSIndexPath *otherQuestion = nil;
//                for(TSQuestion *question in dataModel.questions){
//                    if(question.choice == Choice_None){
//                        //otherQuestion = [dataModel indexPathOfQuestionObject:question];
//                        break;
//                    }
//                }
//                if(otherQuestion != nil)
//                    [self.tableView scrollToRowAtIndexPath:otherQuestion atScrollPosition:UITableViewScrollPositionTop animated:YES];
//                else
//                    [self.tableView scrollToRowAtIndexPath:lastObject atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//                return;
//            }
//            //TODOTODOTODOmust make sure not in last section
//            nextPath = [NSIndexPath indexPathForRow:0 inSection:lastObject.section+1];
//        }
//        else
//            nextPath = [NSIndexPath indexPathForRow:lastObject.row+1 inSection:lastObject.section];
    
        //[self.tableView scrollToRowAtIndexPath:nextPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
    //}
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
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if(touchedTableIndex){
//        touchedTableIndex = NO;
//        CGPoint offset = scrollView.contentOffset;
//        offset.y-=self.tableView.contentInset.top;
//        scrollView.contentOffset = offset;
//        
//    }
//}

@end
