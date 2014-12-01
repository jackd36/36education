//
//  StudentPickerViewController.m
//  MC HW
//
//  Created by Eric Lubin on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StudentPickerViewController.h"
#import "StudentPickerView.h"
@interface StudentPickerViewController ()

@end

@implementation StudentPickerViewController
@synthesize pickerView;
-(id)initWithObjects:(NSArray*)students{
    if(self = [super init]){
        pickerView = [[StudentPickerView alloc] initWithObjects:students];
        self.contentSizeForViewInPopover = CGSizeMake(320,216);
        self.navigationItem.title = @"Select a Student";
    }
    return self;
}
- (void)dealloc
{
    [pickerView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.pickerView.inputView.frame = CGRectMake(0,0,320,300);
    [self.view addSubview:pickerView.inputView];
    //pickerView.inputView.frame = CGRectMake(0,0,400,200);
    //self.view.backgroundColor = [UIColor whiteColor];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
