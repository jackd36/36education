//
//  ViewAssignmentViewController.h
//  MC HW
//
//  Created by Eric Lubin on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshTableViewController.h"

@interface ViewAssignmentViewController : PullToRefreshTableViewController <UIActionSheetDelegate,UIPopoverControllerDelegate,UISplitViewControllerDelegate>{
    BOOL actionSheetVisible;
}
@property (nonatomic,strong) TSUser *student;
@end
