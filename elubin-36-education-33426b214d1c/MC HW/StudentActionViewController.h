//
//  StudentActionViewController.h
//  MC HW
//
//  Created by Eric Lubin on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshTableViewController.h"

@class AttemptFilterViewController;
@interface StudentActionViewController : PullToRefreshTableViewController <UIActionSheetDelegate,UIAlertViewDelegate,UIPopoverControllerDelegate>{
    BOOL actionSheetVisible;
    
}

@property (nonatomic,strong) NSDictionary *student;
@property (nonatomic,strong) TSUser *tutor;

@property (nonatomic,strong) AttemptFilterViewController *attemptFilterController;





@end
