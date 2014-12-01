//
//  UnuploadedTestsViewController.m
//  MC HW
//
//  Created by Eric Lubin on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UnuploadedTestsViewController.h"
#import "ASINetworkQueue.h"
#import "UnuploadedTestTableViewCell.h"
#import "WEPopoverController.h"
#import "UnuploadedTestsLegendViewController.h"
@interface UnuploadedTestsViewController ()
@property (nonatomic,strong) NSMutableArray *unuploadedTests;
@property (nonatomic,strong) ASINetworkQueue *queue;
@property (nonatomic,strong) NSMutableArray *results;

//since the method signatures are all the same, just going to use this and cast an UIPopoverController to this pointer when needed
@property (nonatomic,strong) WEPopoverController *popover;
@end
NSString * const DID_COMPLETE_UPLOADING_FALLBACKS = @"DID FINISH UPLOADING FALLBACKS";
@implementation UnuploadedTestsViewController
@synthesize unuploadedTests,queue,results,popover;
-(id)initWithUID:(NSInteger)user{
    if(self = [self initWithUID:user testCompletionType:NoTestUpload]){
        
    }
    return self;
}
//- (void)dealloc
//{
//    
//   // [super dealloc];
//}
- (id)initWithUID:(NSInteger)user testCompletionType:(TestUpload)type
{
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
        self.navigationItem.title = @"36 Education";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStyleBordered target:self action:@selector(displayPopover:)];
        self.modalPresentationStyle = UIModalPresentationFormSheet;
        uid = user;
        
        //NSArray *existing = [[NSUserDefaults standardUserDefaults] objectForKey:UnuploadedTestsKey];
        
        NSArray *existing = [GenericTestUploadHTTPRequest unuploadedTestsWithStatus:type forUploader:user];
        
        results = [[NSMutableArray alloc] initWithCapacity:[existing count]];
        for(int x = 0;x<[existing count];x++){
            [results addObject:[NSNumber numberWithInt:ELUploadingStateNone]];
        }
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:[existing count]];
        for(NSDictionary *attempt in existing){
            [array addObject:[attempt mutableCopy]];
        }
        
        unuploadedTests =array;
        self.queue = [ASINetworkQueue queue];
        queue.delegate = self;
        queue.maxConcurrentOperationCount = 1;
        queue.queueDidFinishSelector = @selector(didFinishUploadingAllPreviousAttempts);
        
        queue.requestDidFinishSelector = @selector(didFinishUploadingAttempt:);
        queue.requestDidFailSelector = @selector(didFailUploadingAttempt:);
        queue.requestDidStartSelector =@selector(didStartUploadingAttempt:);
        queue.shouldCancelAllRequestsOnFailure  = NO;
        for(NSDictionary *dict in unuploadedTests){
            NSString *json = [dict valueForKey:@"JSON"];
            
            GenericTestUploadHTTPRequest *request = [GenericTestUploadHTTPRequest requestForUser:[[dict valueForKey:@"uid"] integerValue] WithAssignmentID:[[dict valueForKey:@"assignmentID"] integerValue] jsonAnswerString:json completed:[[dict valueForKey:@"completed"] boolValue] sectionName:[dict valueForKey:@"section_type"] onRetry:[[dict valueForKey:@"retry_count"] integerValue]];
            request.useSVProgressHUD = NO;
            request.userInfo = [dict dictionaryWithValuesForKeys:[NSArray arrayWithObjects:@"assignmentID",@"section_type", nil]];
            //request.userInfo = [NSDictionary dictionaryWithObject:[dict valueForKey:@"assignmentID"] forKey:@"assignmentID"];
           
            request.showAlertMessages = NO;
            [queue addOperation:request];
            
        }
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(close)];
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        
        // Custom initialization
    }
    return self;
}
-(void)displayPopover:(UIBarButtonItem*)button{
    if(self.popover.popoverVisible){
        [self.popover dismissPopoverAnimated:YES];
    }
    else{
        [self.popover presentPopoverFromBarButtonItem:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

-(WEPopoverController*)popover{
    if(popover == nil){
        
        UnuploadedTestsLegendViewController *vc = [[UnuploadedTestsLegendViewController alloc] init];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            popover = (WEPopoverController*)[[UIPopoverController alloc] initWithContentViewController:vc];
        }
        else
            popover = [[WEPopoverController alloc] initWithContentViewController:vc];
    }
    return popover;
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Uploading failed attempts...";
}
-(void)didStartUploadingAttempt:(GenericTestUploadHTTPRequest*)request{
    NSInteger index = [self indexOfRequestInfo:request.userInfo];
    [self saveState:ELUploadingStateLoading forRowIndex:index];
    UnuploadedTestTableViewCell *cell = [self cellFromIndex:index];
    cell.state = ELUploadingStateLoading;
}
-(NSInteger)indexOfRequestInfo:(NSDictionary*)dict{
    NSInteger assignmentID = [[dict valueForKey:@"assignmentID"] integerValue];
    
    int x = 0;
    for(NSDictionary *test in unuploadedTests){
        if([[test valueForKey:@"assignmentID"] integerValue] == assignmentID && [[test valueForKey:@"section_type"] isEqualToString:[dict valueForKey:@"section_type"]]){
            break;
        }
        x++;
    }
    return x;
}

-(UnuploadedTestTableViewCell*)cellFromIndex:(NSInteger)indexOfRequest{
    
    if(indexOfRequest != NSNotFound){
        return (UnuploadedTestTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfRequest inSection:0]];
    }
    else{
        return nil;
    }
}

-(void)didFailUploadingAttempt:(GenericTestUploadHTTPRequest*)request{
    
    
    
    NSInteger index = [self indexOfRequestInfo:request.userInfo];
    [self saveState:ELUploadingStateFailed forRowIndex:index];

    UnuploadedTestTableViewCell *cell = [self cellFromIndex:index];
    cell.state = ELUploadingStateFailed;
    NSMutableDictionary *attempt = [unuploadedTests objectAtIndex:index];
    if(request.responseStatusCode == 400){//assignment has already been submitted, DELETE
        
        [GenericTestUploadHTTPRequest deleteInstanceOfAssignment:[[attempt valueForKey:@"assignmentID"] integerValue] sectionName:[attempt valueForKey:@"section_type"] uid:uid];
        [attempt setValue:@"Oops!" forKey:@"title"];
        [attempt setValue:@"It looks like this assignment has already been completed, probably from another device."  forKey:@"message"];
     }else if(request.responseStatusCode == 403){
         [attempt setValue:@"Unauthorized" forKey:@"title"];
         [attempt setValue:@"You unfortunately do not have permission to upload this assignment. Have someone else log in and try again." forKey:@"message"];
     }
     else {
         [attempt setValue:@"Unable to connect" forKey:@"title"];
         [attempt setValue:@"Please check your internet connection and try again later." forKey:@"message"];
     }
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
}

-(void)didFinishUploadingAttempt:(GenericTestUploadHTTPRequest*)request{
    NSInteger index = [self indexOfRequestInfo:request.userInfo];
    [self saveState:ELUploadingStateComplete forRowIndex:index];
    UnuploadedTestTableViewCell *cell = [self cellFromIndex:index];
    cell.state = ELUploadingStateComplete;
}


-(void)saveState:(ELUploadingState)state forRowIndex:(NSInteger)index{
    NSNumber *newState = [NSNumber numberWithInt:state];
    [results replaceObjectAtIndex:index withObject:newState];
    
    
}


-(void)close{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    
}



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [queue go];
    //[SVProgressHUD showWithStatus:@"Uploading previous tests..." maskType:SVProgressHUDMaskTypeClear];
}

-(void)didFinishUploadingAllPreviousAttempts{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:DID_COMPLETE_UPLOADING_FALLBACKS object:nil];
    //give a chance for other views to refresh themselves
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 55.0f;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
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
    return [unuploadedTests count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UnuploadedTestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UnuploadedTestTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }
    
    NSDictionary *attempt = [unuploadedTests objectAtIndex:indexPath.row];
    if([[attempt valueForKey:@"completed"] boolValue]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    
    NSDictionary *dict = [[attempt valueForKey:@"JSON"] JSONValue];
    NSDictionary *testInfo = [dict valueForKey:@"testInfo"];
    if([testInfo valueForKey:@"textLabel"]){
        cell.textLabel.text = [testInfo valueForKey:@"textLabel"];
    }
    else{
        cell.textLabel.text = [attempt valueForKey:@"section_type"];
    }
    
    cell.state = [[results objectAtIndex:indexPath.row] intValue];
    if(cell.state == ELUploadingStateFailed){
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    else{
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.detailTextLabel.text = [testInfo valueForKey:@"detailTextLabel"];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *attempt = [unuploadedTests objectAtIndex:indexPath.row];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[attempt valueForKey:@"title"] message:[attempt valueForKey:@"message"] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
