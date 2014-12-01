//
//  SVModalWebViewController.m
//
//  Created by Oliver Letterer on 13.08.11.
//  Copyright 2011 Home. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import "SVModalWebViewController.h"
#import "SVWebViewController.h"

@interface SVModalWebViewController ()

@property (nonatomic, strong) SVWebViewController *webViewController;

@end


@implementation SVModalWebViewController

@synthesize barsTintColor, availableActions, webViewController;

#pragma mark - Initialization


- (id)initWithAddress:(NSString*)urlString {
    return [self initWithURL:[NSURL URLWithString:urlString]];
}

- (id)initWithData:(NSData*)data textEncodingName:(NSString*)enc{
    SVWebViewController *controller = [[SVWebViewController alloc] initWithData:data textEncodingName:enc];
    if (self = [self initWithWebController:controller]) {
        
    }
    return self;

}

-(id)initWithWebController:(SVWebViewController*)controller{
    self.webViewController = controller;
    if (self = [self initWithRootViewController:controller]) {
        self.webViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:webViewController action:@selector(doneButtonClicked:)];
    }
    return self;
}

- (id)initWithURL:(NSURL *)URL {
    SVWebViewController *controller = [[SVWebViewController alloc] initWithURL:URL];
    if (self = [self initWithWebController:controller]) {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
    
    self.navigationBar.tintColor = self.barsTintColor;
}

- (void)setAvailableActions:(SVWebViewControllerAvailableActions)newAvailableActions {
    self.webViewController.availableActions = newAvailableActions;
}

@end
