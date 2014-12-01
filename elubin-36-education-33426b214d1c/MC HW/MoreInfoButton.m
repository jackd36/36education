//
//  MoreInfoButton.m
//  MC HW
//
//  Created by Eric Lubin on 7/19/12.
//
//

#import "MoreInfoButton.h"

@implementation MoreInfoButton
-(id)init{
    self = [super init];
    if(self){
  
        [self setBackgroundImageNamed:@"PurchaseButtonGreen" forState:UIControlStateNormal];
        [self setBackgroundImageNamed:@"PurchaseButtonGreenPressed" forState:UIControlStateHighlighted];
        //[self setHighlightedBackgroundImageGreen:NO];
        
        
        self.titleEdgeInsets = UIEdgeInsetsMake(2, 4, 2, 4);
        self.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _maxWidth = 75.0f;
    }
    
    return self;
}
-(UIEdgeInsets)backgroundInsets{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}
-(void)setBackgroundImageNamed:(NSString*)fileName forState:(UIControlState)state{
    [self setBackgroundImage:[[UIImage imageNamed:fileName] resizableImageWithCapInsets:self.backgroundInsets] forState:state];
}




-(void)setTitle:(NSString *)title{
    [self setTitle:title forState:UIControlStateNormal];
}
-(NSString*)title{
    return [self titleForState:UIControlStateNormal];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    CGSize textSize = [self.title sizeWithFont:self.titleLabel.font forWidth:MAXFLOAT lineBreakMode:NSLineBreakByWordWrapping];
    textSize.width = MIN(textSize.width,_maxWidth);
    CGPoint oldCenter = self.center;
    self.frame = CGRectMake(0,0,textSize.width+self.titleEdgeInsets.left+self.titleEdgeInsets.right,textSize.height+self.titleEdgeInsets.top+self.titleEdgeInsets.bottom);
    self.center = oldCenter;
    
}

@end
