//
//  AttemptFilterViewController.m
//  MC HW
//
//  Created by Eric Lubin on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AttemptFilterViewController.h"
#import "SVSegmentedControl.h"
NSString * const THIRYSIX_DID_CHANGE_FILTER_PARAMS = @"THIRTYSIX CHANGED FIlter";
@interface SVSegmentedControl ()
@property (nonatomic, strong) NSMutableArray *titlesArray;
@end

@interface AttemptFilterViewController ()
@property (nonatomic,retain) SVSegmentedControl *sectionFilter;
@property (nonatomic,retain) SVSegmentedControl *assignmentTypeFilter;
@property (nonatomic,retain) SVSegmentedControl *aidedFilter;
@property (nonatomic,retain) NSArray *titleArrays1;
@property (nonatomic,retain) NSArray *titleArrays2;
@property (nonatomic,retain) NSArray *titleArrays3;
//old states

//@property (nonatomic) NSInteger oldSectionFilterIndex;
//@property (nonatomic) NSInteger oldAssignmentTypeFilter;
//@property (nonatomic) NSInteger oldAidedFilterIndex;
@end

@implementation AttemptFilterViewController
@synthesize titleArrays1,titleArrays2,titleArrays3;

@synthesize sectionFilter,assignmentTypeFilter,aidedFilter,oldStateBitMask;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        self.titleArrays1=[NSArray arrayWithObjects:@"All",@"English",@"Math",@"Reading",@"Science", nil];
        self.titleArrays2=[NSArray arrayWithObjects:@"All",@"Tests",@"Sections",@"Passages", nil];
        self.titleArrays3=[NSArray arrayWithObjects:@"Either",@"Student",@"Tutor", nil];
        self.contentSizeForViewInPopover = CGSizeMake(320, 195);
        // Custom initialization
    }
    return self;
}
-(void)updateViewForBitmask:(NSInteger)bitmask{
    if(![self isViewLoaded])
        return;
    NSInteger index3 = bitmask %5;
    bitmask-=index3;
    bitmask/=5;
    NSInteger index2 = (bitmask)%5;
    bitmask-=index2;
    bitmask/=5;
    NSInteger index1= (bitmask);
    
    [sectionFilter moveThumbToIndex:index1 animate:NO];
    [assignmentTypeFilter moveThumbToIndex:index2 animate:NO];
    [aidedFilter moveThumbToIndex:index3 animate:NO];
    
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    oldStateBitMask = [self activeState];
    
}

-(NSInteger)encodeValuesForSectionFilter:(NSInteger)index1 typeFilter:(NSInteger)index2 aidedFilter:(NSInteger)index3{
    return ((index1*5)+index2)*5+index3;
}
-(NSInteger)activeState{
    if(![self isViewLoaded])
        return oldStateBitMask;
    NSInteger state= [self encodeValuesForSectionFilter:sectionFilter.selectedIndex typeFilter:assignmentTypeFilter.selectedIndex aidedFilter:aidedFilter.selectedIndex];
    
    return state;
    //return ((sectionFilter.selectedIndex*5)+assignmentTypeFilter.selectedIndex*5)+aidedFilter.selectedIndex;
}


-(BOOL)isFilteredBySection{
    NSInteger bitmask = [self activeState];
    NSInteger index3 = bitmask %5;
    bitmask-=index3;
    bitmask/=5;
    NSInteger index2 = (bitmask)%5;
    bitmask-=index2;
    bitmask/=5;
    NSInteger index1= (bitmask);
    return index1 != 0 && index2 >1;
}
-(void)viewWillDisappear:(BOOL)animated{
    NSInteger newStateBitMask = [self activeState];
    
    if(newStateBitMask != oldStateBitMask){
        oldStateBitMask = newStateBitMask;
        [[NSNotificationCenter defaultCenter] postNotificationName:THIRYSIX_DID_CHANGE_FILTER_PARAMS object:self];
        
    }
    [super viewWillDisappear:animated];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if(IS_IOS_7){
        self.view.backgroundColor = kDefaultTableViewBackgroundColor;
    }
    else
        self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    CGFloat width = 160;
    CGFloat initialOffset = 290;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        initialOffset = 35;
    SVSegmentedControl *control1 = [[SVSegmentedControl alloc] initWithSectionTitles:titleArrays1];
    control1.frame = CGRectMake(0,initialOffset,control1.frame.size.width,control1.frame.size.height);
    control1.center = CGPointMake(width,control1.center.y);
    control1.titleEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 7);
    control1.font = [UIFont boldSystemFontOfSize:11.0f];
    control1.height = 40.0f;
    self.sectionFilter = control1;
    [self.view addSubview:control1];
    [control1 release];

    SVSegmentedControl *control2 = [[SVSegmentedControl alloc] initWithSectionTitles:titleArrays2];
    control2.frame = CGRectMake(0,control1.frame.origin.y+control1.bounds.size.height+control1.height,control2.frame.size.width,control2.frame.size.height);
    control2.center = CGPointMake(width,control2.center.y);
