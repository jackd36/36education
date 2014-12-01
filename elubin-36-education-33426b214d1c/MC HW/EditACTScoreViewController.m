//
//  EditACTScoreViewController.m
//  MC HW
//
//  Created by Eric Lubin on 11/13/12.
//
//

#import "EditACTScoreViewController.h"
#import "UITextFieldCell.h"
#import "EditNotesViewController.h"
#import "ACTResult.h"
#import "CustomBadge.h"
#import "ACTDatePickerView.h"
@interface EditACTScoreViewController ()
@property (nonatomic,strong) NSArray *verboseNames;
@property (nonatomic,strong) NSArray *sectionNames;
@property (nonatomic,strong) NSArray *allowedRanges;
@property (nonatomic) BOOL datePickerVisible;
@property (nonatomic) UITextField *activeTextField;

@property (nonatomic,strong) ACTDatePickerView *datePicker;
@property (nonatomic,strong) ACTResult *actResult;
@property (nonatomic) BOOL actionSheetVisible;
@property (nonatomic,strong) NSIndexSet *validMonths;
@property (nonatomic,strong) UIToolbar *inputAccessoryView;
//@property (nonatomic,strong) UITapGestureRecognizer *tapGesture;
@end

NSString * const SHOULD_DISMISS_POPOVER_FOR_ACTS_NOTIFICATION = @"SHOULD_DISMISS_POPOVER_FOR_ACTS";
NSString * const DID_MODIFY_ACT_SCORE_OBJECT = @"DID_MODIFY_ACT_SCORE_OBJECT";
NSString * const DID_ADD_ACT_SCORE_OBJECT= @"DID_ADD_ACT_SCORE_OBJECT";;
@implementation EditACTScoreViewController

- (id)initWithVerboseNames:(NSArray*)verbose sectionNames:(NSArray*)snames allowedRanges:(NSArray*)allowedRanges validMonths:(NSIndexSet*)validMonths  actResult:(ACTResult*)result;
{
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        self.contentSizeForViewInPopover = CGSizeMake(320,600);
        self.verboseNames = verbose;
        self.sectionNames = snames;
        //self.scoreID = scoreID;
        if(result == nil){
            result = [[ACTResult alloc] initWithAllowedRanges:allowedRanges];
            [result setBlankScores:snames verboseNames:verbose];
        }

        self.actResult = result;
        self.allowedRanges = allowedRanges;
        if(validMonths == nil)
            self.validMonths = [NSMutableIndexSet indexSet];
        else
            self.validMonths = validMonths;
        [_actResult addObserver:self forKeyPath:@"notes" options:0 context:NULL];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:NOTIFICATION_DID_CHANGE_DATE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:UIKeyboardDidShowNotification object:nil];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:UIKeyboardWillHideNotification object:nil];
        //self.actResult.objectID = scoreID;

        
    }
    return self;
}

-(void)receivedNotification:(NSNotification*)notification{
    if([notification.name isEqualToString:NOTIFICATION_DID_CHANGE_DATE]){
        NSString *dateString = self.datePicker.dateString;
        
        _actResult.dateString = dateString;
        _actResult.dateTaken.year = self.datePicker.year;
        _actResult.dateTaken.month = self.datePicker.month;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.text = dateString;
        cell.textLabel.textColor = [UIColor blackColor];
        
    }
    else if([notification.name isEqualToString:UIKeyboardDidShowNotification]){

        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            self.tableView.contentInset= UIEdgeInsetsMake(self.tableView.contentInset.top, 0, 255, 0);
            if(!IS_IPHONE_5){
                [self.navigationController setNavigationBarHidden:YES animated:YES];
                
            }
            
        }
        
       // else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, UINavigationControllerHideShowBarDuration * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
                NSIndexPath *indexPath = [self decodeIndexPathFromBitwiseTag:self.activeTextField.tag];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                
            });
        //}
        
    }
    else if([notification.name isEqualToString:UIKeyboardWillHideNotification]){
        //if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        self.tableView.contentInset= UIEdgeInsetsMake(self.tableView.contentInset.top, 0, 0, 0);
        if(!IS_IPHONE_5){
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            
        }
    }

}

