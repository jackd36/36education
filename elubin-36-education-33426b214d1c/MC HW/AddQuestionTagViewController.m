//
//  AddQuestionTagViewController.m
//  MC HW
//
//  Created by Eric Lubin on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddQuestionTagViewController.h"
#import "NSArray+Grouping.h"

NSString * const QuestionDidModifyTags = @"MCGRADES DIDMODIFYTAGSForQUestion";
NSString * const PassageDidModifyTags = @"MCGRADES DIDMODIFYTAGSForPassage";
@interface AddQuestionTagViewController ()
@property (nonatomic,retain) NSMutableArray *appliedTags;
@property (nonatomic,retain) NSMutableArray *tagsInSection;//in question tags, this is now an array of dictionaries each containing a mutable array
@property (nonatomic,retain) NSArray *filteredTags;

@end

@implementation AddQuestionTagViewController
@synthesize appliedTags,tagsInSection,sectionName,questionIndex,contentType,objectID,filteredTags,waitForRequestCompletion,descriptionOfContent,questionOffset;
- (id)init
{
    self = [self initWithNibName:@"SelectObjectViewController" bundle:nil];
    if (self) {
        self.appliedTags = [NSMutableArray array];
        self.tagsInSection = [NSMutableArray array];
        self.descriptionOfContent = @"Question";
        self.modalPresentationStyle = UIModalPresentationFormSheet;
        // Custom initialization
    }
    return self;
}
- (void)dealloc
{
    [appliedTags release];
    [tagsInSection release];
    [sectionName release];
    [descriptionOfContent release];
    [filteredTags release];
    [super dealloc];
}

