//
//  LeftViewControllerContainerSVC.m
//  MC HW
//
//  Created by Eric Lubin on 10/26/12.
//
//

#import "LeftViewControllerContainerSVC.h"
#import "TutorActionsViewController.h"
#import "ThirtySixTutorStudentPickerViewController.h"

@interface LeftViewControllerContainerSVC ()
@property (nonatomic,strong) TutorActionsViewController *tutorActions;
@property (nonatomic,strong) ThirtySixTutorStudentPickerViewController *studentPicker;
@end


typedef enum{
    UIScreenSizeNeedsAll = 1 << 0,
    UIScreenSizeNeedsSome = 1 << 1,
    UIScreenSizeNeedsNone = 1 << 2,
    UIScreenSizeNotValid = 0,
} UIScreenSizeNeeded;

@implementation LeftViewControllerContainerSVC

- (id)init
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        
        // Custom initialization
    }
    return self;
}
-(BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation{
    return NO;
}

static CGFloat const defaultStudentProportion = 320;
//static CGFloat const defaultSearchProportion = 600;
- (void)viewDidLoad
{
    [super viewDidLoad];
    _studentPicker= [[ThirtySixTutorStudentPickerViewController alloc] init];
    _tutorActions = [[TutorActionsViewController alloc] init];
    
    _tutorActions.tutor = _tutor;
    self.tutorActions.studentPicker = _studentPicker;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:_tutorActions];
    [self addChildViewController:nc];
    
    [self.view addSubview:nc.view];
    
    
    
    UINavigationController *nc2 = [[UINavigationController alloc] initWithRootViewController:_studentPicker];
    //if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
    nc2.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    nc2.navigationBar.tintColor = nil;
    
    [self addChildViewController:nc2];
    
    [self.view addSubview:nc2.view];
    //self.studentPicker.allStudents = _tutor.students;
    self.studentPicker.tutor = _tutor;
    
    
    [self layoutViewControllersForLayout:UIScreenSizeNeedsSome];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:NEEDS_MORE_SCREEN_REAL_ESTATE object:self.studentPicker];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:NEEDS_LESS_SCREEN_REAL_ESTATE object:self.studentPicker];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:NEEDS_NO_SCREEN_REAL_ESTATE object:self.studentPicker];
    //TODO: must add array of students to USER OBJECT
    
	// Do any additional setup after loading the view.
}

-(void)viewDidUnload{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)receivedNotification:(NSNotification*)notification{
    
    UIScreenSizeNeeded screenSize =  ([notification.name isEqualToString:NEEDS_MORE_SCREEN_REAL_ESTATE] << 0) | ([notification.name isEqualToString:NEEDS_LESS_SCREEN_REAL_ESTATE] << 1) | ([notification.name isEqualToString:NEEDS_NO_SCREEN_REAL_ESTATE] << 2);
    
    if(screenSize != UIScreenSizeNotValid){
        
        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
            
            [self layoutViewControllersForLayout:screenSize];
            
        }
        completion:^(BOOL finished) {
            [self.studentPicker scrollToSelectedUser:NO];
        }];
        
        
    }
}

-(void)layoutViewControllersForLayout:(UIScreenSizeNeeded)layout{
    
    CGFloat heightOfBottomVC = 0;
    
    if(layout == UIScreenSizeNeedsNone){
        heightOfBottomVC = 44;
    }
    else{
        heightOfBottomVC = defaultStudentProportion;
    }
    self.tutorActions.navigationController.view.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height-heightOfBottomVC);

    if(layout != UIScreenSizeNeedsAll){
        self.studentPicker.navigationController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        self.studentPicker.navigationController.view.frame = CGRectMake(0,self.tutorActions.navigationController.view.bounds.size.height,self.view.bounds.size.width,heightOfBottomVC);
    }
    else{
        self.studentPicker.navigationController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.studentPicker.navigationController.view.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);
    }
}



-(BOOL)shouldAutorotate{

    return YES;
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
