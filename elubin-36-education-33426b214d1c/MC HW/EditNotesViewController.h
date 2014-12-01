//
//  EditNotesViewController.h
//  iSHS
//
//  Created by Eric Lubin on 7/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditNotesViewController : UITableViewController <UIScrollViewDelegate>{
	UITextView *keyBoard;
}

@property (nonatomic,retain) NSMutableDictionary *assignment;


@end
