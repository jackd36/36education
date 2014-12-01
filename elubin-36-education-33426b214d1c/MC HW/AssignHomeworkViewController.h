//
//  AssignHomeworkViewController.h
//  MC HW
//
//  Created by Eric Lubin on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshTableViewController.h"
@interface AssignHomeworkViewController :PullToRefreshTableViewController


@property (nonatomic,strong) TSUser *tutor;

@property (nonatomic,strong) NSDictionary *student;


@end
