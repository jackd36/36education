//
//  SelectObjectViewController.h
//  MC HW
//
//  Created by Eric Lubin on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SelectObjectViewController : UITableViewController <UIAlertViewDelegate>


@property (nonatomic,strong) NSMutableDictionary *assignment;
@property (nonatomic) NSInteger studentID;
@property (nonatomic) BOOL studentBased;
@property (nonatomic,copy) ASIBasicBlock alertViewAction;

@property (nonatomic,retain ) NSMutableDictionary *hashLookupTable;
-(id)initWithPastAssignments:(NSArray*)assignments;
@end
