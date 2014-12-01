//
//  AttemptFilterViewController.h
//  MC HW
//
//  Created by Eric Lubin on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
NSString extern * const THIRYSIX_DID_CHANGE_FILTER_PARAMS;
@interface AttemptFilterViewController : UIViewController


-(NSString*)prettyFilterString;
-(NSString*)filterGetRequest;
-(NSInteger)activeState;
-(BOOL)isFilteredBySection;
@property (nonatomic) NSInteger oldStateBitMask;
//@property (nonatomic,copy) NSString *cachedFilterString;
@end
