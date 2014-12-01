//
//  EditACTScoreViewController.h
//  MC HW
//
//  Created by Eric Lubin on 11/13/12.
//
//

#import <UIKit/UIKit.h>
#import "ELTableViewController.h"
@class ACTResult;
NSString extern * const SHOULD_DISMISS_POPOVER_FOR_ACTS_NOTIFICATION;
NSString extern * const DID_MODIFY_ACT_SCORE_OBJECT;
NSString extern * const DID_ADD_ACT_SCORE_OBJECT;
@interface EditACTScoreViewController : ELTableViewController <UITextFieldDelegate,UIAlertViewDelegate,UIPopoverControllerDelegate>
- (id)initWithVerboseNames:(NSArray*)verbose sectionNames:(NSArray*)snames allowedRanges:(NSArray*)allowedRanges validMonths:(NSIndexSet*)validMonths actResult:(ACTResult*)result;

@property (nonatomic) NSInteger studentID;
@end
