//
//  ChooseTutorViewController.h
//  MC HW
//
//  Created by Eric Lubin on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshTableViewController.h"
@interface ChooseTutorViewController : PullToRefreshTableViewController <UIAlertViewDelegate>
@property (nonatomic) NSInteger studentID;
@property (nonatomic) NSInteger contentType;
@property (nonatomic) NSInteger objectID;
@property (nonatomic,retain) NSDictionary *assignment;
@end
