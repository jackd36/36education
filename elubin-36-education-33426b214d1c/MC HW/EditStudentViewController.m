//
//  EditStudentViewController.m
//  MC HW
//
//  Created by Eric Lubin on 1/17/13.
//
//

#import "EditStudentViewController.h"
#import "UITextFieldCell.h"
#import "SelectLocationsViewController.h"
#import "SelectTutorsViewController.h"
#import "EditPasswordViewController.h"

NSString * const ADDED_NEW_STUDENT_NOTIFICATION = @"NOTIFICATION_ADDED_NEW_STUDENT_NOTIFICATION";
NSString * const POPOVER_NEEDS_DISMISSING = @"POPOVER_NEEDS_DISMISSING!@#$%^&";
NSString * const SHOULD_DISMISS_POPOVER_FOR_STUDENTS_NOTIFICATION = @"SHOULD_DISMISS_STUDENTS_POPOVER!@#@!#";
@interface EditStudentViewController ()
@property (nonatomic,strong) UITextField *activeTextField;
@property (nonatomic,strong) NSMutableDictionary *student;
@property (nonatomic,strong) NSMutableDictionary *changeDictionary; //contains only the keys in student that have been modified, plus the pk. We use this when saving online. Only important when not new.
@property (nonatomic,strong) NSArray *extendedTimeOptions;
@property (nonatomic,strong) NSArray *allLocations;
@property (nonatomic,strong) NSArray *allTutors;
@property (nonatomic) BOOL dirty;
@property (nonatomic) BOOL highlightMissing;
@property (nonatomic,strong) NSSet *ignoreKeys;
@property (nonatomic,getter=isNew) BOOL new;
@end

@implementation EditStudentViewController


-(id)initWithStudent:(NSMutableDictionary *)student timeOptions:(NSArray*)timeOptions allLocations:(NSArray*)locations allTutors:(NSArray*)allTutors{
    
    if(self = [self init]){
        self.contentSizeForViewInPopover = CGSizeMake(320,500);
        self.allLocations = locations;
        self.allTutors = allTutors;
        self.extendedTimeOptions = timeOptions;
        if(student != nil)
            self.student = student;
        else {
            self.student = [NSMutableDictionary dictionary];
            self.student[@"require_pw_change"] = @YES;
            self.student[@"extended_time"] = timeOptions[0][0];
            self.student[@"active"] = @YES;
            if([locations count] == 1){
                self.student[@"location"] = locations;
            }
//            
//            ELAppDelegate *delegate = [ELAppDelegate sharedDelegate];
//            TSUser *activeUser = delegate.activeUser;
//            if(!activeUser.isAdmin){
//                self.student[@"location"] = @[<#objects, ...#>];
//            }
        }
        self.new =self.student[@"id"] == nil;
        if(![self isNew]){
            self.ignoreKeys = [NSSet setWithObjects:@"name",@"password", nil];
            for(NSString *key in self.student){
                if(![self.ignoreKeys containsObject:key])
                    [self.student addObserver:self forKeyPath:key options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];
            }
            self.changeDictionary = [NSMutableDictionary dictionaryWithObject:self.student[@"id"] forKey:@"id"];
            
        }
        else{
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:NOTIFICATION_DID_SET_PASSWORD object:nil];
            [self.student addObserver:self forKeyPath:@"location" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];
            [self.student addObserver:self forKeyPath:@"tutors" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];

        }


    }
    return self;
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    
    if([self isNew]){
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
    }
    else{
        BOOL dirtify = NO;
        if([keyPath isEqualToString:@"require_pw_change"]){
            if([change[NSKeyValueChangeOldKey] boolValue] != [change[NSKeyValueChangeNewKey] boolValue]){
                dirtify = YES;
                
            }
        }
        else if([keyPath isEqualToString:@"location"] || [keyPath isEqualToString:@"tutors"]){
            dirtify = YES;
            if([keyPath isEqualToString:@"location"]){
                self.student[@"tutors"] = [self.student[@"tutors"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY locations.pk IN %@",[self.student[@"location"] valueForKey:@"pk"]]];
            }
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
            
        }
        else{
            if(![change[NSKeyValueChangeOldKey] isEqualToString:change[NSKeyValueChangeNewKey]]){
                dirtify = YES;
                if([keyPath isEqualToString:@"first"] || [keyPath isEqualToString:@"last"])
                    self.student[@"name"] = [NSString stringWithFormat:@"%@ %@",self.student[@"first"],self.student[@"last"]];

            }
        }
        
        if(dirtify){
            _dirty = YES;
            self.changeDictionary[keyPath] = change[NSKeyValueChangeNewKey];
        }
    }

}

-(void)receivedNotification:(NSNotification*)notification{
    if([notification.name isEqualToString:NOTIFICATION_DID_SET_PASSWORD]){
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];

    }
}
- (void)dealloc
{
    if(![self isNew]){
        for(NSString *key in self.student){
            if(![self.ignoreKeys containsObject:key])
                [self.student removeObserver:self  forKeyPath:key];
        }
    }
    else{
        [self.student removeObserver:self forKeyPath:@"location"];
        [self.student removeObserver:self forKeyPath:@"tutors"];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }

}
- (id)init
{
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(BOOL)isStudentActive{
    return [self.student[@"active"] boolValue];
}

-(void)dismissView{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOULD_DISMISS_POPOVER_FOR_STUDENTS_NOTIFICATION object:nil];
    }
    else
        [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)saveChanges{
    if(_activeTextField){
        [self.activeTextField resignFirstResponder];
        self.activeTextField = nil;
    }
    
    
    //save changes here for new student
    if(![self verifyNewStudentCanBeSubmitted]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Create Student" message:@"One or more of the following fields are incomplete. Please review the fields marked in red and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        self.highlightMissing = YES;
        [self.tableView reloadData];
        return;
    }
    
    
    TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:@"students_by_location/add/"];
    [request addPostValue:[self.student JSONRepresentation] forKey:@"student_info"];
    request.useSVProgressHUD = YES;
    request.progressMaskType = SVProgressHUDMaskTypeGradient;
    
    __weak TSHTTPRequest *weakRequest = request;
    request.completionBlock = ^{
        NSDictionary *response = [[weakRequest responseData] JSONValue];
        self.student[@"id"] = response[@"id"];
        [[NSNotificationCenter defaultCenter] postNotificationName:ADDED_NEW_STUDENT_NOTIFICATION object:nil userInfo:self.student];
        [self dismissView];
    };
    
    request.progressFailureText = @"Unable to create student. Please check your connection and try again.";
    [request startAsynchronous];
    
}

