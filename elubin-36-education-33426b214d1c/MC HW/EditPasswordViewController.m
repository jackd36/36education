//
//  EditPasswordViewController.m
//  MC HW
//
//  Created by Eric Lubin on 1/19/13.
//
//

#import "EditPasswordViewController.h"
NSString * const NOTIFICATION_DID_SET_PASSWORD = @"DID_SET_PASSWORD_NOTIFICATION";
@interface EditPasswordViewController ()
@property (nonatomic,strong) UITextField *initialTextField;
@property (nonatomic,strong) UITextField *confirmTextField;
@end

@implementation EditPasswordViewController

- (id)init
{
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.contentSizeForViewInPopover =  CGSizeMake(320,500);
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];

    if([self isNew] && self.student[@"password"] == nil){
        self.navigationItem.title = @"Set Password";
    }
    else{
        self.navigationItem.title = @"Change Password";
    }
    
    for(int x = 0;x<2;x++){
        UITextField *tf = [[UITextField alloc] initWithFrame:CGRectZero];
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
        tf.spellCheckingType = UITextSpellCheckingTypeNo;
        tf.enablesReturnKeyAutomatically = YES;
        tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        tf.secureTextEntry = YES;
        tf.delegate = self;
        if(x == 0){
            self.initialTextField = tf;
        }
        else{
            self.confirmTextField = tf;
        }
    }
    
    
    
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    UITextField *tf = [self textFieldForIndexPath:indexPath];
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


-(BOOL)enabledSaveButton{
    //NSInteger fieldsEntered = 0;
    if([self.initialTextField.text length] == 0)
        return NO;
    if([self.confirmTextField.text length] == 0)
        return NO;
    
    return YES;
}
-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return @"Enter your new password, and confirm.";

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.rightBarButtonItem.enabled = [self enabledSaveButton];
}

-(void)cancel{
    [self.initialTextField resignFirstResponder];
    [self.confirmTextField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    //self.navigationItem.rightBarButtonItem.enabled = [self enabledSaveButton];
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *otherString = nil;
    if(textField == self.initialTextField){
        otherString = self.confirmTextField.text;
    }
    else if(textField == self.confirmTextField){
        otherString = self.initialTextField.text;
    }
    
    self.navigationItem.rightBarButtonItem.enabled= [otherString length] > 0 && [newString length] > 0;
    
    
    
    return YES;
}

-(void)save{
    //verify passwords match
    if(![self.initialTextField.text isEqualToString:self.confirmTextField.text] || [self.initialTextField.text length] == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Save" message:@"Passwords must be nonempty and must match." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    
    
    
    if([self isNew]){
        self.student[@"password"] = self.initialTextField.text;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DID_SET_PASSWORD object:nil];
        [self cancel];
    }
    else{
        TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:[NSString stringWithFormat:@"students_by_location/%@/",self.student[@"pk"]]];
        [request addPostValue:[@{@"password":self.initialTextField.text} JSONRepresentation] forKey:@"student_info"];
        request.useSVProgressHUD = YES;
        request.progressMaskType = SVProgressHUDMaskTypeClear;
        request.completionBlock = ^{
            [self cancel];
        };
        
        [request startAsynchronous];
        //TODO:
        //perform web request to set password
        // [self cancel] in completion block of web request.
    }
    
    
}

-(BOOL)isNew{
    return self.student[@"pk"] == nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UITextField *tf = [self textFieldForIndexPath:indexPath];
    
    [cell.contentView addSubview:tf];
    
    
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            if([self isNew])
                cell.textLabel.text = @"password";
            else
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

-(UITextField*)textFieldForIndexPath:(NSIndexPath*)indexPath{
    
    if(indexPath.row == 0)
        return self.initialTextField;
    else if(indexPath.row == 1)
        return  self.confirmTextField;
    
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITextField *tf = [self textFieldForIndexPath:indexPath];
    [tf becomeFirstResponder];
    
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField{
    if(textField == self.confirmTextField){
        if([self enabledSaveButton])
            [self save];
    }
    else{
        [self.confirmTextField becomeFirstResponder];
    }
    
    return YES;
}
@end
