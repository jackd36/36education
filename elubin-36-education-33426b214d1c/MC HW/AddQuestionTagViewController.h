//
//  AddQuestionTagViewController.h
//  MC HW
//
//  Created by Eric Lubin on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
NSString extern * const QuestionDidModifyTags;
NSString extern * const PassageDidModifyTags;
@interface AddQuestionTagViewController : UITableViewController <UITextFieldDelegate,UIAlertViewDelegate>
@property (nonatomic) NSInteger questionIndex;
@property (nonatomic) NSInteger questionOffset;
@property (nonatomic) NSInteger contentType;
@property (nonatomic) NSInteger objectID;
@property (nonatomic,copy) NSString *sectionName;
@property (nonatomic) BOOL waitForRequestCompletion;
@property (nonatomic,copy) NSString *descriptionOfContent;
@end
