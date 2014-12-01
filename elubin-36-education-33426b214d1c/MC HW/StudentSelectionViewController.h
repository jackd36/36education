//
//  StudentSelectionViewController.h
//  MC HW
//
//  Created by Eric Lubin on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshTableViewController.h"

@interface StudentSelectionViewController : PullToRefreshTableViewController
//debug purposes

@property (nonatomic,strong) NSArray *users;
@property (nonatomic,strong) NSMutableSet *selectedUsers;
@end
