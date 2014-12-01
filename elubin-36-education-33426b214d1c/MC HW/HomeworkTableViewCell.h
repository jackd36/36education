//
//  HomeworkTableViewCell.h
//  MC HW
//
//  Created by Eric Lubin on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MoreInfoButton;
@interface HomeworkTableViewCell : UITableViewCell{
    UILabel*      _titleLabel;
    UILabel*      _timestampLabel;
    UIImageView* _imageView2;
    
}
@property (nonatomic, readonly, retain) UILabel*      titleLabel;
@property (nonatomic, readonly)         UILabel*      captionLabel;
@property (nonatomic, readonly, retain) UILabel*      timestampLabel;
@property (nonatomic,readonly,retain) UIImageView *imageView;

//@property (nonatomic,strong) MoreInfoButton *customText;

-(void)setAssignment:(NSDictionary*)assignment;
@end
