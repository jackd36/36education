//
//  MoreInfoButton.h
//  MC HW
//
//  Created by Eric Lubin on 7/19/12.
//
//

#import <UIKit/UIKit.h>

@interface MoreInfoButton : UIButton
@property (nonatomic)CGFloat maxWidth;//if the width of the string exceeds this amount, it will be truncated
-(void)setTitle:(NSString *)title;
@end
