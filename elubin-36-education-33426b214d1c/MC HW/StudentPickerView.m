//
//  StudentPickerView.m
//  MC HW
//
//  Created by Eric Lubin on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StudentPickerView.h"

@implementation StudentPickerView
@synthesize pickerView,inputView,inputAccessoryView;

-(id)initWithObjects:(NSArray*)studs{
    if (self = [super init]){
        students = [studs retain];
        pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
        //pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        pickerView.showsSelectionIndicator = YES;
        pickerView.dataSource = self;
        pickerView.delegate = self;
        self.inputView = pickerView;
//        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
//            UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 100, 35)];
//            toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//            toolbar.tintColor = kDefaultToolbarColor;
//            toolbar.items = [NSArray arrayWithObjects:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],[[[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(resignFirstResponder)] autorelease],nil];
//            inputAccessoryView =toolbar;
//        }
        
    }
    return self;
}
- (void)dealloc {
    
    [pickerView release];
    [inputView release];
    [students release];
    [inputAccessoryView release];
    [super dealloc];
}
-(void)selectUser:(NSDictionary*)dict{
    NSInteger index = [students indexOfObject:dict];
    if(index != NSNotFound)
        [pickerView selectRow:index inComponent:0 animated:NO];
}
-(NSDictionary*)selectedUser{
    return [students objectAtIndex:[pickerView selectedRowInComponent:0]];
}

    
- (BOOL) canBecomeFirstResponder {
    return YES;
}
-(void)pickerView:(UIPickerView *)pv didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
}
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [[students objectAtIndex:row] valueForKey:@"name"];
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [students count];
}
@end
