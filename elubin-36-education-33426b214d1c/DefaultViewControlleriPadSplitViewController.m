//
//  DefaultViewControlleriPadSplitViewController.m
//  MC HW
//
//  Created by Eric Lubin on 11/7/12.
//
//

#import "DefaultViewControlleriPadSplitViewController.h"

@interface DefaultViewControlleriPadSplitViewController ()

@end

@implementation DefaultViewControlleriPadSplitViewController

- (id)init
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}
-(BOOL)shouldAutorotate{
    
    return YES;
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    
 
    return YES;
}

-(void)loadView{
    [super loadView];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"applewood"]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"thank-you-note"]];
    imageView.center = CGPointMake(self.view.bounds.size.width/2,self.view.bounds.size.height/5);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:imageView];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
