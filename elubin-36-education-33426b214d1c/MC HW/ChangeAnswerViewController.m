//
//  ChangeAnswerViewController.m
//  MC HW
//
//  Created by Eric Lubin on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChangeAnswerViewController.h"
#import "MCStyledControl.h"
@interface ChangeAnswerViewController ()
@property (nonatomic,retain) MCStyledControl *activeControl;
@end
NSString * const THIRTY_SIX_DID_MODIFY_ANSWER = @"DID_MODIFY_PREVIOUS_ANSWER";
@implementation ChangeAnswerViewController
@synthesize attemptID,previousChoice,numberOfChoices,parentString,activeControl,correctAnswer,questionIndex;
-(id)initWithNumberOfChoices:(NSInteger)choices{
    if(self = [super init]){
        numberOfChoices=choices;

        self.contentSizeForViewInPopover = CGSizeMake([MCStyledControl totalWidthForNumChoices:numberOfChoices orientation:UIInterfaceOrientationPortrait]+6,[MCStyledControl sizeofCellForNumChoices:numberOfChoices orientation:UIInterfaceOrientationPortrait]+6);
    }
    return self;
}
- (void)dealloc
{
    
    [parentString release];
    [activeControl release];
    [super dealloc];
}
- (void)viewDidLoad
{
    //self.view.backgroundColor = kDefaultTableViewBackgroundColor;
    //self.navigationController.navigationBar.tintColor = kDefaultToolbarColor;
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    MCStyledControl *control = [[MCStyledControl alloc] initWithNumberOfChoices:numberOfChoices offset:questionIndex%2 orientation:UIInterfaceOrientationPortrait];
    control.center = CGPointMake(self.contentSizeForViewInPopover.width/2,self.contentSizeForViewInPopover.height/2);
    [control addTarget:self action:@selector(saveChanges) forControlEvents:UIControlEventValueChanged];
    control.correctAnswer = correctAnswer;
    [self.view addSubview:control];
    self.activeControl = control;
    [control release];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEditing)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveChanges)] autorelease];
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
        self.navigationItem.title = [NSString stringWithFormat:@"Question %d",questionIndex+1];
    else
        self.navigationItem.title = [NSString stringWithFormat:@"Q%d",questionIndex+1];
    
    
    self.navigationItem.prompt = parentString;
    [control moveThumbToChoice:previousChoice animate:NO];
    //[control moveThumbToIndex:prev animate:<#(BOOL)#>
	// Do any additional setup after loading the view.
}


-(void)cancelEditing{
    [[NSNotificationCenter defaultCenter] postNotificationName:MC_GRADES_SHOULD_DISMISS_POPOVER object:nil];
}
-(void)saveChanges{
    if(activeControl.selectedChoice == previousChoice){
        [self cancelEditing];
    }
    else{
        TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:[NSString stringWithFormat:@"modify_answer/%d/?choice=%d",attemptID,activeControl.selectedChoice]];
        
        request.useSVProgressHUD = YES;
        request.progressMaskType = SVProgressHUDMaskTypeClear;
        request.completionBlock = ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:THIRTY_SIX_DID_MODIFY_ANSWER object:nil];
            [self cancelEditing];
        };
        [request startAsynchronous];
    }
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    self.activeControl = nil;
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