//    control2.titleEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 7);
    control2.font = [UIFont boldSystemFontOfSize:11.5f];
    control2.height = 40.0f;
    self.assignmentTypeFilter = control2;
    [self.view addSubview:control2];
    [control2 release];
    
    SVSegmentedControl *control3 = [[SVSegmentedControl alloc] initWithSectionTitles:titleArrays3];
    control3.frame = CGRectMake(0,control2.frame.origin.y+control2.bounds.size.height+control2.height,control3.frame.size.width,control3.frame.size.height);
    
    control3.height = 40.0f;
    self.aidedFilter = control3;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Reset" forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(resetFilters) forControlEvents:UIControlEventTouchUpInside];
    
    [button sizeToFit];
    control3.center = CGPointMake((width*2-button.bounds.size.width-10)/2,control3.center.y);
    
    button.center = CGPointMake(width*2-button.bounds.size.width/2-5,control3.center.y);
//    control3.titleEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 7);
//    control3.font = [UIFont boldSystemFontOfSize:11.0f];
    
    [self.view addSubview:control3];
    [self.view addSubview:button];
    [control3 release];
    [self updateViewForBitmask:oldStateBitMask];
    // Do any additional setup after loading the view from its nib.
}
-(void)resetFilters{
    [sectionFilter moveThumbToIndex:0 animate:YES];
    [aidedFilter moveThumbToIndex:0 animate:YES];
    [assignmentTypeFilter moveThumbToIndex:0 animate:YES];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.sectionFilter = nil;
    self.assignmentTypeFilter = nil;
    self.aidedFilter = nil;
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)dealloc
{
    [sectionFilter release];
    [assignmentTypeFilter release];
    [aidedFilter release];
    [titleArrays1 release];
    [titleArrays2 release];
    [titleArrays3 release];
    [super dealloc];
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

-(NSString*)filterGetRequest{
    if(oldStateBitMask == 0)
        return nil;
    
    NSMutableString *filter = [NSMutableString string];
    
    
    NSInteger bitmask = [self activeState];
    NSInteger index3 = bitmask %5;
    bitmask-=index3;
    bitmask/=5;
    NSInteger index2 = (bitmask)%5;
    bitmask-=index2;
    bitmask/=5;
    NSInteger index1= (bitmask);
    
    if(index3 > 0 && index3 <[titleArrays3 count])
        [filter appendFormat:@"tracking_info=%d&",index3-1];
    if(index1 != 0 && index1 < [titleArrays1 count])
        [filter appendFormat:@"section_type=%@&",[titleArrays1 objectAtIndex:index1]];
    if(index2 != 0 && index2 < [titleArrays2 count])
        [filter appendFormat:@"type=%@",[titleArrays2 objectAtIndex:index2]];
    if([filter length] >0 && [[filter substringFromIndex:[filter length]-1] isEqualToString:@"&"])
        [filter deleteCharactersInRange:NSMakeRange([filter length]-1, 1)];
    
    return filter;
}
-(NSString*)prettyFilterString{
    if(oldStateBitMask == 0)
        return nil;
    NSInteger bitmask = [self activeState];
    NSInteger index3 = bitmask %5;
    bitmask-=index3;
    bitmask/=5;
    NSInteger index2 = (bitmask)%5;
    bitmask-=index2;
    bitmask/=5;
    NSInteger index1= (bitmask);
    
    
    NSMutableArray *filters = [NSMutableArray array];
    if(index2 != 0 && index2 < [titleArrays2 count])
        [filters addObject:[titleArrays2 objectAtIndex:index2]];
    
    
    if(index1 != 0 && index1 < [titleArrays1 count])
        [filters addObject:[titleArrays1 objectAtIndex:index1]];

    
    if(index3 != 0 && index3 < [titleArrays3 count])
        [filters addObject:[titleArrays3 objectAtIndex:index3]];
           
    return [NSString stringWithFormat:@"Filter: %@",[filters componentsJoinedByString:@", "]];
    
}
@end
