//
//  TestQueueViewController.m
//  MC HW
//
//  Created by Eric Lubin on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestQueueViewController.h"
#import "TSTest.h"
#import "TSSection.h"
#import "TestTakingViewController.h"
#import "GenericTestUploadHTTPRequest.h"
@implementation TestQueueViewController
@synthesize test;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationPageSheet;
        
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!IS_IOS_7) {
        self.navigationController.navigationBar.tintColor = nil;
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    } else {
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;

    }
    self.navigationItem.title = test.testID;
    //self.tableView.backgroundColor = kDefaultTableViewBackgroundColor;
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(closeTest)] autorelease];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)closeTest{
    if(test.started)
        [[NSNotificationCenter defaultCenter] postNotificationName:THIRTY_SIX_ASSIGNMENT_STATUS_DID_CHANGE object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:test.assignmentID] forKey:@"id"]];
    
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}
- (void)dealloc {
    [test release];
    [super dealloc];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(test.complete){
        
        [self dismissModalViewControllerAnimated:animated];
        [[NSNotificationCenter defaultCenter] postNotificationName:THIRTY_SIX_DID_COMPLETE_ASSIGNMENT object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:test.assignmentID] forKey:@"id"]];
    }
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [test.sections count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        
        
    }
    TSSection *section = [test.sections objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [section sectionName];
    if(section.complete){
        
        cell.imageView.image = [UIImage imageNamed:@"checkmark"];
        cell.imageView.highlightedImage = cell.imageView.image;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //cell.imageView.highlightedImage = [UIImage imageNamed:@"ActiveCheckbox_pressed"];
        
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        if(section.started){
            cell.imageView.image = [UIImage imageNamed:@"unread_partial"];
            cell.imageView.highlightedImage = [UIImage imageNamed:@"unread_partial_pressed"];
        }
        else{
            cell.imageView.image = [UIImage imageNamed:@"unread"];
            cell.imageView.highlightedImage = [UIImage imageNamed:@"unread_pressed"];
        }
            
    }

    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TSSection *section = [test.sections objectAtIndex:indexPath.row];
    section.assignmentID = test.assignmentID;
    if(section.complete)
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    else{
        TestTakingViewController *testVC = [[TestTakingViewController alloc] initWithDataModel:section];

        testVC.partOfTest = YES;
        
        [self.navigationController pushViewController:testVC animated:YES];
        [testVC release];
    }
}
@end
