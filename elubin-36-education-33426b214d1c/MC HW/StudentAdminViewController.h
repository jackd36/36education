//
//  StudentAdminViewController.h
//  MC HW
//
//  Created by Eric Lubin on 1/17/13.
//
//

#import <UIKit/UIKit.h>
#import "TSHTTPRequestPullToRefreshViewController.h"

NSString extern * const UPDATE_STUDENTS_LIST_NOTIFICATION;
@class TSUser,ThirtySixTutorStudentPickerViewController;
@interface StudentAdminViewController : TSHTTPRequestPullToRefreshViewController <UISearchDisplayDelegate,UIAlertViewDelegate,UIPopoverControllerDelegate>
@property (nonatomic,strong) TSUser *tutor;
@property (nonatomic,weak) ThirtySixTutorStudentPickerViewController *delegate;
@end