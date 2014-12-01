//
//  AggregationFilterViewController.m
//  MC HW
//
//  Created by Eric Lubin on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AggregationFilterViewController.h"
#import "SVSegmentedControl.h"
#import "StudentSelectionViewController.h"
@interface AggregationFilterViewController ()
@property (nonatomic,retain) NSSet *students;
@property (nonatomic,retain) SVSegmentedControl *control1;
@property (nonatomic) NSInteger selectedIndex;
@end

@implementation AggregationFilterViewController
@synthesize students,control1,selectedIndex;
- (void)dealloc
{
    [students release];
    [control1 release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
- (id)initWithStudents:(NSSet*)studs tutorAided:(NSInteger)integer
{
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.contentSizeForViewInPopover = CGSizeMake(320,300);
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(doneEditingFilter)] autorelease];
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelFilter)] autorelease];
        self.navigationItem.title = @"Filter Results";
        self.students = studs;
        selectedIndex = integer;
        // Custom initialization
    }
    return self;
}
-(void)doneEditingFilter{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DID_MODIFY_FILTER_PARAMS_FOR_AGGREGATION" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:control1.selectedIndex],@"tutorAided",students,@"students", nil]];
    [self cancelFilter];
}

-(void)cancelFilter{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [[NSNotificationCenter defaultCenter] postNotificationName:MC_GRADES_SHOULD_DISMISS_POPOVER  object:nil];
    }
    else{
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(studentsChanged:) name:@"DID_SELECT_NEW_FILTER_GROUP" object:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.tableView reloadData];
}
-(void)studentsChanged:(NSNotification*)notif{
    NSSet *studs = [notif.userInfo valueForKey:@"users"];
    self.students = [studs valueForKey:@"id"];
    [self.tableView reloadData];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    self.control1 = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return 1;
}
-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if(section == 0)
        return @"Choose whether you would like to see only attempts submitted by students, tutors, or both.";
    else
        return @"Choose which of the following students you would like to be included in the results.";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    if(indexPath.section ==0){
        UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        SVSegmentedControl *control3 = [[[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"Either",@"Student",@"Tutor",nil]] autorelease];
        control3.selectedIndex = selectedIndex;
        self.control1 = control3;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        control3.center = CGPointMake(cell.bounds.size.width/2,cell.bounds.size.height/2);
        
        //control3.height = 40.0f;
        [cell addSubview:control3];
        
        
        return cell;
    }
    else{
        UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if([students count] > 1){
            cell.textLabel.text = [NSString stringWithFormat:@"%d students",[students count]];
        }
        else{
            cell.textLabel.text = [NSString stringWithFormat:@"%d student",[students count]];
        }
        
        return cell;
    }
    
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
    if(indexPath.section == 1){
        StudentSelectionViewController *vc = [[StudentSelectionViewController alloc] initWithStyle:UITableViewStylePlain];
        NSMutableSet *set = [NSMutableSet setWithCapacity:[students count]];
        for(NSNumber *uid in students){
            [set addObject:[NSDictionary dictionaryWithObject:uid forKey:@"id"]];
        }
        
        vc.selectedUsers = set;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
}

@end
