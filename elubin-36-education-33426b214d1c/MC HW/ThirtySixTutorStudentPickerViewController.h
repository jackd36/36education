//
//  ThirtySixTutorStudentPickerViewController.h
//  MC HW
//
//  Created by Eric Lubin on 10/23/12.
//
//

#import <UIKit/UIKit.h>
NSString extern * const DID_CHANGE_STUDENT_SELECTION;
NSString extern * const DID_LOAD_CACHED_STUDENT_IPAD;

//these two notifications help signal the LeftViewControllerContainerSVC that the search is triggered and we need more or less screen real estate to accomadate the keyboard
NSString extern * const NEEDS_MORE_SCREEN_REAL_ESTATE;
NSString extern * const NEEDS_LESS_SCREEN_REAL_ESTATE;
NSString * const NEEDS_NO_SCREEN_REAL_ESTATE;
@interface ThirtySixTutorStudentPickerViewController : UITableViewController <UISearchDisplayDelegate>
//@property (nonatomic,strong) NSArray *allStudents;//an array of students, represented by dictionaries. Each dictionary has a @"first", @"last", and @"active", @"id" property
@property (nonatomic) NSInteger selectedStudentID;
@property (nonatomic,strong) TSUser *tutor;

-(void)scrollToSelectedUser:(BOOL)animated;
-(void)setViewActive:(BOOL)active animated:(BOOL)animated;
-(void)updateUserDataFromNotifications;
@end
