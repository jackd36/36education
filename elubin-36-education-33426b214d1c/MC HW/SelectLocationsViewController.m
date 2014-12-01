//
//  SelectLocationsViewController.m
//  MC HW
//
//  Created by Eric Lubin on 1/18/13.
//
//

#import "SelectLocationsViewController.h"

@interface SelectLocationsViewController ()

@end

@implementation SelectLocationsViewController


-(void)viewDidLoad  {
    [super viewDidLoad];
    self.navigationItem.title = @"Locations";
}
-(NSString*)studentKeyPath{
    return @"location";
}

-(NSString*)keyPathOnItems{
    return @"name";
}


-(NSString*)verifySelectionsCompatibleWithTutor:(TSUser *)tutor selectedItems:(NSArray *)selectedItems{
    
    //by definition this is true
    
//    if(!tutor.isAdmin ){
//        NSMutableSet *locations = [NSMutableSet setWithArray:[tutor.locations valueForKey:@"pk"]];
//        NSMutableSet *selectedItems = [NSMutableSet setWithArray:[selectedItems valueForKey:@"pk"]];
//        if(![locations intersectsSet:selectedItems])
//            return @"The desired student must have at least one location in common with the tutor adding it.";
//    }
    if([selectedItems count] == 0)
        return @"The desired student must be a member of at least one location.";
    
    return nil;
    
}


@end