-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    return ![self isEditing];
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    //send notificaiton so studentadmin can deselect selected row and set self.activePopover to nil
    [[NSNotificationCenter defaultCenter] postNotificationName:POPOVER_NEEDS_DISMISSING object:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if([self isNew]){
        [self setEditing:YES animated:NO];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissView)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveChanges)];
        self.navigationItem.title = @"New Student";
    }
    else{
        if([self isStudentActive]){
            self.navigationItem.rightBarButtonItem = self.editButtonItem;
        }
        [self setUIEditing:NO];
        self.navigationItem.title = @"Edit Student";
    }
    self.tableView.allowsSelectionDuringEditing = YES;
    
    //}
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    if(section == 0)
        return 3;
    else if (section == 1)
        return 2;
    else if(section == 2)
        return 2;
    else if(section == 3)
        return 1;
    return 0;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return @"User Information";
    }
    else if(section == 1){
        return @"Password";
    }
    else
        return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section == 0){
        
        
        static NSString *CellIdentifier = @"Cell";
        UITextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil){
            cell = [[UITextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.textField.delegate = self;
            cell.textField.inputAccessoryView = self.inputAccessoryView;
            cell.textField.frame = CGRectMake(0, 0, 170, 22);
            cell.textField.font = [UIFont systemFontOfSize:17.0];
            cell.textField.textColor = RGBCOLOR(0.22,0.33,0.53);
            cell.textField.adjustsFontSizeToFitWidth = YES;
            //cell.textField.tag =
            
        }
        
        NSString *studentKey = nil;
        
        cell.textField.textColor = cell.detailTextLabel.textColor;
        cell.textField.tag = indexPath.row;
        cell.indentationLevel = 0.0;
        //cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0];
        if(indexPath.row == 0){
            cell.textLabel.text = @"First Name";
            cell.textField.keyboardType = UIKeyboardTypeAlphabet;
            cell.textField.returnKeyType = UIReturnKeyNext;
            studentKey = @"first";
            
            
        }
        else if(indexPath.row == 1){
            cell.textLabel.text = @"Last Name";
            studentKey = @"last";
            cell.textField.keyboardType = UIKeyboardTypeAlphabet;
            cell.textField.returnKeyType = UIReturnKeyNext;
            
        }
        else if(indexPath.row == 2){
            cell.textLabel.text = @"E-mail";
            studentKey = @"email";
            cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
            cell.textField.returnKeyType = UIReturnKeyDone;
            
        }
        cell.textField.text = self.student[studentKey];
        if(self.highlightMissing && ([cell.textField.text length] == 0 || ([studentKey isEqualToString:@"email"] && ![self verifyEmail]))){
            cell.textLabel.textColor = [UIColor redColor];
        }
        else{
            cell.textLabel.textColor = [UIColor blackColor];
        }
        
        
        
        //    if(indexPath.section == [self numberOfSectionsInTableView:tableView]-1 && indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section]){
        //        cell.textField.returnKeyType = UIReturnKeyDone;
        //    }
        //    else{
        //        cell.textField.returnKeyType = UIReturnKeyNext;
        //    }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textField.userInteractionEnabled = [self isEditing];

        // Configure the cell...
        
        return cell;

        
    }
    else if(indexPath.section == 1 && indexPath.row == 1){
        
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"Require password change";
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            UISwitch *onOff = [[UISwitch alloc] initWithFrame:CGRectZero];
            onOff.on = [self.student[@"require_pw_change"] boolValue];
            cell.accessoryView = onOff;
            onOff.userInteractionEnabled = [self isEditing];
            [onOff addTarget:self action:@selector(changedValueOfPasswordChange:) forControlEvents:UIControlEventValueChanged];
            return cell;
        
        
    }
    else if(indexPath.section == 2 || (indexPath.section == 1 && indexPath.row == 0)){
        static NSString *CellIdentifier2 = @"Cell7";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier2];
            //cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
            

        }
        cell.textLabel.textColor = [UIColor blackColor];
        if(indexPath.section == 2){
            if([self isEditing]){
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else{
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            if(indexPath.row == 0){
                if([self.allLocations count] == 1){
                    cell.textLabel.text = @"Location";
                    cell.detailTextLabel.text = self.student[@"location"][0][@"name"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                else{
                    cell.textLabel.text = @"Location(s)";
                    NSArray *selectedLocations = self.student[@"location"];
                    NSInteger count = [selectedLocations count];
                    if(count == 0){
                        cell.detailTextLabel.text = @"None";
                    }
                    else if(count == 1){
                        cell.detailTextLabel.text = selectedLocations[0][@"name"];
                    }
                    else{
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d selected",count];
                    }
                }
                
                if(self.highlightMissing && [self.student[@"location"] count] == 0){
                    cell.textLabel.textColor = [UIColor redColor];
                }
                else{
                    cell.textLabel.textColor = [UIColor blackColor];
                }
                //if(self.highlightMissing && self.)
                
            }
            else if(indexPath.row == 1){
                cell.textLabel.text = @"Tutor(s)";
                NSArray *selectedTutors = self.student[@"tutors"];
                
                NSInteger count = [selectedTutors count];
                if(count == 0){
                    cell.detailTextLabel.text = @"None";
                }
                else if(count == 1){
                    cell.detailTextLabel.text = selectedTutors[0][@"name"];
                }
                else{
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d selected",count];
                }
            }
        }
        else if(indexPath.section == 1){
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = nil;
            if([self isNew] && self.student[@"password"] == nil) {
                cell.textLabel.text = @"Set password...";
                if(self.highlightMissing)
                    cell.textLabel.textColor = [UIColor redColor];
                else{
                    cell.textLabel.textColor = [UIColor blackColor];
                }
            }
            else{
                cell.textLabel.text = @"Change password...";
                cell.textLabel.textColor = [UIColor blackColor];
                
            }
            
            
            
            
        }
        
        return cell;
    }
    else if(indexPath.section == 3){
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"Extended time";
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self.extendedTimeOptions count]];
        int x = 0;
        int activeInteger = 0;
        for(NSArray *pair in self.extendedTimeOptions){
            if(activeInteger == 0 && [pair[0] isEqualToString:self.student[@"extended_time"]])
                activeInteger = x;
            [array addObject:pair[1]];
            x++;
        }
    
        UISegmentedControl *sc = [[UISegmentedControl alloc] initWithItems:array];
        sc.segmentedControlStyle = UISegmentedControlStyleBar;
        sc.userInteractionEnabled = [self isEditing];
        cell.accessoryView = sc;
        sc.selectedSegmentIndex = activeInteger;
        [sc addTarget:self action:@selector(changeExtendedTimeOption:) forControlEvents:UIControlEventValueChanged];
        
        return cell;
    }
    return nil;
}

