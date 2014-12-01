//
//  GenericAggregationViewController.h
//  MC HW
//
//  Created by Eric Lubin on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PullToRefreshTableViewController.h"

@interface GenericAggregationViewController : PullToRefreshTableViewController <UIPopoverControllerDelegate>
@property (nonatomic,strong) NSDictionary *objectInfo;
@property (nonatomic,copy) NSString *keyForObjectInfoDidLoad;
@property (nonatomic) NSInteger numberOfRowsInGrid;
@property (nonatomic) NSInteger numberOfRowsInSectionOne;
@property (nonatomic,retain) NSSet *studentsIDs;
@property (nonatomic) NSInteger tutorAided;
@property (nonatomic) NSInteger attemptReferrerID;//used to know when to popviewcontroller backwards
-(BOOL)isSecondSectionVisible;
-(NSArray*)arrayOfActiveSegment;
-(BOOL)onAttemptsTab;
-(NSString*)headerTitleForAggregates;
-(CGFloat)heightForRowInSecondSection;
-(NSString*)headerTitleForSecondSection;

@end
