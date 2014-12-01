//
//  UnuploadedTestTableViewCell.m
//  MC HW
//
//  Created by Eric Lubin on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UnuploadedTestTableViewCell.h"
@interface UnuploadedTestTableViewCell()
@property (nonatomic,strong) UIActivityIndicatorView *activityView;
@end
@implementation UnuploadedTestTableViewCell
@synthesize state,activityView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:activityView];
        self.imageView.image = [UIImage imageNamed:@"attending"];
        self.imageView.hidden = YES;
        // Initialization code
    }
    return self;
}
-(void)setState:(ELUploadingState)st{
    state = st;
    if(state != ELUploadingStateLoading){
        [activityView stopAnimating];
        self.imageView.hidden = NO;
        if(state == ELUploadingStateComplete){
            self.imageView.image = [UIImage imageNamed:@"attending"];
        }
        else if(state == ELUploadingStateFailed){
            self.imageView.image = [UIImage imageNamed:@"notAttending"];
        }
        else if(state == ELUploadingStateAlertFailed){
            self.imageView.image = [UIImage imageNamed:@"failure-btn"];

        }
        else{
            self.imageView.hidden = YES;
        }
    }
    else {
        self.imageView.hidden = YES;
        [activityView startAnimating];
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    activityView.center = self.imageView.center;
    
    
}

@end