-(void)changeExtendedTimeOption:(UISegmentedControl*)control{
    self.student[@"extended_time"] = self.extendedTimeOptions[control.selectedSegmentIndex][0];
}

-(void)changedValueOfPasswordChange:(UISwitch*)onOff{
    self.student[@"require_pw_change"] = @(onOff.isOn);
}
-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if(section == 1){
        return @"When this setting is on, the user is forced to change their password the next time they login.";
    }
    else if(section == 3){
        return @"For those who are given extra time when taking the ACT, you may specify a multiple here.";
    }
    return nil;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}




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

#pragma mark - Table view delegate
-(void)setTextFieldsEditing:(BOOL)editing{
    for(UITextFieldCell *tfs in [self.tableView visibleCells]){
        if([tfs isKindOfClass:[UITextFieldCell class]])
            tfs.textField.userInteractionEnabled =editing;
    }
}

-(void)setUIEditing:(BOOL)editing{
    [self setTextFieldsEditing:editing];
    //set status of UISwitch
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    UISwitch *onOff = (UISwitch*)cell.accessoryView;
    onOff.userInteractionEnabled = editing;
    
    UITableViewCell *cell2 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    UISegmentedControl *sc = (UISegmentedControl*)cell2.accessoryView;
    sc.userInteractionEnabled = editing;
    
    
    NSArray *rows = @[[NSIndexPath indexPathForRow:0 inSection:2],[NSIndexPath indexPathForRow:1 inSection:2]];
    
    for(NSIndexPath *row in rows){
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:row];
        if(editing && !(row.row == 0 && [self.allLocations count] == 1)){
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else{
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    self.navigationItem.hidesBackButton = editing;
    if(!editing && _activeTextField){
        [self.activeTextField resignFirstResponder];
        self.activeTextField = nil;
    }
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    if(!editing && _activeTextField){
        [self.activeTextField resignFirstResponder];
        self.activeTextField = nil;
    }
    
    if(editing || !_dirty){
        [self setUIEditing:editing];
        [super setEditing:editing animated:animated];
    }
    else{
     
        TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:[NSString stringWithFormat:@"students_by_location/%@/",self.student[@"id"]]];
        [request addPostValue:[self.changeDictionary JSONRepresentation] forKey:@"student_info"];
        request.useSVProgressHUD = YES;
        request.progressMaskType = SVProgressHUDMaskTypeClear;
        request.completionBlock = ^{
            [self setUIEditing:editing];
            [super setEditing:editing animated:animated];
            _dirty = NO;
        };
        
        [request startAsynchronous];

        
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self isEditing] && indexPath.section == 0){
        UITextFieldCell *cell = (UITextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        //self.activeTextField = cell.textField;
        [cell.textField becomeFirstResponder];
    }
    else if(indexPath.section == 2){
        if(indexPath.row == 0 && [self.allLocations count] != 1){
            SelectLocationsViewController *vc = [[SelectLocationsViewController alloc] initWithItems:self.allLocations student:self.student];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if(indexPath.row == 1){
            if([self.student[@"location"] count] == 0){
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unexpected Error." message:@"In order to add a tutor, you must first select at least one location for the student." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
                return;
            }
            SelectTutorsViewController *vc = [[SelectTutorsViewController alloc] initWithItems:[self.allTutors filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY locations.pk IN %@",[self.student[@"location"] valueForKey:@"pk"]]] student:self.student];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if(indexPath.section == 1 && indexPath.row == 0){
        EditPasswordViewController *vc = [[EditPasswordViewController alloc] init];
        vc.student = self.student;
        [self.navigationController pushViewController:vc animated:YES];
        //Present view controllers here to change password
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    self.activeTextField = textField;

    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField.tag < 2){
        UITextFieldCell *cell = (UITextFieldCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag+1 inSection:0]];
        [cell.textField becomeFirstResponder];
    }
    else{
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    NSString *newString = textField.text;
    if(textField.tag == 0 || textField.tag == 1){
        if(textField.tag == 0)
            self.student[@"first"] = newString;
    
        if(textField.tag == 1)
            self.student[@"last"] = newString;
        
       
    }
    else if(textField.tag == 2)
        self.student[@"email"] = newString;
    return  YES;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self isEditing] || (indexPath.row == 0 && indexPath.section == 1)){
        return indexPath;
    }
    return nil;
}
-(BOOL)verifyEmail{
    NSString *email = self.student[@"email"];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,6}$" options:0 error:NULL];
    NSRange rangeOfMatch = [regex rangeOfFirstMatchInString:email options:0 range:NSMakeRange(0, [email length])];
    return rangeOfMatch.location != NSNotFound;
}

-(BOOL)verifyNewStudentCanBeSubmitted{
    
    
    return [self.student[@"first"] length] > 0 && [self.student[@"last"] length] > 0 && [self.student[@"email"] length] > 0 && [self.student[@"password"] length] > 0 && [self.student[@"location"] count] > 0 && [self verifyEmail];
}
@end
