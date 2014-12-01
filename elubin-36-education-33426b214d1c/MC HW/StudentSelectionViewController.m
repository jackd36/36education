//
//  StudentSelectionViewController.m
//  MC HW
//
//  Created by Eric Lubin on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StudentSelectionViewController.h"
#import "NSObject+SBJson.h"



@interface StudentSelectionViewController()
-(void)loadStudents;
-(void)initToolbar;
-(void)updateToolbar;

@end
@implementation StudentSelectionViewController
@synthesize users,selectedUsers;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)dealloc{
    
    [users release];
    [selectedUsers release];
    [super dealloc];
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
    if(!selectedUsers)
        self.selectedUsers = [NSMutableSet set];
    //self.tableView.allowsMultipleSelection = YES;
    self.contentSizeForViewInPopover = CGSizeMake(320,300);
    self.navigationItem.title = @"Student Scope";
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)] autorelease];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEditing)] autorelease];
    [self reloadTableViewDataSource];
    [self initToolbar];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)initToolbar{
    UIBarButtonItem *selectAll = [[[UIBarButtonItem alloc] initWithTitle:@"Select All" style:UIBarButtonItemStyleDone target:self action:@selector(toggleSelection:)] autorelease];
    UIBarButtonItem *flexibleSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    UIBarButtonItem *fixedSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
    fixedSpace.width = selectAll.width;
    UIBarButtonItem *info = [[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    
    self.toolbarItems = [NSArray arrayWithObjects:selectAll,flexibleSpace,info,flexibleSpace,fixedSpace,nil];
    [self updateToolbar];
}
-(void)updateToolbar{
    NSInteger usersSelected = [selectedUsers count];
    NSString *output = [NSString stringWithFormat:@"%d user",usersSelected];
    if (usersSelected != 1)
        output = [output stringByAppendingString:@"s"];
    output = [output stringByAppendingString:@" selected"];
    UIBarButtonItem *item = [self.toolbarItems objectAtIndex:2];
    item.title = output;
    UIBarButtonItem *button = [self.toolbarItems objectAtIndex:0];
    if(usersSelected == [users count]){
        button.style = UIBarButtonItemStyleBordered;
        button.title = @"Deselect All";
    }
    else {
        button.style = UIBarButtonItemStyleDone;
        button.title = @"Select All";
    }
        
}

-(void)toggleSelection:(UIBarButtonItem*)button{
    if(button.style == UIBarButtonItemStyleDone){
        for(int x=0;x<[users count];x++){
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:x inSection:0]];
            [selectedUsers addObject:[users objectAtIndex:x]];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else if(button.style == UIBarButtonItemStyleBordered){
        for(int x=0;x<[users count];x++){
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:x inSection:0]];
            [selectedUsers removeObject:[users objectAtIndex:x]];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    [self updateToolbar];
    
}
-(void)dismiss{
    if([selectedUsers count] == 0){
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please select at least one user to filter by and then try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [view show];
        [view release];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DID_SELECT_NEW_FILTER_GROUP" object:nil userInfo:[NSDictionary dictionaryWithObject:selectedUsers forKey:@"users"]];
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"selectedUsers" object:nil userInfo:[NSDictionary dictionaryWithObject:selectedUsers forKey:@"value"]];
        [self cancelEditing];
    }
}
-(void)cancelEditing{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    self.users = nil;
//self.invoke = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    return [users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.textLabel.text = [[users objectAtIndex:indexPath.row] valueForKey:@"name"];
    if([[selectedUsers valueForKey:@"id"] containsObject:[[users objectAtIndex:indexPath.row] valueForKey:@"id"]])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
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
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *selectedUser = [users objectAtIndex:indexPath.row];
    if([selectedUsers containsObject:selectedUser]){
        [selectedUsers removeObject:selectedUser];
         cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else{
        [selectedUsers addObject:selectedUser];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self updateToolbar];

}





- (void)reloadTableViewDataSource
{
	[self loadStudents];
}


-(NSString*)uniqueURLPath{
    return @"students/all/";
    //return [NSString stringWithFormat:@"students/all/",tutorID];
    
}

-(void)loadStudents{

    __block TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:[self uniqueURLPath]];
    request.completionBlock = ^{
        [self doneLoadingTableViewDataWithSuccess:YES];
        
        NSDictionary *dict = [request.responseData JSONValue];
        self.users = [dict valueForKey:@"list"];
        NSArray *userIDs = [users valueForKey:@"id"];
        
        NSMutableSet *newSet = [selectedUsers mutableCopy];
        for(NSDictionary *selectedUser in selectedUsers){
            if(![userIDs containsObject:[selectedUser valueForKey:@"id"]])
                [newSet removeObject:selectedUser];
            else{
                NSDictionary *oldUser = [selectedUser retain];
                [newSet removeObject:selectedUser];
                NSDictionary *newUser = nil;
                for(NSDictionary *dict in users){
                    if([[dict valueForKey:@"id"] intValue] == [[oldUser valueForKey:@"id"] intValue]){
                        newUser =dict;
                        break;
                    }
                }
                if(newUser != nil){
                    [newSet addObject:newUser];
                }
            }
        }
        self.selectedUsers = newSet;
        [newSet release];
        [self updateToolbar];
        [self.tableView reloadData];
    };
    request.failedBlock = ^{
        [self doneLoadingTableViewDataWithSuccess:NO];
        
    };
    [request startAsynchronous];
    
    
}


@end
