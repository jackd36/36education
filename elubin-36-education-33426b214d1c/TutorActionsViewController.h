//
//  TutorActionsViewController.h
//  MC HW
//
//  Created by Eric Lubin on 10/21/12.
//
//

#import <UIKit/UIKit.h>
@class ThirtySixTutorStudentPickerViewController;
@interface TutorActionsViewController : UITableViewController <UIActionSheetDelegate,UIPopoverControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic,strong) TSUser *tutor;

@property (nonatomic,strong) NSDictionary *selectedStudent;

@property (nonatomic,strong) ThirtySixTutorStudentPickerViewController *studentPicker;
@end
