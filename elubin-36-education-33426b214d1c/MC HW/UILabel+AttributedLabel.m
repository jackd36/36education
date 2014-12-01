//
//  UILabel+AttributedLabel.m
//  MC HW
//
//  Created by Eric Lubin on 1/22/13.
//
//

#import "UILabel+AttributedLabel.h"

@implementation UILabel (AttributedLabel)
-(void)setAttributedTextColor:(UIColor*)color{
    if(color == nil)
        return;
    NSMutableAttributedString *string = [self.attributedText mutableCopy];
    //NSMutableDictionary *student = [self studentFromTableView:tableView indexPath:indexPath];
    
    [string addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0,[self.text length])];
    self.attributedText = string;
}
@end
