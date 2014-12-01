//
//  CustomizeAssignmentViewController.h
//  MC HW
//
//  Created by Eric Lubin on 6/24/12.
//
//

#import <UIKit/UIKit.h>
#import "PullToRefreshTableViewController.h"

@class SelectObjectViewController;
@interface CustomizeAssignmentViewController : UITableViewController
//@property (nonatomic) NSInteger contentType;
//@property (nonatomic) NSInteger objectID;
@property (nonatomic,strong) NSMutableDictionary *assignment;
@property (nonatomic) NSInteger studentID;
@property (nonatomic,weak) SelectObjectViewController *delegate;
@property (nonatomic,strong ) NSMutableDictionary *hashLookupTable;
@property (nonatomic) BOOL inPopover;
@property (nonatomic) BOOL readOnly;//allows us to display the subset for viewing, or for editing
@end