- (void)dealloc
{
    [_actResult removeObserver:self forKeyPath:@"notes"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}



- (void)showPicker{
    if(!IS_IOS_7){
        //[self.tableView setContentOffset:CGPointZero animated:YES];
        if(![self.datePicker isDescendantOfView:self.view]){
            


            [self.view addSubview:self.datePicker];
            self.datePicker.frame = CGRectMake(0,self.view.bounds.size.height,self.datePicker.frame.size.width,self.datePicker.frame.size.height);
            
            
            
            //self.view.userInteractionEnabled = NO;
            self.tableView.userInteractionEnabled = NO;
            [UIView animateWithDuration:UINavigationControllerHideShowBarDuration*1.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                CGRect oldFrame = self.datePicker.frame;
                oldFrame.origin.y-=oldFrame.size.height;
                self.datePicker.frame = oldFrame;
            } completion:^(BOOL finished) {
                
            }];
            
            
            //activate picker with latest values
            if(_actResult.dateString != nil)
                [self.datePicker selectDateComponents:_actResult.dateTaken];
            else{
                //set date equal to today
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSDateComponents *components = [calendar components:NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[NSDate date]];
                [self.datePicker selectDateComponents:components];
                [self receivedNotification:[NSNotification notificationWithName:NOTIFICATION_DID_CHANGE_DATE object:nil]]; //simulate a received notification
            }
        
        }
    } else {
        if(!_datePickerVisible){
            _datePickerVisible = YES;
            self.datePicker.hidden = NO;
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [self hidePicker];
        }
        
        
    }
}


-(void)hidePicker{
    if(!IS_IOS_7){
        if([self.datePicker isDescendantOfView:self.view]){
            
            self.tableView.userInteractionEnabled = YES;
            
            [UIView animateWithDuration:UINavigationControllerHideShowBarDuration*1.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                CGRect oldFrame = self.datePicker.frame;
                oldFrame.origin.y+=oldFrame.size.height;
                self.datePicker.frame = oldFrame;
            } completion:^(BOOL finished) {
                [self.datePicker removeFromSuperview];
            }];
        }
    } else {
        if(_datePickerVisible) {
            _datePickerVisible = NO;
            self.datePicker.hidden = YES;
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
    }

}

-(ACTDatePickerView*)datePicker{
    if(_datePicker == nil){
        _datePicker = [[ACTDatePickerView alloc] initWithAvailableMonths:_validMonths width:self.view.bounds.size.width];
        if(!IS_IOS_7)
            _datePicker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    }
    return _datePicker;
}
-(void)returnToParentViewController{

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOULD_DISMISS_POPOVER_FOR_ACTS_NOTIFICATION object:nil];
    }
    else
        [self dismissViewControllerAnimated:YES completion:nil];

}

-(BOOL)isNew{
    return [self.actResult isNew];
}




-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"notes"] && object == _actResult){
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(IS_IOS_7)
        self.tableView.backgroundColor = kDefaultTableViewBackgroundColor;
    
    self.tableView.allowsSelectionDuringEditing = YES;
    if([self isNew]){
        self.navigationItem.title = @"Add ACT";
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveNewAct)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(returnToParentViewController)];
    }
    else{
        self.navigationItem.title = @"Edit ACT";
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if([self isNew]){
        [self setEditing:YES animated:NO];
    }
    else{
        [self setUIEditing:NO];
    }
    
    self.inputAccessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    self.inputAccessoryView.tintColor = nil;
    if(!IS_IOS_7)
        self.inputAccessoryView.barStyle = UIBarStyleBlackTranslucent;
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Previous",@"Next"]];
    segmentedControl.momentary = YES;
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    
    [segmentedControl addTarget:self action:@selector(navigateInputs:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *nav = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissInput)];
    self.inputAccessoryView.items = @[nav,[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],done];
    
    
}

-(void)navigateInputs:(UISegmentedControl*)control{
    NSIndexPath *newPath = nil;
    
        
    NSIndexPath *indexPath = [self decodeIndexPathFromBitwiseTag:self.activeTextField.tag];
    
    BOOL next = control.selectedSegmentIndex;
    
    if(next){
        if(indexPath.row == [self tableView:self.tableView numberOfRowsInSection:indexPath.section]-1){
            newPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section+1];
        }
        else{
            newPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        }
    }
    else{
        if(indexPath.row == 0){
            newPath = [NSIndexPath indexPathForRow:[self tableView:self.tableView numberOfRowsInSection:indexPath.section-1]-1 inSection:indexPath.section-1];
        }
        else{
            newPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
        }
    }
    
    
    
        
        

    [self tableView:self.tableView didSelectRowAtIndexPath:newPath];
}

-(void)dismissInput{
    if([self.activeTextField isFirstResponder]){
        [self.activeTextField resignFirstResponder];
    }
    else{
        [self hidePicker];
    }
}

