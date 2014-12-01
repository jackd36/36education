//
//  HomeworkTableViewCell.m
//  MC HW
//
//  Created by Eric Lubin on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HomeworkTableViewCell.h"
#import "NSDate+prettifiedRelativeDateString.h"
#import "MoreInfoButton.h"
static const NSInteger  kMessageTextLineCount       = 2;
@implementation HomeworkTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:reuseIdentifier];
    if (self) {
        //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        self.textLabel.font = [UIFont systemFontOfSize:14];
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.highlightedTextColor = [UIColor whiteColor];
        self.textLabel.adjustsFontSizeToFitWidth = NO;
        self.textLabel.textColor = [UIColor lightGrayColor];
        self.textLabel.backgroundColor = [UIColor whiteColor];
        self.textLabel.textAlignment = UITextAlignmentLeft;
        self.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.contentMode = UIViewContentModeLeft;
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:14];
        self.detailTextLabel.textColor = RGBCOLOR(79, 89, 105);
        self.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
        self.detailTextLabel.backgroundColor =[UIColor whiteColor];
        self.detailTextLabel.textAlignment = UITextAlignmentLeft;
        self.detailTextLabel.contentMode = UIViewContentModeTop;
        self.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
        self.detailTextLabel.numberOfLines = kMessageTextLineCount;
        self.detailTextLabel.contentMode = UIViewContentModeLeft;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    //[_customText setHighlightedBackgroundImageGreen:NO];
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)didMoveToSuperview{
    [super didMoveToSuperview];
    
    if (self.superview) {
        _titleLabel.backgroundColor = self.backgroundColor;
        _timestampLabel.backgroundColor = self.backgroundColor;
        _imageView2.backgroundColor = self.backgroundColor;
        
        
    }
}
- (void)prepareForReuse {
    [super prepareForReuse];
    _titleLabel.text = nil;
    _timestampLabel.text = nil;
    self.captionLabel.text = nil;
    _imageView2.image = nil;
    _imageView2.highlightedImage = nil;
    //_customText.title = nil;
    
}
- (void)dealloc {
    [_titleLabel release];
    [_timestampLabel release];
    [_imageView2 release];
    //[_customText release];
    [super dealloc];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat left = 0;
    const CGFloat   kTableCellSmallMargin = 6;
    const CGFloat   kTableCellMargin      = 10;
    
    CGFloat top = kTableCellSmallMargin;
    
    
    if (_imageView2) {
        [_imageView2 sizeToFit];
        _imageView2.frame = CGRectMake(11, kTableCellSmallMargin,_imageView2.bounds.size.width, _imageView2.bounds.size.height);
        _imageView2.center = CGPointMake(_imageView2.center.x,self.contentView.bounds.size.height/2);
        left += 11 + _imageView2.frame.size.width + 11;
        
    } else {
        left = kTableCellMargin;
    }
    CGFloat width = self.contentView.width - left;
    if (_titleLabel.text.length) {
        _titleLabel.frame = CGRectMake(left, top, width, _titleLabel.font.ascender-_titleLabel.font.descender+1);
        top += _titleLabel.height;
        
    } else {
        _titleLabel.frame = CGRectZero;
    }
    
    if (self.captionLabel.text.length) {
        self.captionLabel.frame = CGRectMake(left, top, width, self.captionLabel.font.ascender-_titleLabel.font.descender+1);
        top += self.captionLabel.height;
        
    } else {
        self.captionLabel.frame = CGRectZero;
    }
    
    if (self.detailTextLabel.text.length) {
        CGFloat textHeight = (self.detailTextLabel.font.ascender-self.detailTextLabel.font.descender+1 )* kMessageTextLineCount;
        self.detailTextLabel.frame = CGRectMake(left, top, width, textHeight);
        
    } else {
        self.detailTextLabel.frame = CGRectZero;
    }
    
    if (_timestampLabel.text.length) {
        _timestampLabel.alpha = !self.showingDeleteConfirmation;
        [_timestampLabel sizeToFit];
        _timestampLabel.left = self.contentView.width - (_timestampLabel.width + kTableCellSmallMargin);
        _timestampLabel.top = _titleLabel.top;
        _titleLabel.width -= _timestampLabel.width + kTableCellSmallMargin*2;
        
    } else {
        _timestampLabel.frame = CGRectZero;
    }
    
//    if(_customText && ENABLE_SUBSET_ASSIGNMENTS){
//        
//        _customText.left = self.contentView.width - (_customText.width + kTableCellSmallMargin);
//        _customText.bottom = self.contentView.height-kTableCellSmallMargin;
//    }
//    else{
//        _customText.frame = CGRectZero;
//    }
    
    
    if(self.captionLabel.text == nil){
        self.titleLabel.center = CGPointMake(self.titleLabel.center.x, ceil(self.contentView.bounds.size.height/2));
    }
    _titleLabel.backgroundColor = [UIColor clearColor];

}

