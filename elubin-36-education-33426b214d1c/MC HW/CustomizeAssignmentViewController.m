//
//  CustomizeAssignmentViewController.m
//  MC HW
//
//  Created by Eric Lubin on 6/24/12.
//
//

#import "CustomizeAssignmentViewController.h"
#import "SelectObjectViewController.h"
#import "NSMutableDictionary+MC_Grades.h"
@interface CustomizeAssignmentViewController ()
@property (nonatomic,copy) NSString *sectionTitle;
@property (nonatomic,strong) NSArray *children;
@property (nonatomic,strong) NSMutableIndexSet *selectedIndices;
@property (nonatomic,strong) NSIndexPath *previouslyCrossedIndexPath;
@property (nonatomic) NSComparisonResult highlightingDirection;
@property (nonatomic) NSComparisonResult previousDraggingDirection;
@property (nonatomic,strong) UIBarButtonItem *selectAllButton;
@property (nonatomic,strong) UIBarButtonItem *deselectAllButton;
@property (nonatomic,strong) UIBarButtonItem *oddButton;
@property (nonatomic,strong) UIBarButtonItem *evenButton;
@property (nonatomic) BOOL loadedStatus;
@property (nonatomic) NSInteger childContentType;

@end

@implementation CustomizeAssignmentViewController

- (id)init
{

    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        //self.selectedIndices =[NSMutableIndexSet indexSet];
        self.contentSizeForViewInPopover = CGSizeMake(320,300);
        // Custom initialization
    }
    return self;
}

-(void)dismiss{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)loadProgressOfChildren{
    
    
    __block TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:[NSString stringWithFormat:@"students/%d/completed/?content_type=%d&object_id=%d",self.studentID,self.contentType,self.objectID]];
    __weak TSHTTPRequest *weakRequest = request;
    request.completionBlock = ^{
        _loadedStatus = YES;
        NSArray *results = [[weakRequest.responseData JSONValue] valueForKey:@"previous_completed"];
        
        for(NSDictionary *attempt in results){
            NSNumber *attemptID = [attempt valueForKey:@"id"];
            
            AssignmentIndicatorType type;
            if([[attempt valueForKey:@"completed"] boolValue])
                type = IndicatorTypeComplete;
            else
                type = IndicatorTypeAssignedAndIncomplete;
            
            [_hashLookupTable addInt:type forContentType:@(self.childContentType) andObjectID:attemptID];
        }
        NSLog(@"%@",_hashLookupTable);
        //NSLog(@"%@",objects);
        
        [self.tableView reloadData];

    };
    
    [request startAsynchronous];
}


-(void)saveSelection{
    
    
    NSArray *primaryKeys = [[self.children objectsAtIndexes:self.selectedIndices] valueForKey:@"id"];
    
    if([self.selectedIndices count] == self.children.count){
        [_assignment removeObjectForKey:@"subset"];
        _assignment[@"is_subset"] = @NO;
    }
    else{
        [_assignment setValue:primaryKeys forKey:@"subset"];
        _assignment[@"is_subset"] = @YES;
    }

    
    if(_delegate != nil)
        self.delegate.alertViewAction();
    else{
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
}
-(void)selectAllItems{
    self.selectedIndices = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.children.count)];
    [self reloadBarButtonItems];
    [self.tableView reloadData];
}

-(void)deselectAll{
    self.selectedIndices = [NSMutableIndexSet indexSet];
    [self reloadBarButtonItems];
    [self.tableView reloadData];
}

-(void)selectOdd{
    self.selectedIndices = [self indexSetWithEvenItems:NO];
    [self reloadBarButtonItems];
    [self.tableView reloadData];
    
}

-(void)selectEven{
    self.selectedIndices = [self indexSetWithEvenItems:YES];
    [self reloadBarButtonItems];
    [self.tableView reloadData];
}

