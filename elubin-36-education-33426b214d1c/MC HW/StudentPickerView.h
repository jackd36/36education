//
//  StudentPickerView.h
//  MC HW
//
//  Created by Eric Lubin on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StudentPickerView : UIControl <UIPickerViewDelegate,UIPickerViewDataSource>{
    NSArray *students;
}
@property (nonatomic,readonly) UIPickerView *pickerView;
@property (readwrite, strong) UIView *inputView;
@property (readwrite,strong) UIView *inputAccessoryView;
-(id)initWithObjects:(NSArray*)studs;
-(NSDictionary*)selectedUser;
-(void)selectUser:(NSDictionary*)dict;
@end
