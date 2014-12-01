//
//  AssignmentInfoViewController.h
//  iSHS
//
//  Created by Eric Lubin on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>



NSString extern * const  THIRTYSIX_ED_DID_ADD_ASSIGNMENT;
NSString extern * const  THIRTYSIX_ED_DID_CHANGE_ASSIGNMENT;
//@class AssignmentsViewController;
@interface AssignmentInfoViewController : UITableViewController <UIAlertViewDelegate,UIPopoverControllerDelegate>
@property (nonatomic,strong) NSMutableDictionary *activeAssignment;


@property (nonatomic, getter=isStudentBasedView) BOOL studentBasedView;



@property (nonatomic,strong) NSDictionary *student;
@property (nonatomic,strong ) NSArray *allAssignments; //used to pass into SelectObjectsViewController


@end
