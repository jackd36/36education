//
//  ACTScoresViewController.h
//  MC HW
//
//  Created by Eric Lubin on 11/9/12.
//
//

#import <UIKit/UIKit.h>
#import "PullToRefreshTableViewController.h"

@interface ACTScoresViewController : PullToRefreshTableViewController <UIPopoverControllerDelegate,UIActionSheetDelegate>


@property NSInteger studentID;
@end
