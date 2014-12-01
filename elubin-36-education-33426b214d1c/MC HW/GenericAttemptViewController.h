//
//  GenericAttemptViewController.h
//  MC HW
//
//  Created by Eric Lubin on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshTableViewController.h"
#import "WEPopoverController.h"
@interface GenericAttemptViewController : PullToRefreshTableViewController <UIActionSheetDelegate,UIPopoverControllerDelegate,WEPopoverControllerDelegate>{
    BOOL showingActionSheet;
}

@property (nonatomic,copy) NSString *subListingCellClassName;

@property (nonatomic,strong) NSDictionary *objectInfo;

@property (nonatomic) BOOL hideAggregationFeature;//used to prevent infinite looping
@property (nonatomic) BOOL enforceTimeLimit;
//-(void)setStudent:(NSString*)studentName;

-(BOOL)assignmentWasTimed;
-(BOOL)allowsSubListingEditing;
-(BOOL)enforceTimeLimitInUI;
-(BOOL)canShowErrors;
@end
