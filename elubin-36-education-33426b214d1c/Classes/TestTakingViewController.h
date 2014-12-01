//
//  TestTakingViewController.h
//  MC HW
//
//  Created by Eric Lubin on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
NSString extern * const THIRTY_SIX_DID_COMPLETE_ASSIGNMENT;
NSString extern * const THIRTY_SIX_CONNECTION_ERROR_ASSIGNMENT;
NSString extern * const THIRTY_SIX_ASSIGNMENT_STATUS_DID_CHANGE;

@class TSTestAbstractBase;
@interface TestTakingViewController : UITableViewController <UIAlertViewDelegate>{
    BOOL pauseButtonPressed;
    BOOL alertViewPresent;
    BOOL timeRanOut;
    BOOL fiveMinuteWarningTriggered;
}
@property (nonatomic,retain,readonly) TSTestAbstractBase *dataModel;
@property (nonatomic,getter = isPartOfTest) BOOL partOfTest;

-(id)initWithDataModel:(TSTestAbstractBase*)model;
@end