//-(void)hideActiveTextField:(UITapGestureRecognizer*)gesture{
//    [self.activeTextField resignFirstResponder];
//    [self.tableView removeGestureRecognizer:gesture];
//}

-(BOOL)validateACT{
    if(![_actResult isValid]){
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Unable to save: ACT must have at least one score and have a date." delegate:nil cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil];
        [actionSheet showInView:self.view];
        return NO;
    }
    return YES;
}

-(void)saveNewAct{
    if(self.activeTextField && ![self textFieldShouldEndEditing:self.activeTextField]){
        return;
    }
    
    
   
    
    if(![self validateACT]){
        return;
    }
    [_actResult saveAndClose];
    
    TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:[NSString stringWithFormat:@"students/%d/act_scores/add/",_studentID]];
    
    request.useSVProgressHUD = YES;
    request.cachePolicy = ASIDoNotReadFromCacheCachePolicy | ASIDoNotWriteToCacheCachePolicy;
    
    request.progressMaskType = SVProgressHUDMaskTypeClear;
    
    NSDictionary *postKwargs = [_actResult postDictionary];
    
    for(NSString *key in postKwargs)
        [request addPostValue:postKwargs[key] forKey:key];
    
    __weak TSHTTPRequest *weakRequest = request;
    request.completionBlock = ^{
        NSDictionary *dict = [[weakRequest responseData] JSONValue];
        _actResult.objectID = [dict[@"id"] integerValue];

        
        [[NSNotificationCenter defaultCenter] postNotificationName:DID_ADD_ACT_SCORE_OBJECT object:nil userInfo:@{@"object":_actResult}];
        [self returnToParentViewController];
    };
    
//    request.failedBlock = ^{
//        _actResult.scoresDirty = YES; //ensures tapping save again after a failure redoes the saving.
//        //[self.navigationController popViewControllerAnimated:YES];
//    };

    [request startAsynchronous];
}

-(void)setTextFieldsEditing:(BOOL)editing{
    for(UITextFieldCell *tfs in [self.tableView visibleCells]){
        if([tfs isKindOfClass:[UITextFieldCell class]])
            tfs.textField.userInteractionEnabled =editing;
    }
}




-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    if(self.activeTextField && ![self textFieldShouldEndEditing:self.activeTextField]){
        return;
    }
    
    
    
    
    if(!editing){
        if(![self validateACT]){
            return;
        }
        BOOL dirty = [_actResult saveAndClose];
        [self hidePicker];
        if(dirty){
            TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:[NSString stringWithFormat:@"act_scores/%d/",_actResult.objectID]];
            //request.requestContainer = self;
            request.useSVProgressHUD = YES;
            request.cachePolicy = ASIDoNotReadFromCacheCachePolicy | ASIDoNotWriteToCacheCachePolicy;
            
            request.progressMaskType = SVProgressHUDMaskTypeClear;
            NSDictionary *postKwargs = [_actResult postDictionary];
            
            for(NSString *key in postKwargs)
                [request addPostValue:postKwargs[key] forKey:key];
            
            
            request.completionBlock = ^{
                [self setUIEditing:editing];
                [super setEditing:editing animated:animated];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:DID_MODIFY_ACT_SCORE_OBJECT object:nil userInfo:@{@"id":@(_actResult.objectID)}];
            };
            
                                            
            request.failedBlock = ^{
                _actResult.scoresDirty = YES;
                //[self.navigationController popViewControllerAnimated:YES];
            };
            [request startAsynchronous];
            
            
            //spin up web request here to save changes, block UI and only call super when web request is succesful
            
            return;
        }
        else{
            [self setUIEditing:editing];
            [super setEditing:editing animated:animated];
        }
    }
    else{
        [self setUIEditing:editing];
        [super setEditing:editing animated:animated];
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    
}

-(void)setUIEditing:(BOOL)editing{
    [self setTextFieldsEditing:editing];
    self.navigationItem.hidesBackButton = editing;
    if(!editing && _activeTextField){
        [self.activeTextField resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_sectionNames count]+1;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0)
        return @"Test Information";
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    if(section == 0){
        return 2+![self isNew] + _datePickerVisible;
    }
    else
        return [_verboseNames[section-1] count]+1;
}


-(NSInteger)encodeIndexPath:(NSIndexPath*)indexPath{
    return (indexPath.section << 16) | indexPath.row;
}



