//
//  EditDueDateViewController.m
//  iSHS
//
//  Created by Eric Lubin on 7/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EditDueDateViewController.h"
@interface EditDueDateViewController()
-(void)dateChanged:(UIDatePicker*)sender;
-(void)previousPage;
-(void)saveChanges;
@end;

@implementation EditDueDateViewController
@synthesize assignment,picker,df;

#pragma mark -
#pragma mark Initialization


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
        self.contentSizeForViewInPopover = CGSizeMake(320,440);
    }
    return self;
}



#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    if(IS_IOS_7 && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        self.tableView.backgroundColor = kDefaultTableViewBackgroundColor;
    
    //if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        //self.contentSizeForViewInPopover = CGSizeMake(320, 360);
	self.navigationItem.title = @"Edit Due Date";
	self.df = [[[NSDateFormatter alloc] init] autorelease];
    
    df.dateFormat = @"EEEE, MMMM d, yyyy";
    
	self.tableView.scrollEnabled = NO;
	
	//self.tableView.backgroundColor = kDefaultTableViewBackgroundColor;
    id activeDate = [assignment valueForKey:@"due_date"];
	if(activeDate == nil || activeDate == [NSNull null]){
		activeDate = [NSDate date];
 
        self.tableView.contentInset = UIEdgeInsetsMake(42.0+24, 0, 216, 0);
	}
	else {
        activeDate = [NSDate dateWithTimeIntervalSince1970:[activeDate intValue]];
		self.tableView.contentInset = UIEdgeInsetsMake(35, 0, 216, 0);
	}
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	
    CGRect datePickerFrame;
    
    if(IS_IOS_7){
        datePickerFrame = CGRectMake(0, self.view.bounds.size.height - 328, self.view.bounds.size.width, 216);
    } else {
        
        datePickerFrame = CGRectMake(0,self.view.bounds.size.height-216-self.tableView.contentInset.top,self.view.bounds.size.width,216);
    }
	UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:datePickerFrame];
    self.picker = datePicker;
    datePicker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	datePicker.datePickerMode = UIDatePickerModeDate;
	datePicker.date = activeDate;
	[datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    
    if(IS_IOS_7){
        datePicker.backgroundColor = [UIColor whiteColor];
        
    }
	[self.view addSubview:datePicker];
	[datePicker release];
	
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(previousPage)];
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveChanges)];
    //discard changes uiactionsheet
	
	self.navigationItem.leftBarButtonItem = leftButton;
	self.navigationItem.rightBarButtonItem = rightButton;
	[leftButton release];
	[rightButton release];
}

-(void)dateChanged:(UIDatePicker*)sender{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UILabel *dateString = (UILabel*)[cell viewWithTag:18];
    dateString.text = [df stringFromDate:picker.date];
}
-(void)previousPage{
    
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)saveChanges{
	//parentController.activeAssignment.dueDate = selectedDate;
	[assignment setValue:[NSString stringWithFormat:@"%.0f",[picker.date timeIntervalSince1970]] forKey:@"due_date"];
	[self previousPage];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

// Override to allow orientations other than the default portrait orientation.
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
     id activeDate = [assignment valueForKey:@"due_date"];
	if(activeDate == nil || activeDate == [NSNull null])
		return 1;
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		//cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
		//cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
		UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width/320*300,44)];
		date.backgroundColor = [UIColor clearColor];
		date.center = CGPointMake(self.view.bounds.size.width/2, 22);
		date.tag = 18;
		date.textAlignment = UITextAlignmentCenter;
		date.highlightedTextColor = [UIColor whiteColor];
		[cell addSubview:date];
		[date release];
	}
	UILabel *label = (UILabel*)[cell viewWithTag:18];
	if(indexPath.section == 0){
		label.text = [df stringFromDate:picker.date];
		label.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
		label.textColor = [UIColor blackColor];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	else if(indexPath.section == 1){
		label.text = @"Remove Due Date";
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		label.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
		label.textColor = [UIColor colorWithRed:0.22 green:.33 blue:.53 alpha:1];
	}
	
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 1){
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove Due Date" otherButtonTitles:nil];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
        else{
			if(self.tabBarController == nil)
				[actionSheet showInView:self.view];
			else
				[actionSheet showInView:self.tabBarController.view];
		}
        
		[actionSheet release];
	}
	
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(buttonIndex == 0){
        [assignment setValue:[NSNull null] forKey:@"due_date"];
        [self previousPage];
	}
	else if(buttonIndex == 1){
		[self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:YES];
		
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    self.picker = nil;
    self.df = nil;
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[assignment release];
    [picker release];
    [super dealloc];
}
/*
#pragma mark -
#pragma mark PopoverDelegate
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    return NO;
}*/

@end

