//
//  SpecificTagErrorViewController.m
//  MC HW
//
//  Created by Eric Lubin on 6/20/12.
//
//

#import "SpecificTagErrorViewController.h"
#import "NSArray+grouping.h"
#import "QuestionAttemptCell.h"
#import "UIViewController+AttemptLogic.h"
#import "GenericAttemptViewController.h"
@interface SpecificTagErrorViewController ()

@end

@implementation SpecificTagErrorViewController

- (id)init
{
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        self.contentSizeForViewInPopover = CGSizeMake(320,360);
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.info objectForKey:@"questions"] count]+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return 1;
    else{
        return [[[[self.info objectForKey:@"questions"] objectAtIndex:section-1] objectForKey:NSARRAY_GROUPING_OBJECTS_STRING] count];
    }
}
-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        //if([self dictionaryIsTagTitle:dict]){
        id text = [self.info objectForKey:@"error_info"];
        
        if(text != [NSNull null] && [text length] > 0){
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
    }
    
    
    return 45.0f;
}

-(NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0){
        id title = [self.info objectForKey:@"category_description"];
        if(title == [NSNull null])
            return nil;
        else
            return title;
    }
    else{
        return [[[self.info objectForKey:@"questions"] objectAtIndex:section-1] objectForKey:NSARRAY_GROUPING_SECTION_TITLE_STRING];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.detailTextLabel.numberOfLines = 0;
            cell.imageView.image = [UIImage imageNamed:@"DetailViewTag"];
        }
        cell.textLabel.text = [self.info objectForKey:@"description"];
        id error_info = [self.info objectForKey:@"error_info"];
        if(error_info == [NSNull null])
            cell.detailTextLabel.text = nil;
        else
            cell.detailTextLabel.text = error_info;
        return cell;
    }
    else{
        static NSString *CellID = @"questions";
        QuestionAttemptCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        if(cell == nil){
            cell = [[QuestionAttemptCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.enforceTimeLimit = self.enforceTimeLimit;
        }
        NSDictionary *question = [[[[self.info objectForKey:@"questions"] objectAtIndex:indexPath.section-1] objectForKey:NSARRAY_GROUPING_OBJECTS_STRING] objectAtIndex:indexPath.row];
        //NSDictionary *question = self.info[@"questions"][indexPath.section-1][NSARRAY_GROUPING_OBJECTS_STRING][indexPath.row];
        cell.object = question;
        return cell;
    }
    
    
    // Configure the cell...
    
    
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1){
        NSDictionary *attempt = [[[[self.info objectForKey:@"questions"] objectAtIndex:indexPath.section-1] objectForKey:NSARRAY_GROUPING_OBJECTS_STRING] objectAtIndex:indexPath.row];
        
        GenericAttemptViewController *vc = (GenericAttemptViewController*)attemptViewControllerForAttempt(attempt);
        if([vc isKindOfClass:[GenericAttemptViewController class]])
            vc.enforceTimeLimit = self.enforceTimeLimit;
        //vc.student = [self.objectInfo valueForKey:@"student"];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}

@end
