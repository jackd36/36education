//
//  ELMoreTableViewCell.h
//  MC HW
//
//  Created by Eric Lubin on 9/18/12.
//
//

#import <UIKit/UIKit.h>

@interface ELMoreTableViewCell : UITableViewCell
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
@property (nonatomic, strong) UIActivityIndicatorView*  activityIndicatorView;
@property (nonatomic)                   BOOL                      animating;
@end
