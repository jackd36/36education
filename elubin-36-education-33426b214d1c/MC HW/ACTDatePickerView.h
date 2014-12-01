//
//  ACTDatePickerView.h
//  MC HW
//
//  Created by Eric Lubin on 11/30/12.
//
//

#import <UIKit/UIKit.h>
NSString extern * const NOTIFICATION_DID_CHANGE_DATE;
@interface ACTDatePickerView : UIView <UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic,readonly) UIPickerView *pickerView;



-(NSString*)dateString;

-(void)selectDateComponents:(NSDateComponents*)components;


-(NSInteger)year;
-(NSInteger)month;

-(id)initWithAvailableMonths:(NSIndexSet*)dateNumbers width:(CGFloat)width;
@end
