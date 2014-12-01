//
//  UISplitViewController+VCSwapping.m
//  MC HW
//
//  Created by Eric Lubin on 10/22/12.
//
//

#import "UISplitViewController+VCSwapping.h"

@implementation UISplitViewController (VCSwapping)


-(void)setDetailViewController:(UIViewController*)vc{
    if(!self.viewControllers.count)
        return;
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    self.viewControllers = @[self.viewControllers[0],nc];
    
}
@end
