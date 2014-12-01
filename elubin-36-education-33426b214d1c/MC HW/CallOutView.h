//
//  CallOutView.h
//  CallOutView
//
//  Created by Hendrik Holtmann on 18.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CallOutView : UIView {

	UIImageView *calloutLeft;
	UIImageView *calloutCenter;
	UIImageView *calloutRight;
	UIButton *calloutButton;
	UILabel *calloutLabel;
	NSString *text;
	CGAffineTransform transform;
}

+ (CallOutView*) addCalloutView:(UIView*)parent text:(NSString*)text point:(CGPoint)pt target:(id)target action:(SEL)selector;

@property (nonatomic, copy) NSString *text;
@property (nonatomic,retain) id userInfo;
@end
