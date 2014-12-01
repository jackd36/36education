//
//  ELMoreTableViewCell.m
//  MC HW
//
//  Created by Eric Lubin on 9/18/12.
//
//

#import "ELMoreTableViewCell.h"
static const CGFloat kMoreButtonMargin = 40;
const CGFloat   kTableCellSmallMargin2 = 6;
@implementation ELMoreTableViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.textColor = RGBCOLOR(0, 109, 224);
        self.textLabel.font = [UIFont boldSystemFontOfSize:15];
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)layoutSubviews{
    [super layoutSubviews];
    _activityIndicatorView.left = kMoreButtonMargin - (_activityIndicatorView.width
                                                       + kTableCellSmallMargin2);
    _activityIndicatorView.top = floor(self.contentView.height/2 - _activityIndicatorView.height/2);
    
    self.textLabel.frame = CGRectMake(kMoreButtonMargin, self.textLabel.top,
                                      self.contentView.width - (kMoreButtonMargin
                                                                + kTableCellSmallMargin2),
                                      self.textLabel.height);
    self.detailTextLabel.frame = CGRectMake(kMoreButtonMargin, self.detailTextLabel.top,
                                            self.contentView.width - (kMoreButtonMargin
                                                                      + kTableCellSmallMargin2),
                                            self.detailTextLabel.height);
}

- (UIActivityIndicatorView*)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                                  UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:_activityIndicatorView];
    }
    
    return _activityIndicatorView;
}
- (void)setAnimating:(BOOL)animating {
    if (_animating != animating) {
        _animating = animating;
        
        if (_animating) {
            [self.activityIndicatorView startAnimating];
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            
        } else {
            [_activityIndicatorView stopAnimating];
            self.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
        
        [self setNeedsLayout];
    }
    
}


@end
