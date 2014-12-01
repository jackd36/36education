//
//  SelectTutorsViewController.m
//  MC HW
//
//  Created by Eric Lubin on 1/18/13.
//
//

#import "SelectTutorsViewController.h"

@interface SelectTutorsViewController ()

@end

@implementation SelectTutorsViewController

-(void)viewDidLoad  {
    [super viewDidLoad];
    self.navigationItem.title = @"Tutors";
}
-(NSString*)studentKeyPath{
    return @"tutors";
}

-(NSString*)keyPathOnItems{
    return @"name";
}


-(NSString*)verifySelectionsCompatibleWithTutor:(TSUser *)tutor selectedItems:(NSArray *)selectedItems{

    return nil;
    
}

@end