- (UILabel*)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.highlightedTextColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _titleLabel.contentMode = UIViewContentModeLeft;

        _titleLabel.adjustsFontSizeToFitWidth = YES;
        
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UILabel*)captionLabel {
    return self.textLabel;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UILabel*)timestampLabel {
    if (!_timestampLabel) {
        _timestampLabel = [[UILabel alloc] init];
        _timestampLabel.font = [UIFont systemFontOfSize:13];
        _timestampLabel.textColor = RGBCOLOR(36, 112, 216);
        _timestampLabel.highlightedTextColor = [UIColor whiteColor];
        _timestampLabel.contentMode = UIViewContentModeLeft;
        [self.contentView addSubview:_timestampLabel];
    }
    return _timestampLabel;
}

//-(MoreInfoButton*)customText{
//    if(!_customText){
//        _customText = [[MoreInfoButton alloc] init];
//        [self.contentView addSubview:_customText];
//    }
//    return _customText;
//}

- (UIImageView*)imageView{
    if(!_imageView2){
        _imageView2 = [[UIImageView alloc] init];
        [self.contentView addSubview:_imageView2];
    }
    return _imageView2;
}
-(void)setAssignment:(NSDictionary*)assignment{
    if([[assignment valueForKey:@"editable"] boolValue]){
        self.imageView.image = [UIImage imageNamed:@"unread"];
        self.imageView.highlightedImage = [UIImage imageNamed:@"unread_pressed"];
    }
    else{
        self.imageView.image = [UIImage imageNamed:@"unread_partial"];
        self.imageView.highlightedImage = [UIImage imageNamed:@"unread_partial_pressed"];
    }
    
    self.titleLabel.text = [assignment valueForKey:@"textLabel"];
    id detailTextLabel = [assignment valueForKey:@"detailTextLabel"];
    if(detailTextLabel == [NSNull null])
        detailTextLabel = nil;
    self.captionLabel.text = detailTextLabel;
    
//    
    if([[assignment valueForKey:@"is_subset"] boolValue] && ENABLE_SUBSET_ASSIGNMENTS){
        self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    else{
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    //NSString *notes = [assignment valueForKey:@"notes"];
   // if([notes isEqualToString:@""] || notes == nil)
        //notes = nil;
    
    
    //self.captionLabel.text = notes;
    id due = [assignment valueForKey:@"due_date"];
    if(due == nil || [NSNull null] == due)
        self.timestampLabel.text = nil;
    else{
        self.timestampLabel.text = [[NSDate dateWithTimeIntervalSince1970:[due intValue]] relativeDateString];
        if([due intValue] <= [[NSDate today] timeIntervalSince1970])
            self.timestampLabel.textColor = [UIColor redColor];
        else
            self.timestampLabel.textColor = RGBCOLOR(36, 112, 216);
    }
    // Configure the cell...
}

@end