-(NSIndexPath*)decodeIndexPathFromBitwiseTag:(NSInteger)tag{
    return [NSIndexPath indexPathForRow:(tag<< 16)>>16 inSection:(tag>>16)];
}

-(NSArray*)scores{
    return self.actResult.initalizedScoresWhileEditing;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    if(indexPath.section != 0){
        
    
        static NSString *CellIdentifier = @"Cell";
        UITextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil){
            cell = [[UITextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textField.delegate = self;
            cell.textField.inputAccessoryView = self.inputAccessoryView;
            
            //cell.textField.tag =
            
        }
        cell.textField.tag = [self encodeIndexPath:indexPath];
        if(indexPath.row == 0){
            cell.textLabel.text = [NSString stringWithFormat:@"%@:",_sectionNames[indexPath.section-1]];
            cell.indentationLevel = 0.0;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0];
        }
        else{
            cell.textLabel.text = [_verboseNames[indexPath.section-1][indexPath.row-1] stringByAppendingString:@":"];
            cell.indentationLevel = 2.0;
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        }
        
    //    if(indexPath.section == [self numberOfSectionsInTableView:tableView]-1 && indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section]){
    //        cell.textField.returnKeyType = UIReturnKeyDone;
    //    }
    //    else{
    //        cell.textField.returnKeyType = UIReturnKeyNext;
    //    }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textField.userInteractionEnabled = [self isEditing];
        //NSLog(@"%@",self.scores);
        id score = self.scores[indexPath.section-1][indexPath.row];
        if(score != [NSNull null])
            cell.textField.text = [NSString stringWithFormat:@"%@",score];
        else
            cell.textField.text = nil;
        // Configure the cell...
        
        return cell;
    }
    else if(indexPath.section == 0 && indexPath.row == 1 && IS_IOS_7 && _datePickerVisible) {
        static NSString *CellIdentifier = @"DatePickerCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell addSubview:self.datePicker];
            
        }
        
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"Cell2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.numberOfLines = 0;
            
        }
        
        
        
        
        if(indexPath.row == (2 + (IS_IOS_7 && _datePickerVisible))){
            cell.textLabel.text = @"Composite Score";
            cell.imageView.image = [UIImage imageNamed:@"81-dashboard"];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if([self isEditing]){
                cell.accessoryView = [CustomBadge customBadgeWithString:@"-" withStringColor:[UIColor whiteColor] withInsetColor:[UIColor greenColor] withBadgeFrame:YES withBadgeFrameColor:[UIColor yellowColor] withScale:1.0 withShining:YES];
            }
            else
                cell.accessoryView = [CustomBadge customBadgeWithString:[NSString stringWithFormat:@"%@",_actResult.compositeScore] withStringColor:[UIColor whiteColor] withInsetColor:[UIColor greenColor] withBadgeFrame:YES withBadgeFrameColor:[UIColor yellowColor] withScale:1.0 withShining:YES];
            
        }
        else {
            cell.accessoryView = nil;
            if([self isEditing]){
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            }
            else{
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
            }
            
            
            
            if(indexPath.row == (1 + (IS_IOS_7 && _datePickerVisible))){
                cell.textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
                
                if(_actResult.notes == nil || [_actResult.notes length] == 0 ){
                    cell.textLabel.text = @"Notes";
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                }
                else{
                    cell.textLabel.text = _actResult.notes;
                    cell.textLabel.textColor = [UIColor blackColor];
                }
                
                cell.imageView.image = [UIImage imageNamed:@"note"];
            }
            else if(indexPath.row == 0){
                cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
                if(_actResult.dateString == nil){
                    cell.textLabel.text = @"Date Taken";
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                }
                else{
                    cell.textLabel.text = _actResult.dateString;
                    cell.textLabel.textColor = [UIColor blackColor];
                }
                cell.imageView.image = [UIImage imageNamed:@"calendar"];
            }
            
        }

        
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0 && indexPath.row == 1){
        if (IS_IOS_7 && _datePickerVisible) {
            return 218.0f;
            
        } else {
            NSString *Text = _actResult.notes;
            UIFont *cellFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
            CGFloat width = tableView.frame.size.width;
            if(self.tableView == tableView){
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                    width -= 45*2;
                else
                    width -= 10*2;
            }
            width-=50;
            CGSize constraintSize = CGSizeMake(width, MAXFLOAT);
            CGSize labelSize = [Text sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
            CGFloat height = labelSize.height +15;
            if(height >=45)
                return height;
        }
	}
    return 45.0f;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self isEditing] && indexPath.section != 0){
        UITextFieldCell *cell = (UITextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        //self.activeTextField = cell.textField;
        [cell.textField becomeFirstResponder];
    }
    else if([self isEditing] && indexPath.section == 0){
        if(indexPath.row == (1 + (IS_IOS_7 && _datePickerVisible))){
            EditNotesViewController *vc = [[EditNotesViewController alloc] initWithStyle:UITableViewStyleGrouped];
            vc.assignment = (NSMutableDictionary*)_actResult;
            [self.navigationController pushViewController:vc animated:YES];
            
        }
        else if(indexPath.row == 0){
            [self showPicker];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    //verify input is numeric
    NSString * newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    BOOL valid;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:newString];
    valid = [alphaNums isSupersetOfSet:inStringSet];
    
    
    
    return (valid || [newString length] == 0) && [newString length] <= 3;
    
    


}

-(UISegmentedControl*)controlInToolbar{
    UIBarButtonItem *item = self.inputAccessoryView.items[0];
    return (UISegmentedControl*)item.customView;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
//    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 216, 0);
//    UIEdgeInsets oldInsets = self.tableView.contentInset;
//    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad && !UIEdgeInsetsEqualToEdgeInsets(self.tableView.contentInset, insets))
//        self.tableView.contentInset = insets;
    
    
    
    
    NSIndexPath *indexPath = [self decodeIndexPathFromBitwiseTag:textField.tag];
    UISegmentedControl *control = self.controlInToolbar;
    
    [control setEnabled:!(indexPath.section == [self numberOfSectionsInTableView:self.tableView]-1 && indexPath.row == [self tableView:self.tableView numberOfRowsInSection:indexPath.section]-1) forSegmentAtIndex:1];
    [control setEnabled:!(indexPath.section == 1 && indexPath.row == 0) forSegmentAtIndex:0];
    
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    self.activeTextField = textField;
    
    
    
//    if(![self.tableView.gestureRecognizers containsObject:_tapGesture]){
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideActiveTextField:)];
//        _tapGesture = tap;
//        [self.tableView addGestureRecognizer:tap];
//    }
    
}




