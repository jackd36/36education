//
//  AppStartViewController.h
//  MC HW
//
//  Created by Eric Lubin on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppStartViewController : UIViewController <UITextFieldDelegate,UIAlertViewDelegate>
@property (nonatomic,strong) UITextField *username;
@property (nonatomic,strong) UITextField *password;
//@property (nonatomic,strong) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL animatedNavBar;
@end
