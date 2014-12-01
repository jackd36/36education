//
//  ACTDatePickerView.m
//  MC HW
//
//  Created by Eric Lubin on 11/30/12.
//
//

#import "ACTDatePickerView.h"
@interface ACTDatePickerView()
@property (nonatomic,strong) NSArray *monthSymbols;
@property (nonatomic,strong) NSArray *monthNumbers; //simply contains an array of month numbers, so we can obtain our current month at any time
@property (nonatomic,strong) NSDictionary *monthMappings;
@property (nonatomic) NSRange yearRange;
@end
NSString * const NOTIFICATION_DID_CHANGE_DATE = @"NOTIFICATION_DID_CHANGE_DATE";
NSInteger const heightForPicker = 216;
@implementation ACTDatePickerView

-(id)initWithAvailableMonths:(NSIndexSet*)dateNumbers width:(CGFloat)width{
    if (self = [self initWithFrame:CGRectMake(0,0,width,heightForPicker)]){
        
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy";
        NSArray *allMonths = [dateFormatter monthSymbols];
        self.monthSymbols = [allMonths objectsAtIndexes:dateNumbers];

        //create hash table for effiency key=>value. The keys are the month numbers 1-12, the values are their corresponding indices in the self.monthSymbols array
        NSMutableArray *monthNumbers = [NSMutableArray arrayWithCapacity:[_monthSymbols count]];
        NSMutableDictionary *map = [NSMutableDictionary dictionaryWithCapacity:[_monthSymbols count]];
        __block NSInteger count = 0;
        
        [dateNumbers enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            NSNumber *month = @(idx+1);
            [monthNumbers addObject:month];
            map[month] = @(count);
            count++;
        }];
        self.monthMappings = map;
        self.monthNumbers = monthNumbers;
        NSCalendar *gregorian = [NSCalendar currentCalendar];
        NSDateComponents *components = [gregorian components:NSYearCalendarUnit fromDate:[NSDate date]];
        NSInteger currentYear = [components year];
        
        _yearRange = NSMakeRange(currentYear-5, 7);
        
        
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, width, heightForPicker)];
        _pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _pickerView.showsSelectionIndicator = YES;
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        
        [self addSubview:_pickerView];
    }
    return self;
}



-(NSInteger)year{
    NSInteger row = [_pickerView selectedRowInComponent:1];
    return _yearRange.location+row;
}
-(NSInteger)month{
    
    return [self.monthNumbers[[_pickerView selectedRowInComponent:0]] integerValue];
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DID_CHANGE_DATE object:nil];
}
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if(component == 0){
        return _monthSymbols[row];
    }
    else{
        return [NSString stringWithFormat:@"%d",_yearRange.location+row];
    }
}

-(NSString*)dateString{
    return [NSString stringWithFormat:@"%@ %@",[self pickerView:_pickerView titleForRow:[_pickerView selectedRowInComponent:0] forComponent:0],[self pickerView:_pickerView titleForRow:[_pickerView selectedRowInComponent:1] forComponent:1]];
    
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(component == 0){
        return [_monthSymbols count];
        
    }
    else{
        return _yearRange.length;
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}
-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    CGFloat widthOfComponent2= .3f;
    if(component == 0)
        return pickerView.bounds.size.width*(1-widthOfComponent2);
    return pickerView.bounds.size.width*widthOfComponent2-30;
}
-(void)selectDateComponents:(NSDateComponents*)components{
    //selects the desired components in the picker, if possible
    
    
    NSNumber *indexToSelectForMonthObject = self.monthMappings[@(components.month)];
    
    NSInteger indexToSelectForMonth = NSNotFound;
    if(indexToSelectForMonthObject != nil)
        indexToSelectForMonth = [indexToSelectForMonthObject integerValue];
    [self selectYearInPicker:components.year];
    
    if(indexToSelectForMonth != NSNotFound){
        [_pickerView selectRow:indexToSelectForMonth inComponent:0 animated:NO];
    }
    else{
        //pick closest to that month, in the past, that is valid
        
        CGPoint newPoints = [self recursiveSearch:components.month year:components.year];
        [_pickerView selectRow:newPoints.x inComponent:0 animated:NO];
        if(newPoints.y != components.year)
            [self selectYearInPicker:newPoints.y];
        
    }
}
           
-(void)selectYearInPicker:(NSInteger)year{
    NSInteger indexToSelectForYear = year - _yearRange.location;
    
    if(indexToSelectForYear < 0 || indexToSelectForYear >= _yearRange.length){
        //recalculate and rehash based on needed values
        
        if(indexToSelectForYear < 0){
            _yearRange = NSMakeRange(_yearRange.location+indexToSelectForYear, _yearRange.length-indexToSelectForYear);
        }
        else{
            _yearRange = NSMakeRange(_yearRange.location, indexToSelectForYear+1);
        }
        [_pickerView reloadComponent:1];
        
    }
    [_pickerView selectRow:indexToSelectForYear inComponent:1 animated:NO];
}
-(CGPoint)recursiveSearch:(NSInteger)month year:(NSInteger)year{
    NSNumber *monthIndex = self.monthMappings[@(month)];
    if(monthIndex != nil){
        return CGPointMake(monthIndex.integerValue, year);
    }
    else{
        if(month == 1){
            return [self recursiveSearch:12 year:year-1];
        }
        else{
            return [self recursiveSearch:month-1 year:year];
        }
    }
}

@end
