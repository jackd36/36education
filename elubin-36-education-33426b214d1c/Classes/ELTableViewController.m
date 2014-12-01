//
//  ELTableViewController.m
//  MC HW
//
//  Created by Eric Lubin on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ELTableViewController.h"

@implementation ELTableViewController
@synthesize tableView,clearsSelectionOnViewWillAppear,headerView;
-(id)init{
    if(self = [self initWithStyle:UITableViewStylePlain]){
        
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style{
    if(self = [super init]){
        _style = style;
        clearsSelectionOnViewWillAppear = YES;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(clearsSelectionOnViewWillAppear)
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView flashScrollIndicators];
}
-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

- (void)dealloc {
    [headerView release];
    [tableView release];
    [super dealloc];
}
#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    if(tableView != nil){
        [tableView removeFromSuperview];
        self.tableView = nil;
    }
    UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:_style];
    tv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tv.delegate = self;
    
    tv.dataSource = self;
    self.tableView = tv;
    [self.view addSubview:tv];
//    if(self.tableView.style == UITableViewStyleGrouped){
//        if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
//            self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top, 143, self.tableView.contentInset.bottom, 143);
//        }
//    }
}

-(void)setHeaderView:(UIView *)hv{
    
    [headerView removeFromSuperview];
    [headerView release];
    headerView = [hv retain];
    if(hv == nil)
        return;
    CGRect frame = headerView.frame;
    frame.origin = CGPointMake(0, 0);
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    CGRect tableViewFrame = tableView.frame;
    tableViewFrame.origin.y=headerView.frame.size.height;
    tableViewFrame.size.height=self.view.bounds.size.height-tableViewFrame.origin.y;
    tableView.frame=tableViewFrame;
    headerView.frame = frame;
    [self.view addSubview:headerView];
    
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.headerView = nil;
    self.tableView = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 0;
}
-(UITableViewCell*)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell...
    
    return cell;
}
@end
