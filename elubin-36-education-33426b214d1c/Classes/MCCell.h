//
//  MCCell.h
//  MC HW
//
//  Created by Eric Lubin on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCCell : UIView
@property (nonatomic,copy) NSString *cellString;
@property (nonatomic,getter = isAnswered) BOOL answered;
@property (nonatomic,getter = isCorrect) BOOL correct;
@property (nonatomic,getter = doesShowRightWrong) BOOL showsRightWrong;
@end
