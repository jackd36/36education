//
//  PullToRefreshTableViewController.h
//  TableViewPull
//
//  Created by Eric Lubin on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "ELTableViewController.h"
@interface PullToRefreshTableViewController : UITableViewController     <EGORefreshTableHeaderDelegate>{
    EGORefreshTableHeaderView *_refreshHeaderView;
}

- (void)reloadTableViewDataSource;//override with logic to reload model
- (void)doneLoadingTableViewDataWithSuccess:(BOOL)success;//call after model is done reloading with success indicator
- (NSString*)uniqueURLPath;//overide to indicate location to save last-updated info
-(void)refreshLastUpdated; //used to tell the UI to update the last-updated date
@end
