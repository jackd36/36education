//
//  ChangePasswordViewController.m
//  MC HW
//
//  Created by Eric Lubin on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChangePasswordViewController.h"

@interface ChangePasswordViewController ()
@property (nonatomic,strong) NSArray *textFields;
@end
NSString * const THIRTY_SIX_DID_CHANGE_PASSWORD =@"DID_CHANGE_PASSWORD_LALALA";
@implementation ChangePasswordViewController
@synthesize textFields,disableCancelButton,initialOldPassword;
- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.contentSizeForViewInPopover = CGSizeMake(320, 240);
        self.modalInPopover = YES;
        // Custom initialization
    }
    return self;
}
- (void)dealloc
{
    [initialOldPassword release];
    [textFields release];
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Change Password";
    
    if(!disableCancelButton)
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)] autorelease];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:3];
    for(int x =0;x<3;x++){
        UITextField *tf = [[UITextField alloc] initWithFrame:CGRectZero];
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
        tf.spellCheckingType = UITextSpellCheckingTypeNo;
        tf.enablesReturnKeyAutomatically = YES;
        tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        tf.secureTextEntry = YES;
        tf.delegate = self;
        [array addObject:tf];
        [tf release];
    }
    
    self.textFields = array;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(BOOL)enabledSaveButton{
    NSInteger fieldsEntered = 0;
    for(UITextField *tf in textFields){
        if([tf.text length] > 0)
            fieldsEntered++;
    }
    return fieldsEntered == [textFields count];
}


-(void)cancel{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [[NSNotificationCenter defaultCenter] postNotificationName:MC_GRADES_SHOULD_DISMISS_POPOVER object:nil];
    }
    else{
        [self.parentViewController dismissModalViewControllerAnimated:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.rightBarButtonItem.enabled = [self enabledSaveButton];
//    UITextField *tf = [textFields objectAtIndex:0];
//    [tf becomeFirstResponder];
}
-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if(section == 0){
        return @"Please enter your old password.";
    }
    else if(section == 1){
        return @"Enter your new password, and confirm.";
    }
    return nil;
}
-(void)save{
    __block TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:@"change_password/"];
    [request setPostValue:[[textFields objectAtIndex:0] text] forKey:@"old_password"];
    [request setPostValue:[[textFields objectAtIndex:1] text] forKey:@"new_password1"];
    [request setPostValue:[[textFields objectAtIndex:2] text] forKey:@"new_password2"];
    //request.requestContainer = self;
    request.useSVProgressHUD = YES;
    request.progressSuccessText = @"Password changed!";
    request.completionBlock =^{
        [[NSNotificationCenter defaultCenter] postNotificationName:THIRTY_SIX_DID_CHANGE_PASSWORD object:nil];
        [self cancel];
    };
    [request startAsynchronous];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSInteger index = [textFields indexOfObject:textField];
    if(index > 0){
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    else{
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    //self.navigationItem.rightBarButtonItem.enabled = [self enabledSaveButton];
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSInteger fieldsEntered = 0;
    for(UITextField *tf in textFields){
        if([tf.text length] > 0 && textField != tf)
            fieldsEntered++;
    }
    if([newString length] > 0)
        fieldsEntered++;
    
    self.navigationItem.rightBarButtonItem.enabled= fieldsEntered == [textFields count];
    
    
    
    return YES;
}


-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    self.textFields = nil;
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    self.textFields = nil;
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
    if(section == 0)
        return 1;
    else if(section == 1)
        return 2;
    
    return 0;
}


-(BOOL)textFieldShouldReturn:(UITextField*)textField{
    NSInteger index = [textFields indexOfObject:textField];
    
    
    if(index == [textFields count]-1){
        if([self enabledSaveButton])
            [self save];
    }
    else{
        UITextField *tf = [textFields objectAtIndex:index+1];
        [tf becomeFirstResponder];
        if(index == 0){
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
        
    return YES;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil] autorelease];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UITextField *tf = [textFields objectAtIndex:indexPath.row+indexPath.section];
    
    
    [cell.contentView addSubview:tf];

    
    if(indexPath.section == 0){
        cell.textLabel.text = @"old pass";
        tf.returnKeyType = UIReturnKeyNext;
        tf.text = initialOldPassword;
    }
    else if(indexPath.section == 1){
        if(indexPath.row == 0){
            cell.textLabel.text = @"new pass";
            tf.returnKeyType = UIReturnKeyNext;
        }
        else if(indexPath.row == 1){
            cell.textLabel.text = @"confirm";
            tf.returnKeyType = UIReturnKeyDone;
        }
    }
    

    // Configure the cell...
    
    return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    UITextField *tf = [textFields objectAtIndex:indexPath.row+indexPath.section];
    if(IS_IOS_7){

        CGFloat widthOfLabel = 108 + 5;
        
        tf.frame = CGRectMake(widthOfLabel, 0, cell.frame.size.width - widthOfLabel-5,cell.frame.size.height);
        tf.center = CGPointMake(tf.center.x,cell.frame.size.height/2);
    }
    else {
        tf.frame = CGRectMake(cell.textLabel.bounds.size.width+cell.textLabel.frame.origin.x+6, 0, self.view.bounds.size.width-20-cell.textLabel.bounds.size.width-cell.textLabel.frame.origin.x-6, 45);
        tf.center = CGPointMake(tf.center.x,cell.contentView.bounds.size.height/2-2);
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
    UITextField *tf = [textFields objectAtIndex:indexPath.row +indexPath.section];
    [tf becomeFirstResponder];

}

@end
