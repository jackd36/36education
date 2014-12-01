//
//  EditPasswordViewController.h
//  MC HW
//
//  Created by Eric Lubin on 1/19/13.
//
//

#import <UIKit/UIKit.h>
NSString extern * const NOTIFICATION_DID_SET_PASSWORD;

@interface EditPasswordViewController : UITableViewController <UITextFieldDelegate>
@property (nonatomic,strong) NSMutableDictionary *student;
@end
