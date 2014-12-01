//
//  SelectManyViewController.h
//  MC HW
//
//  Created by Eric Lubin on 1/18/13.
//
//

#import <UIKit/UIKit.h>

@interface SelectManyViewController : UITableViewController


-(id)initWithItems:(NSArray*)items student:(NSMutableDictionary*)student;



//must be overriden in subclasses
-(NSString*)studentKeyPath;
-(NSString*)keyPathOnItems;
-(NSString*)verifySelectionsCompatibleWithTutor:(TSUser*)tutor selectedItems:(NSArray*)selectedItems;
@end
