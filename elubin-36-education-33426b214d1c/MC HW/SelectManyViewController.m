//
//  SelectManyViewController.m
//  MC HW
//
//  Created by Eric Lubin on 1/18/13.
//
//

#import "SelectManyViewController.h"
#import "ELAppDelegate.h"

@interface SelectManyViewController ()
@property (nonatomic,strong) NSArray *items;
@property (nonatomic,strong) NSMutableIndexSet *selectedRows;
@property (nonatomic,strong) NSMutableDictionary *student;
@end

@implementation SelectManyViewController

-(id)initWithItems:(NSArray*)items student:(NSMutableDictionary*)student
{
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.items = items;
        self.contentSizeForViewInPopover = CGSizeMake(320,500);
        NSArray *selected = student[[self studentKeyPath]];
        self.student = student;
        self.selectedRows = [NSMutableIndexSet indexSet];
        NSMutableDictionary *hashedKeys = [NSMutableDictionary dictionaryWithCapacity:[items count]];
        int x = 0;
        for(NSDictionary *item in items){
            hashedKeys[item[@"pk"]] = @(x);
            x++;
        }
        
        for(NSDictionary *selectedItem in selected){
            NSNumber *index = hashedKeys[selectedItem[@"pk"]];
            if(index != nil)
                [self.selectedRows addIndex:[index intValue]];
        }
        
        
        
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissWithoutSaving)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveChanges)];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)dismissWithoutSaving{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)saveChanges{
    ELAppDelegate *delegate = [ELAppDelegate sharedDelegate];
    TSUser *currentTutor = delegate.activeUser;
    NSArray *selections = [self.items objectsAtIndexes:self.selectedRows];
    NSString *error = [self verifySelectionsCompatibleWithTutor:currentTutor selectedItems:selections];
    if(error == nil){
        self.student[[self studentKeyPath]] = selections;
        [self dismissWithoutSaving];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Save" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}



///////THESE METHODS MUST BE OVERRIDEN IN SUBCLASSES
-(NSString*)verifySelectionsCompatibleWithTutor:(TSUser*)tutor selectedItems:(NSArray*)selectedItems{
    return nil;
}


-(NSString*)studentKeyPath{
    [NSException raise:@"This method must be overriden from the abstract parent class %@ in order to work correctly" format:NSStringFromClass([self class]),nil];
    return nil;
}


-(NSString*)keyPathOnItems{
    [NSException raise:@"This method must be overriden from the abstract parent class %@ in order to work correctly" format:NSStringFromClass([self class]),nil];

    return nil;
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
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = self.items[indexPath.row][[self keyPathOnItems]];
    if([self.selectedRows containsIndex:indexPath.row]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
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
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if([self.selectedRows containsIndex:indexPath.row]){
        [self.selectedRows removeIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else{
        [self.selectedRows addIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
