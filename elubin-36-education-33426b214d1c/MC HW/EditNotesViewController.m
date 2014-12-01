//
//  EditNotesViewController.m
//  iSHS
//
//  Created by Eric Lubin on 7/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EditNotesViewController.h"
@interface EditNotesViewController()

-(void)previousPage;
-(void)saveChanges;
@end


@implementation EditNotesViewController
@synthesize assignment;

#pragma mark -
#pragma mark Initialization


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
        self.contentSizeForViewInPopover = CGSizeMake(320,228);
    }
    return self;
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}
#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    if(IS_IOS_7 && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        self.tableView.backgroundColor = kDefaultTableViewBackgroundColor;
    self.tableView.allowsSelection = NO;
    //self.tableView.backgroundColor = kDefaultTableViewBackgroundColor;

	self.tableView.delegate = self;
	self.tableView.scrollEnabled = NO;
    //if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
        self.tableView.rowHeight = 200-self.navigationController.navigationBar.frame.origin.y;
    //else
       // self.tableView.rowHeight = 600;
	self.navigationItem.title = @"Edit Notes";
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(previousPage)];
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveChanges)];
    //discard changes uiactionsheet
	
	self.navigationItem.leftBarButtonItem = leftButton;
	self.navigationItem.rightBarButtonItem = rightButton;
	[leftButton release];
	[rightButton release];
}

-(void)previousPage {
	
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)saveChanges {
	//save notes
	/*
	NSMutableArray *assignments = [(parentController.dataManager assignmentsForPeriod:parentController.currentPeriod];
	if([self isNewNote]){
		assignment *newAssignment = [[assignment alloc] init];
		newAssignment.notes = keyBoard.text;
		[assignments addObject:newAssignment];
		[newAssignment release];
	}*/
	
	//parentController.activeAssignment.notes = keyBoard.text;
    [assignment setValue:keyBoard.text forKey:@"notes"];
	[self previousPage];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}*/


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[keyBoard becomeFirstResponder];
		[self.navigationController setToolbarHidden:YES animated:animated];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	[keyBoard resignFirstResponder];
}

/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/






#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    static NSInteger kTextViewTag = 99;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(5, 5, cell.contentView.bounds.size.width-20, self.tableView.rowHeight-10)];
		text.tag = kTextViewTag;
		text.font = [UIFont systemFontOfSize:16];
		text.backgroundColor = [UIColor clearColor];
		text.textColor = [UIColor colorWithRed:0.22 green:.33 blue:.53 alpha:1];
		[cell.contentView addSubview:text];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		[text release];
	}
    UITextView *textView = (UITextView*)[cell.contentView viewWithTag:kTextViewTag];
	textView.text = [assignment valueForKey:@"notes"];
    // Configure the cell...
    keyBoard = textView;
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
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	scrollView.delegate = nil;
	[scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)dealloc {
	[assignment release];
    [super dealloc];
}


@end

