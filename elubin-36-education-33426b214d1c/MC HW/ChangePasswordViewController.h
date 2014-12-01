//
//  ChangePasswordViewController.h
//  MC HW
//
//  Created by Eric Lubin on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

NSString extern * const THIRTY_SIX_DID_CHANGE_PASSWORD;
@interface ChangePasswordViewController : UITableViewController <UITextFieldDelegate>
@property (nonatomic) BOOL disableCancelButton;
@property (nonatomic,copy) NSString *initialOldPassword;

@end
