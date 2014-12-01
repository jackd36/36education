//
//  StudentPickerViewController.h
//  MC HW
//
//  Created by Eric Lubin on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class StudentPickerView;
@interface StudentPickerViewController : UIViewController


@property (nonatomic,readonly) StudentPickerView *pickerView;

-(id)initWithObjects:(NSArray*)students;
@end
