//
//  ChooseTutorViewController.m
//  MC HW
//
//  Created by Eric Lubin on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChooseTutorViewController.h"
#import "JSONToObjC.h"
#import "AssignmentInfoViewController.h"
//#import "ELAppDelegate.h"
@interface ChooseTutorViewController ()
@property (nonatomic,strong) NSArray *tutors;
@property (nonatomic) NSInteger selectedTutorID;
@end

@implementation ChooseTutorViewController
@synthesize studentID,tutors,selectedTutorID,contentType,objectID,assignment;
- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.contentSizeForViewInPopover = CGSizeMake(320,400);
        // Custom initialization
    }
    return self;
}
- (void)dealloc
{
    [assignment release];
    [tutors release];
    [super dealloc];
}

-(NSString*)uniqueURLPath{
    return [NSString stringWithFormat:@"students/%d/tutors/",studentID];
}

-(void)reloadTableViewDataSource{
    __block TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:[self uniqueURLPath]];
    //request.requestContainer = self;
    request.completionBlock = ^{
        [self doneLoadingTableViewDataWithSuccess:YES];
        
        NSArray *response = [request.responseData JSONValue];
        self.tutors = response;
        [self.tableView reloadData];
    };
    request.failedBlock = ^{
        [self doneLoadingTableViewDataWithSuccess:NO];
    };
    [request startAsynchronous];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadTableViewDataSource];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Tutors";
    //self.tableView.backgroundColor = kDefaultTableViewBackgroundColor;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return @"Choose a tutor to whom this assignment will be related.";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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
    return [tutors count] >0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [tutors count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [[tutors objectAtIndex:indexPath.row] valueForKey:@"full_name"];
    // Configure the cell...
    
    return cell;
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

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    __block TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:[NSString stringWithFormat:@"hw/start/ct/%d/id/%d/tutor_id/%d/?timed=%d",contentType,objectID,selectedTutorID,buttonIndex]];
    //request.requestContainer = self;
    request.completionBlock = ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:THIRTYSIX_ED_DID_ADD_ASSIGNMENT object:nil];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            [[NSNotificationCenter defaultCenter] postNotificationName:MC_GRADES_SHOULD_DISMISS_POPOVER object:nil];
            UIViewController *vc = testTakingViewControllerFromJson([request.responseData JSONValue],assignment);
            //vc.modalPresentationStyle = UIModalPresentationPageSheet;
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
            nc.modalPresentationStyle = UIModalPresentationPageSheet;
            [vc release];
            
            [self.view.window.rootViewController presentModalViewController:nc animated:YES];
            [nc release];
        }
        else
            [self.navigationController pushViewController:testTakingViewControllerFromJson([request.responseData JSONValue],assignment) animated:YES];
        
    };
    [request startAsynchronous];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    NSDictionary *tutor = [tutors objectAtIndex:indexPath.row];
    selectedTutorID = [[tutor valueForKey:@"id"] integerValue];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Timed test?" message:@"Please select if you would like this test to be timed" delegate:self cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
    
    [alertView show];
    [alertView release];
}

@end
