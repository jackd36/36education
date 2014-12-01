//
//  AttemptTableViewCell.m
//  MC HW
//
//  Created by Eric Lubin on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AttemptTableViewCell.h"

#import "NSDate+prettifiedRelativeDateString.h"
@interface AttemptTableViewCell ()
@property (nonatomic,strong) UIImageView *flaggedImage;
@property (nonatomic) BOOL flagVisible;
@end

@implementation AttemptTableViewCell
@synthesize pctCorrect,sectionIsFactoredOut,enforceTimeLimit;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        pctCorrect = MAXFLOAT;
        // Initialization code
        enforceTimeLimit = YES;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _flaggedImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flag"]];
        [self.contentView addSubview:_flaggedImage];
    }
    return self;
}




-(void)prepareForReuse{
    [super prepareForReuse];
    _timestampLabel.text = nil;
    
}
-(void)setAttempt:(NSDictionary*)attempt{
    _flagVisible = [attempt[@"is_subset"] boolValue];
    
    self.timestampLabel.text = [[NSDate dateWithTimeIntervalSince1970:[[attempt valueForKey:@"date_completed"] integerValue]] relativeDateStringTime:YES];
    if(pctCorrect != MAXFLOAT)
        self.badgeColor = [UIColor colorWithHue:0.3333*pctCorrect saturation:1.0 brightness:0.80 alpha:1.0];
    
}

- (UILabel*)timestampLabel {
    if (!_timestampLabel) {
        _timestampLabel = [[UILabel alloc] init];
        _timestampLabel.backgroundColor = [UIColor clearColor];
        _timestampLabel.font = [UIFont systemFontOfSize:13];
        _timestampLabel.textColor = RGBCOLOR(36, 112, 216);
        _timestampLabel.highlightedTextColor = [UIColor whiteColor];
        _timestampLabel.contentMode = UIViewContentModeLeft;
        [self.contentView addSubview:_timestampLabel];
    }
    return _timestampLabel;
}
- (void)dealloc
{
    [_timestampLabel release];
    [_flaggedImage release];
    [super dealloc];
}

-(void)layoutSubviews{
    [super layoutSubviews];

    
    [self.flaggedImage sizeToFit];
    self.flaggedImage.frame = CGRectMake(self.textLabel.right+5,0,self.flaggedImage.frame.size.width,self.flaggedImage.frame.size.height);
    self.flaggedImage.center = CGPointMake(self.flaggedImage.center.x,self.textLabel.center.y);
    self.flaggedImage.hidden = !_flagVisible;
    
    if((id)_timestampLabel.text == [NSNull null])
        _timestampLabel.text = nil;
    if (_timestampLabel.text.length) {
        _timestampLabel.alpha = !self.showingDeleteConfirmation;
        [_timestampLabel sizeToFit];
        _timestampLabel.left = self.contentView.width - (_timestampLabel.width + 6);
        _timestampLabel.top = 4;
        //self.textLabel.width -= _timestampLabel.width + kTableCellSmallMargin*2;
        
    } else {
        _timestampLabel.frame = CGRectZero;
    }
    self.badge.center = CGPointMake(self.badge.center.x,(self.contentView.bounds.size.height - _timestampLabel.bottom)/2+_timestampLabel.bottom);
    self.badge2.top = self.badge.top;
    //self.badge.bottom =self.contentView.bounds.size.height-4;
}
@end
