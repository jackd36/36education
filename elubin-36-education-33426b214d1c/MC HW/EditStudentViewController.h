//
//  EditStudentViewController.h
//  MC HW
//
//  Created by Eric Lubin on 1/17/13.
//
//

#import <UIKit/UIKit.h>
NSString extern * const ADDED_NEW_STUDENT_NOTIFICATION;
NSString extern * const POPOVER_NEEDS_DISMISSING;
NSString extern * const SHOULD_DISMISS_POPOVER_FOR_STUDENTS_NOTIFICATION;
@interface EditStudentViewController : UITableViewController <UITextFieldDelegate,UIPopoverControllerDelegate>

-(id)initWithStudent:(NSMutableDictionary *)student timeOptions:(NSArray*)timeOptions allLocations:(NSArray*)locations allTutors:(NSArray*)allTutors;
@end