-(void)reloadBarButtonItems{
    UIBarButtonItem *disabledButton = nil;
    if([self.selectedIndices count] == self.children.count){
        disabledButton = self.selectAllButton;
    }
    else if([self.selectedIndices count] == 0)
        disabledButton = self.deselectAllButton;
    else if([self.selectedIndices isEqualToIndexSet:[self indexSetWithEvenItems:YES]])
        disabledButton = self.evenButton;
    else if([self.selectedIndices isEqualToIndexSet:[self indexSetWithEvenItems:NO]])
        disabledButton = self.oddButton;
    
    for (UIBarButtonItem *button in self.toolbarItems) {
        button.enabled = button != disabledButton;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = self.selectedIndices.count > 0 || self.readOnly;
}
-(NSMutableIndexSet*)indexSetWithEvenItems:(BOOL)even{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for(NSInteger x = (int)even;x<self.children.count;x+=2)
        [indexSet addIndex:x];
    
    return indexSet;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if(IS_IOS_7)
        self.tableView.backgroundColor = kDefaultTableViewBackgroundColor;
    
    if(!_readOnly){
        self.navigationItem.title = @"Customize";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveSelection)];
        self.navigationItem.prompt = @"Tap an item below to assign it to the student.";
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        self.selectAllButton = [[UIBarButtonItem alloc] initWithTitle:@"Select All" style:UIBarButtonItemStyleDone target:self action:@selector(selectAllItems)];
        self.deselectAllButton = [[UIBarButtonItem alloc] initWithTitle:@"Deselect All" style:UIBarButtonItemStyleBordered target:self action:@selector(deselectAll)];
        self.oddButton = [[UIBarButtonItem alloc] initWithTitle:@"Odd" style:UIBarButtonItemStyleBordered target:self action:@selector(selectOdd)];
        self.evenButton = [[UIBarButtonItem alloc] initWithTitle:@"Even" style:UIBarButtonItemStyleBordered target:self action:@selector(selectEven)];
        self.toolbarItems = @[ self.selectAllButton,flexibleSpace,self.deselectAllButton,flexibleSpace,self.oddButton, flexibleSpace,self.evenButton] ;
    }
    else{
        if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
            self.navigationItem.title = @"Custom Homework Assignment";
        else{
            self.navigationItem.title = @"Custom HW";
        }
        
        if(!_inPopover)
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
        
    }
    
    if(self.assignment[@"id"] != nil && _delegate == nil && _assignment[@"subset"] == nil){
        //webrequest this shit, block UI with loading thing then once done, we reloadtableviewdatasource.
        NSString *url = [NSString stringWithFormat:@"hw/%@/subset_info/",self.assignment[@"id"]];
        __block TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:url];
        __weak TSHTTPRequest *weakRequest = request;
        request.useSVProgressHUD = NO;
        request.cachePolicy = ASIAskServerIfModifiedCachePolicy;
        request.secondsToCache = 7*86400;
        request.useSVProgressHUD = YES;
        request.progressMaskType = SVProgressHUDMaskTypeClear;
        request.completionBlock = ^{
            _assignment[@"subset"] = [weakRequest.responseData JSONValue][@"subset"];
            if(self.children == nil)
                [self reloadTableViewDataSource];
        };
        [request startAsynchronous];
    }
    else{
        if(self.children == nil)
            [self reloadTableViewDataSource];
    }
    
    
    self.tableView.allowsMultipleSelection = YES;
    
    if(!_readOnly){
        UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        gestureRecognizer.allowableMovement = MAXFLOAT;
        gestureRecognizer.minimumPressDuration = 0.5;
        [self.view addGestureRecognizer:gestureRecognizer];
    }
    
    if(!_loadedStatus && !_readOnly)
        [self loadProgressOfChildren];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)longPress:(UILongPressGestureRecognizer*)gesture{
    if(gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged || gesture.state == UIGestureRecognizerStatePossible){
        CGPoint location = [gesture locationInView:self.view];
        NSIndexPath *path = [self.tableView indexPathForRowAtPoint:location];
        if(gesture.state == UIGestureRecognizerStateBegan){
            
            if(path == nil){
                gesture.enabled = NO;
                return;
            }
            self.previouslyCrossedIndexPath = path;
            self.highlightingDirection = NSOrderedSame;
            self.previousDraggingDirection = NSOrderedSame;
            [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        else if(gesture.state == UIGestureRecognizerStateChanged){
            if(path != nil && ![path isEqual:self.previouslyCrossedIndexPath]){
                NSComparisonResult orderOfSelection = [path compare:self.previouslyCrossedIndexPath];
                
                if(self.highlightingDirection == NSOrderedSame || orderOfSelection == self.highlightingDirection){
                    if(self.highlightingDirection != NSOrderedSame && self.previousDraggingDirection != orderOfSelection){
                       
                        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:path.row-self.highlightingDirection inSection:path.section] animated:NO scrollPosition:UITableViewScrollPositionNone];
                    }
                    [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
                    self.highlightingDirection = orderOfSelection;
                }
                else{
                    if(self.previousDraggingDirection != orderOfSelection){
                        NSInteger row;
                        if(self.previousDraggingDirection == self.highlightingDirection){
                            row=path.row+self.previousDraggingDirection;
                        }
                        else{
                            row=path.row-self.previousDraggingDirection;
                        }
                        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:path.section] animated:NO];
                    }
                    [self.tableView deselectRowAtIndexPath:path animated:NO];
                }
                
                self.previouslyCrossedIndexPath = path;
                if(orderOfSelection != NSOrderedSame)
                    self.previousDraggingDirection = orderOfSelection;
                //self.previousOrderOfSelection = orderOfSelection;
                    
            }
            
        }
        else if(gesture.state == UIGestureRecognizerStatePossible){
            if(path != nil){
                [self.tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
        }
        
        //scroll if needed
        
        if(self.tableView.contentSize.height > self.tableView.bounds.size.height){ //checks if the tableview needs scrolling
            CGFloat verticalDiff = self.tableView.bounds.size.height-location.y+self.tableView.contentOffset.y+self.navigationController.toolbar.bounds.size.height;
            NSLog(@" %f",verticalDiff);
        }
        //NSArray *visibleCells = [self.tableView indexPathsForVisibleRows];
        //if([visibleCells[visibleCells.count-2] isEqual:path]){ //shoud also check that the content allows scrolling
            
            //[self.tableView setContentOffset:CGPointMake(0,self.tableView.contentOffset.y+10*self.previousDraggingDirection) animated:YES];
        //}
    }

    else if(gesture.state == UIGestureRecognizerStateEnded){
        for (NSIndexPath *path in self.tableView.indexPathsForSelectedRows) {
            [self tableView:self.tableView didSelectRowAtIndexPath:path];
        }
        
    }
    
    
}

-(NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section{
    return self.sectionTitle;
}

-(NSString*)tableView:(UITableView*)tableView titleForFooterInSection:(NSInteger)section{
    if(!_readOnly)
        return @"Long press a cell and then drag to highlight multiple cells at once.";

    return nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait) || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

#pragma mark - Table view data source

-(NSString*)uniqueURLPath{
    return [NSString stringWithFormat:@"object/%d/id/%d/hierarchy/",self.contentType,self.objectID];
}


-(NSInteger)contentType{
    return [[_assignment valueForKey:@"content_type"] integerValue];
}

-(NSInteger)objectID{
    return [[_assignment valueForKey:@"object_id"] integerValue];
}

-(void)reloadTableViewDataSource{
    __block TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:[self uniqueURLPath]];
    request.useSVProgressHUD = NO;
    request.cachePolicy = ASIAskServerIfModifiedWhenStaleCachePolicy;
    request.secondsToCache = 7*86400;
    __weak TSHTTPRequest *weakRequest = request;
    request.completionBlock = ^{
        NSDictionary *results = [weakRequest.responseData JSONValue];
        id info = results[@"info"];
        if([info isKindOfClass:[NSDictionary class]])
            info = [[info allValues] lastObject];
        self.sectionTitle = [info componentsJoinedByString:@" \u2192 "];
        self.children = results[@"listing"];
        self.childContentType = [results[@"child_content_type"] integerValue];
        if(_assignment[@"subset"] == nil)
            self.selectedIndices = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.children.count)];
        else{
            NSSet *set = [NSSet setWithArray:_assignment[@"subset"]];
            
            NSMutableIndexSet *indexSetHits = [NSMutableIndexSet indexSet];
            for(int x = 0;x<[self.children count];x++){
                if([set containsObject:self.children[x][@"id"]]){
                    [indexSetHits addIndex:x];
                }
            }
            self.selectedIndices = indexSetHits;
        }
        [self.tableView reloadData];
        
        
        
        [self reloadBarButtonItems];
        
        BOOL hideToolbar = _readOnly || [results[@"hide_toolbar"] boolValue];
        if(hideToolbar != self.navigationController.toolbarHidden){
            [self.navigationController setToolbarHidden:hideToolbar animated:YES];
        }
        //[self doneLoadingTableViewDataWithSuccess:YES];
    };

    [request startAsynchronous];
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.children count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.indentationWidth = 23.0f;
    }
    if([self.selectedIndices containsIndex:indexPath.row])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSDictionary *object = self.children[indexPath.row];
    cell.textLabel.text = object[@"textLabel"];
    cell.detailTextLabel.text = object[@"detailTextLabel"];
    
    cell.indentationLevel = 0.0;
    
    if(_readOnly){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else{
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    
    if(self.navigationController.toolbarHidden && !_readOnly){
        NSNumber *ct = @(self.childContentType);
        
        
        
        NSDictionary *contentTypeDict = [_hashLookupTable objectForKey:ct];
        
        NSNumber *objectID = object[@"id"];
        
        AssignmentIndicatorType activity = [[contentTypeDict objectForKey:objectID] integerValue];
        if(contentTypeDict[objectID] == nil && !_loadedStatus){
            activity = IndicatorTypeComplete;
        }
        cell.indentationLevel = 0.0;
        switch (activity) {
            case IndicatorTypeUnassigned:
                cell.imageView.image = [UIImage imageNamed:@"unread_unassigned"];
                cell.imageView.highlightedImage = [UIImage imageNamed:@"unread_pressed"];
                break;
            case IndicatorTypeAssignedAndUnread:
                cell.imageView.image = [UIImage imageNamed:@"unread"];
                cell.imageView.highlightedImage = [UIImage imageNamed:@"unread_pressed"];
                break;
            case IndicatorTypeAssignedAndIncomplete:
                cell.imageView.image = [UIImage imageNamed:@"unread_partial"];
                cell.imageView.highlightedImage = [UIImage imageNamed:@"unread_partial_pressed"];
                break;
            case IndicatorTypeComplete:
                cell.imageView.image = nil;
                cell.imageView.highlightedImage = nil;
                cell.indentationLevel = 1.0;
                break;
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if([self.selectedIndices containsIndex:indexPath.row]){
        [self.selectedIndices removeIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else{
        [self.selectedIndices addIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
        
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self reloadBarButtonItems];
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_readOnly){
        return nil;
    }
    return indexPath;
}
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return !_readOnly;
}
@end
