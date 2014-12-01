//
//  TutorActionsDataSource.m
//  MC HW
//
//  Created by Eric Lubin on 11/9/12.
//
//

#import "TutorActionsDataSource.h"
#import "MTSlideViewControllerDefines.h"
#import "UIImage+extensions.h"
@interface TutorActionsDataSource()
@property (nonatomic,strong) NSArray *sections;
@end

@implementation TutorActionsDataSource
-(id)initWithAdmin:(BOOL)isAdmin{
    if(self = [self init]){
        
        NSArray *plist = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TutorActionsDataSource" ofType:@"plist"]];
        
        self.sections = [self transformSections:plist forAdmin:isAdmin];
        
    }
    return self;
}

-(NSArray*)transformSections:(NSArray*)sections forAdmin:(BOOL)isAdmin{
    NSMutableArray *newSections = [NSMutableArray arrayWithCapacity:[sections count]];
    
    
    for(NSDictionary *item in sections){
        if(![item[@"36education_requires_admin"] boolValue] || isAdmin){
            [newSections addObject:[self sectionInfoFromPlist:item]];
        }
        
    }

    return newSections;
    
    
}



-(NSDictionary*)sectionInfoFromPlist:(NSDictionary*)dict{
    NSMutableDictionary *mutableCopy = [dict mutableCopy];
    
    NSMutableArray *mutableViewControllerList = [NSMutableArray arrayWithCapacity:[dict[kMTSlideViewControllerSectionViewControllersKey] count]];
    
    for(NSDictionary *oldVC in dict[kMTSlideViewControllerSectionViewControllersKey]){
        [mutableViewControllerList addObject:[self viewControllerInfoFromPlist:oldVC]];
    }
    
    
    mutableCopy[kMTSlideViewControllerSectionViewControllersKey] = mutableViewControllerList;
    
    return mutableCopy;
    
    
}








-(NSDictionary*)viewControllerInfoFromPlist:(NSDictionary*)dict{
    
    NSMutableDictionary *mutableDictionary = [dict mutableCopy];
    
    Class vcClass = NSClassFromString(mutableDictionary[kMTSlideViewControllerViewControllerKey]);
    mutableDictionary[kMTSlideViewControllerViewControllerKey] = [[vcClass alloc] init];
    
    mutableDictionary[kMTSlideViewControllerViewControllerIconKey] = [UIImage imageNamed:mutableDictionary[kMTSlideViewControllerViewControllerIconKey]];
    mutableDictionary[kMTSlideViewControllerViewControllerSelectedIconKey] = [UIImage imageNamed:dict[kMTSlideViewControllerViewControllerIconKey] withColor:[UIColor whiteColor]];
    
    
    return mutableDictionary;
}

@end