-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self hidePicker];
    [super touchesEnded:touches withEvent:event];
    
    
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    _actionSheetVisible = NO;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    NSString *newString = textField.text;
    NSIndexPath *path = [self decodeIndexPathFromBitwiseTag:textField.tag];
    
    NSRange acceptedRange = [self.allowedRanges[path.section-1][path.row] rangeValue];
    
    NSInteger score = [newString integerValue];
    
    BOOL readyToSave = score >= acceptedRange.location && score <= acceptedRange.location+acceptedRange.length;
    
    BOOL isEmpty = [newString length] == 0;
    
    
    if(!isEmpty && !readyToSave) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Value" message:[NSString stringWithFormat:@"",] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        if(!_actionSheetVisible){
            _actionSheetVisible = YES;
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Entry" message:[NSString stringWithFormat:@"Valid integer values range from %d to %d inclusive. Please try again.",acceptedRange.location,acceptedRange.location+acceptedRange.length] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            alertView.delegate = self;
            [alertView show];
            
        }
        
    }
    else{
        NSMutableArray *section = self.scores[path.section-1];
        
        id oldObject = section[path.row];
        BOOL changed = NO;
        if(isEmpty){
            [section replaceObjectAtIndex:path.row withObject:[NSNull null]];
            changed = oldObject != [NSNull null];
        }
        else{
            [section replaceObjectAtIndex:path.row withObject:@(score)];
            changed = oldObject == [NSNull null] || [oldObject integerValue] != score;
        }
        if(changed)
            _actResult.scoresDirty = YES;
        
    }
    
    return  readyToSave || isEmpty;
}


//-(void)textFieldDidEndEditing:(UITextField *)textField{
//    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
//        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//}
-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    return ![self isEditing];
}
//- (void)textFieldDidEndEditing:(UITextField *)textField{
//    
//    NSIndexPath *path = [self decodeIndexPathFromBitwiseTag:textField.tag];
//    NSMutableArray *section = self.scores[path.section];
//    if([textField.text length] == 0){
//        [section replaceObjectAtIndex:path.row withObject:[NSNull null]];
//    }
//    else{
//        NSInteger score = [textField.text integerValue];
//        
//        
//        [section replaceObjectAtIndex:path.row withObject:@(score)];
//        
//    }
//    
//}
@end
