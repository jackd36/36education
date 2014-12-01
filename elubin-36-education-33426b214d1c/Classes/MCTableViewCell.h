//
//  MCTableViewCell.h
//  MC HW
//
//  Created by Eric Lubin on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCStyledControl.h"
@interface MCTableViewCell : UITableViewCell
@property (nonatomic,strong,readonly) MCStyledControl *multipleChoiceControl;
@property (nonatomic,strong,readonly) UIButton *questionNumber;

- (id)initWithNumberOfChoices:(NSInteger)numChoices offset:(BOOL)offset tutor:(BOOL)tutor orientation:(UIInterfaceOrientation)orientation reuseIdentifier:(NSString *)reuseIdentifier;


@end
