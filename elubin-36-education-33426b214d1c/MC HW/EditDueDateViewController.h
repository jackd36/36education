//
//  EditDueDateViewController.h
//  iSHS
//
//  Created by Eric Lubin on 7/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EditDueDateViewController : UITableViewController <UIActionSheetDelegate>
@property (nonatomic,retain) NSMutableDictionary *assignment;
@property (nonatomic,retain) UIDatePicker *picker;
@property (nonatomic,retain) NSDateFormatter *df;

@end
