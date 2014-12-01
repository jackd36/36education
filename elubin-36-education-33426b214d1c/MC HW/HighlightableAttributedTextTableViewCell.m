//
//  HighlightableAttributedTextTableViewCell.m
//  MC HW
//
//  Created by Eric Lubin on 12/1/12.
//
//

#import "HighlightableAttributedTextTableViewCell.h"
#import "UILabel+AttributedLabel.h"
@implementation HighlightableAttributedTextTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}





- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
//    if(!selected){
//        
//    }
    
    
    
    if(selected){
        self.textLabelColor = self.textLabel.highlightedTextColor;
    }
    else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
            self.textLabelColor = _unhighlightedTextColor;
        });
        
    }
    // Configure the view for the selected state
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
//    if(highlighted){
//        
//    }
    if(highlighted){
        self.textLabelColor = self.textLabel.highlightedTextColor;
    }
    else{
        self.textLabelColor = _unhighlightedTextColor;
    }
    
}


-(void)setTextLabelColor:(UIColor*)color{
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")){
        self.textLabel.attributedTextColor = color;
    }

}

-(void)setUnhighlightedTextColor:(UIColor *)unhighlightedTextColor{
    if(unhighlightedTextColor != _unhighlightedTextColor) {
        _unhighlightedTextColor = unhighlightedTextColor;
        self.textLabelColor = unhighlightedTextColor;
        //self.textLabel.attributedTextColor = unhighlightedTextColor;
    }
    
}


@end