-(BOOL)isQuestionBased{
    return [descriptionOfContent isEqualToString:@"Question"];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Add tags";

    self.navigationItem.leftBarButtonItem =  [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)] autorelease];
    self.navigationItem.rightBarButtonItem =  [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)] autorelease];
    UIBarButtonItem *add= [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createTag)] autorelease];
    add.style = UIBarButtonItemStyleBordered;
    UIBarButtonItem *flexible = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    self.searchDisplayController.searchBar.placeholder = @"Search tags";
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if([self isQuestionBased])
        add = nil;
    self.toolbarItems = [NSArray arrayWithObjects:self.editButtonItem,flexible,add,nil];
    self.navigationController.toolbarHidden = NO;
}
-(void)cancel{
     [[NSNotificationCenter defaultCenter] postNotificationName:@"SHOULD_RESTART_TIMER" object:nil];
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
   
    
}
-(void)save{
    //do stuff here
    NSString *urlString = nil;
    if([self isQuestionBased])
        urlString = [NSString stringWithFormat:@"tags/ct/%d/id/%d/q/%d/set/",contentType,objectID,questionIndex];
    else{
        urlString = [NSString stringWithFormat:@"tags/passage/%d/set/",objectID];
    }
    __block TSHTTPRequest *request =[TSHTTPRequest requestWithPathComponent:urlString];
    
//    request.progressMaskType = SVProgressHUDMaskTypeClear;
//    request.useSVProgressHUD = YES;
    [request addPostValue:[appliedTags JSONRepresentation] forKey:@"json"];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    if(waitForRequestCompletion)
        request.completionBlock = ^{
            [self cancel];
            if([self isQuestionBased])
                [[NSNotificationCenter defaultCenter] postNotificationName:QuestionDidModifyTags object:nil];
            else{
                [[NSNotificationCenter defaultCenter] postNotificationName:PassageDidModifyTags object:nil];
            }
            //send notification to update UI here
        };
    [request startAsynchronous];
    if(!waitForRequestCompletion)
        [self cancel];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadData];
}
-(void)loadData{
    NSString *urlString = nil;
    if([self isQuestionBased])
        urlString = [NSString stringWithFormat:@"tags/ct/%d/id/%d/q/%d/",contentType,objectID,questionIndex];
    else{
        urlString = [NSString stringWithFormat:@"tags/passage/%d/",objectID];
    }
    
    __block TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:urlString];
    //request.requestContainer = self;
    request.useSVProgressHUD = YES;
    request.progressLoadingText = @"Loading tags..";
    //request.useSVProgressHUD = objects == nil;
    request.completionBlock = ^{
        NSDictionary *dict = [[request responseData] JSONValue];
        NSArray *tags = [dict valueForKey:@"existing_tags"];
        NSArray *array = [dict valueForKey:@"all_tags"];
        if([self isQuestionBased]){
            
            NSMutableArray *groupedArray = (NSMutableArray*)[array groupUsingKey:@"category__description"];
            self.tagsInSection = groupedArray;
            
        }
        else{
            NSMutableArray *arrayCopy = [[dict valueForKey:@"all_tags"] mutableCopy];
            self.tagsInSection = arrayCopy;
            [arrayCopy release];
        }
        self.appliedTags = [NSMutableArray arrayWithCapacity:[tags count]];
        [tagsInSection sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES]]];
        for(NSNumber *tagID in tags){
            NSDictionary *dict = [[array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id == %@",tagID]] lastObject];
            [appliedTags addObject:dict];
            [tagsInSection removeObject:dict];
        }
        [self.tableView reloadData];
    };

    [request startAsynchronous];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(void)createTag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Tag" message:@"Enter a description..." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create New", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *field = [alert textFieldAtIndex:0];
    field.delegate = self;
    [alert show];
    [alert release];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        NSString *tagName = [alertView textFieldAtIndex:0].text;
        NSArray *filtered = [[tagsInSection arrayByAddingObjectsFromArray:appliedTags] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"description ==[cd] %@",tagName]];
        
        if([filtered count] == 0){
            
            NSDictionary *newTag = [NSDictionary dictionaryWithObject:tagName forKey:@"description"];
            [appliedTags addObject:newTag];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Tag already exists!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
        }
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 50) ? NO : YES;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}
#pragma mark - Table view data source
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(self.tableView == tableView){
        if(section ==0)
            if([descriptionOfContent isEqualToString:@"Question"])
                return [NSString stringWithFormat:@"Tags Applied to %@ %d",descriptionOfContent,questionIndex+1+questionOffset];
            else{
                return [NSString stringWithFormat:@"Tags Applied to %@",descriptionOfContent];
            }
        else {
            if([self isQuestionBased]){
                return [[tagsInSection objectAtIndex:section-1] valueForKey:NSARRAY_GROUPING_SECTION_TITLE_STRING];
            }
            else
                return [NSString stringWithFormat:@"All %@ Tags",sectionName];
        }
    }
    else{
        if([self isQuestionBased]){
            return [[filteredTags objectAtIndex:section] valueForKey:NSARRAY_GROUPING_SECTION_TITLE_STRING];
        }
        else
            return nil;
    }
    
}

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if(section == 0 && self.tableView == tableView){
        return @"Swipe to remove a tag";
    }
    return nil;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([self isQuestionBased]){
        if(tableView != self.tableView){
            return [filteredTags count];
        }
        else{
            return [tagsInSection count]+1;
        }
    }
    else{
        if(tableView == self.tableView)
            return 2;
        // Return the number of sections.
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.tableView){
        if (section == 0) {
            return [appliedTags count];
        }
        else{
            if([self isQuestionBased]){
                return [[[tagsInSection objectAtIndex:section-1] valueForKey:NSARRAY_GROUPING_OBJECTS_STRING] count];
            }
            else{
                if(section == 1){
                    return [tagsInSection count];
                }
                return 0;
            }
        }
    }
    else{
        if([self isQuestionBased]){
            return [[[filteredTags objectAtIndex:section] valueForKey:NSARRAY_GROUPING_OBJECTS_STRING] count];
        }
        else
            return [filteredTags count];
    }
        
}
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0 && tableView == self.tableView){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error info" message:[[appliedTags objectAtIndex:indexPath.row] valueForKey:@"error_info"] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(![self isQuestionBased] || (indexPath.section == 0 && tableView == self.tableView)){
        return 45.0f;
    }
    NSString *text = nil;
    if(tableView == self.tableView)
        text = [[[[tagsInSection objectAtIndex:indexPath.section-1] valueForKey:NSARRAY_GROUPING_OBJECTS_STRING] objectAtIndex:indexPath.row] valueForKey:@"error_info"];
    else{
        text = [[[[filteredTags objectAtIndex:indexPath.section] valueForKey:NSARRAY_GROUPING_OBJECTS_STRING] objectAtIndex:indexPath.row] valueForKey:@"error_info"];
    }
    
    
    if([text length] > 0){
		UIFont *cellFont = [UIFont systemFontOfSize:14.0f];
        
        CGFloat width = tableView.frame.size.width;
        if(self.tableView == tableView){
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                width -= 45*2;
            else
                width -= 10*2;
        }
        width-=50;
        
        CGSize constraintSize = CGSizeMake(width, MAXFLOAT);
		CGSize labelSize = [text sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
		CGFloat height = labelSize.height +30;
		if(height >=45)
			return height;
	}
	return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.imageView.image = [UIImage imageNamed:@"DetailViewTag"];
        cell.detailTextLabel.numberOfLines = 0;
        
    }
    if(self.tableView == tableView){
        if(indexPath.section == 0){
            cell.textLabel.text = [[appliedTags objectAtIndex:indexPath.row] valueForKey:@"description"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if([self isQuestionBased]){
                cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
                if([[[appliedTags objectAtIndex:indexPath.row] valueForKey:@"category__description"] length] > 0)
                    cell.detailTextLabel.text = [[appliedTags objectAtIndex:indexPath.row] valueForKey:@"category__description"];
            }
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            if([self isQuestionBased]){
                //cell.detailTextLabel.text = [
                NSDictionary *tag = [[[tagsInSection objectAtIndex:indexPath.section-1] valueForKey:NSARRAY_GROUPING_OBJECTS_STRING] objectAtIndex:indexPath.row];
                cell.textLabel.text = [tag valueForKey:@"description"];
                cell.detailTextLabel.text = [tag valueForKey:@"error_info"];
            }
            else{
                 cell.textLabel.text = [[tagsInSection objectAtIndex:indexPath.row] valueForKey:@"description"];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            
        }
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
        if([self isQuestionBased]){
            NSDictionary *tag = [[[filteredTags objectAtIndex:indexPath.section] valueForKey:NSARRAY_GROUPING_OBJECTS_STRING] objectAtIndex:indexPath.row];
            cell.textLabel.text = [tag valueForKey:@"description"];
            cell.detailTextLabel.text = [tag valueForKey:@"error_info"];
        }
        else
            cell.textLabel.text = [[filteredTags objectAtIndex:indexPath.row] valueForKey:@"description"];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    // Configure the cell...
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  indexPath.section == 0;
}

-(NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"Untag";
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *tag = [appliedTags objectAtIndex:indexPath.row];
        [tag retain];
        [appliedTags removeObjectAtIndex:indexPath.row];
        if([tag valueForKey:@"id"] != nil){
            NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES]];
            if([self isQuestionBased]){
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",NSARRAY_GROUPING_SECTION_TITLE_STRING,[tag valueForKey:@"category__description"]];
                NSDictionary *category = [[tagsInSection filteredArrayUsingPredicate:predicate] lastObject];
                NSInteger index = [tagsInSection indexOfObject:category];
                NSMutableArray *subArray = [[tagsInSection objectAtIndex:index] valueForKey:NSARRAY_GROUPING_OBJECTS_STRING];
                [subArray addObject:tag];
                [subArray sortUsingDescriptors:sortDescriptors];
                [tableView beginUpdates];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[subArray indexOfObject:tag] inSection:index+1]] withRowAnimation:UITableViewRowAnimationTop];
                [tableView endUpdates];
            }
            else{
                [tagsInSection addObject:tag];
                
                [tagsInSection sortUsingDescriptors:sortDescriptors];
                [tableView beginUpdates];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[tagsInSection indexOfObject:tag] inSection:1]] withRowAnimation:UITableViewRowAnimationTop];
                [tableView endUpdates];
            }
        }
        else{
            
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        [tag release];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


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
    
    if(tableView != self.tableView){
        if([self isQuestionBased]){
            NSDictionary *tag = [[[filteredTags objectAtIndex:indexPath.section] valueForKey:NSARRAY_GROUPING_OBJECTS_STRING] objectAtIndex:indexPath.row];
            [tag retain];
            [appliedTags addObject:tag];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",NSARRAY_GROUPING_SECTION_TITLE_STRING,[tag valueForKey:@"category__description"]];
            NSDictionary *category = [[tagsInSection filteredArrayUsingPredicate:predicate] lastObject];
            NSInteger index = [tagsInSection indexOfObject:category];
            NSMutableArray *subArray = [[tagsInSection objectAtIndex:index] valueForKey:NSARRAY_GROUPING_OBJECTS_STRING];
            [subArray removeObject:tag];
            [tag release];
            
        }
        else{
            NSDictionary *tag = [filteredTags objectAtIndex:indexPath.row];
            [tag retain];
            [tagsInSection removeObject:tag];
            [appliedTags addObject:tag];
            [tag release];
            
        }
        [self.tableView reloadData];
        [self.searchDisplayController setActive:NO animated:YES];
    }
    else if(indexPath.section > 0){
        if([self isQuestionBased]){
            NSDictionary *tag = [[[tagsInSection objectAtIndex:indexPath.section-1] valueForKey:NSARRAY_GROUPING_OBJECTS_STRING] objectAtIndex:indexPath.row];
            [tag retain];
            [[[tagsInSection objectAtIndex:indexPath.section-1] valueForKey:NSARRAY_GROUPING_OBJECTS_STRING] removeObjectAtIndex:indexPath.row];
            [appliedTags addObject:tag];
            [tag release];
            
        }
        else{
            NSDictionary *tag = [tagsInSection objectAtIndex:indexPath.row];
            [tag retain];
            
            [tagsInSection removeObjectAtIndex:indexPath.row];
            [appliedTags addObject:tag];
            [tag release];
        }
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    }
}
- (BOOL)searchDisplayController:(UISearchDisplayController*)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
	
	[self filterContentForSearchText:controller.searchBar.text scope:[controller.searchBar.scopeButtonTitles objectAtIndex:self.searchDisplayController.searchBar.selectedScopeButtonIndex]];
	
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    
    
	[self filterContentForSearchText:searchString scope:[controller.searchBar.scopeButtonTitles objectAtIndex:self.searchDisplayController.searchBar.selectedScopeButtonIndex]];
	
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    
    if([self isQuestionBased]){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"description contains[cd] %@ || error_info contains[cd] %@",searchText,searchText];
        NSArray *allObjects = [tagsInSection ungroupArray];
        self.filteredTags = [[allObjects filteredArrayUsingPredicate:predicate] groupUsingKey:@"category__description"];
    }
    else{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"description contains[cd] %@",searchText];
        self.filteredTags = [tagsInSection filteredArrayUsingPredicate:predicate];
    }
    
    
    
}
@end
