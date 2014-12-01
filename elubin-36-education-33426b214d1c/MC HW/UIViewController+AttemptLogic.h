//
//  UIViewController+AttemptLogic.h
//  MC HW
//
//  Created by Eric Lubin on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GenericAttemptViewController;
@class GenericAggregationViewController;
UIViewController *attemptViewControllerForAttempt(NSDictionary* attempt);
GenericAggregationViewController *aggregationViewControllerForAttempt(NSDictionary* attempt);

