//
//  UITextFieldCell.m
//  MC HW
//
//  Created by Eric Lubin on 11/18/12.
//
//

#import "UITextFieldCell.h"

@implementation UITextFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 40, 22)];
        
        tf.keyboardType = UIKeyboardTypeNumberPad;
        tf.placeholder = @"-";
        tf.enablesReturnKeyAutomatically = YES;
        tf.textAlignment = NSTextAlignmentRight;
        
        tf.font = [UIFont boldSystemFontOfSize:20.0f];
        self.accessoryView =tf;
        //[self.contentView addSubview:tf];
        self.textField  = tf;
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
    //self.textField.frame = CGRectMake(self.contentView.bounds.size.width-self.textField.frame.size.width-15,0,self.textField.frame.size.height,self.textField.frame.size.width);
    //self.textField.center = CGPointMake(self.textField.center.x,self.contentView.bounds.size.height/2);
}

@end
