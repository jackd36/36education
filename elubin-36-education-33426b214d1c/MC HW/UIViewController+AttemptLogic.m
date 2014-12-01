//
//  UIViewController+AttemptLogic.m
//  MC HW
//
//  Created by Eric Lubin on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIViewController+AttemptLogic.h"
#import "PassageAttemptViewController.h"
#import "SectionAttemptViewController.h"
#import "TestAttemptViewController.h"

#import "SectionAggregationViewController.h"
#import "TestAggregationViewController.h"
#import "PassageAggregationViewController.h"
#import "QuestionAggregationViewController.h"
UIViewController *attemptViewControllerForAttempt(NSDictionary* attempt){
   
    NSString *type = [attempt valueForKey:@"type"];
    GenericAttemptViewController *vc = nil;
    if([type isEqualToString:@"Passage"]){
        vc = [[PassageAttemptViewController alloc] init];
    }
    else if([type isEqualToString:@"Section"]){
        vc = [[SectionAttemptViewController alloc] init];
        
    }
    else if([type isEqualToString:@"Test"]){
        vc = [[TestAttemptViewController alloc] init];
    }
    else if([type isEqualToString:@"Question"]){
        NSDictionary *info = [attempt dictionaryWithValuesForKeys:[NSArray arrayWithObjects:@"type",@"object_content_type",@"object_id", nil]];
        GenericAggregationViewController *vc =  aggregationViewControllerForAttempt(info);
        vc.objectInfo = info;
        return vc;
    }
    if(vc == nil)
        [NSException raise:@"Invalid attempt type" format:@"The attempt type \"%@\" was not recognized by the script",type];
    
    vc.objectInfo = attempt;
    return [vc autorelease];
}

GenericAggregationViewController *aggregationViewControllerForAttempt(NSDictionary* attempt){
    NSString *type = [attempt valueForKey:@"type"];
    GenericAggregationViewController *vc = nil;

    if([type isEqualToString:@"Passage"]){
        vc = [[PassageAggregationViewController alloc] init];
    }
    else if([type isEqualToString:@"Section"]){
        vc = [[SectionAggregationViewController alloc] init];
        
    }
    else if([type isEqualToString:@"Test"]){
        vc = [[TestAggregationViewController alloc] init];
    }
    else if([type isEqualToString:@"Question"]){
        vc = [[QuestionAggregationViewController alloc] init];
    }
    if(vc == nil)
        [NSException raise:@"Invalid aggregation type" format:@"The attempt type \"%@\" was not recognized by the script",type];
    
    vc.objectInfo = attempt;
    vc.attemptReferrerID = [[attempt valueForKey:@"object_id"] integerValue];
    return [vc autorelease];
}