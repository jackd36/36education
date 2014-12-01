//
//  ErrorInfoViewController.h
//  MC HW
//
//  Created by Eric Lubin on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshTableViewController.h"
@interface ErrorInfoViewController : PullToRefreshTableViewController
@property (nonatomic,strong) NSDictionary *objectInfo;
@property (nonatomic) BOOL enforceTimeLimit;
@end
