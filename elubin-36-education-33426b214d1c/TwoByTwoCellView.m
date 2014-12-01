//
//  TwoByTwoCellView.m
//  TwoByTwoViewCell
//
//  Created by Gavin Miller on 10-12-02.
//  Copyright 2010 RANDOMTYPE. All rights reserved.
//

#import "TwoByTwoCellView.h"

// Private method declaration
@interface TwoByTwoCellView()

- (UILabel *)valueLabelWithFrame:(CGRect)frame;
- (UILabel *)titleLabelWithFrame:(CGRect)frame text:(NSString *)text;

@end


@implementation TwoByTwoCellView

@synthesize topLeftValue, topRightValue, bottomLeftValue, bottomRightValue;
@synthesize topLeftTitle, topRightTitle, bottomLeftTitle, bottomRightTitle;
@synthesize numRows;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        numRows = 2;
        horizontalLine = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        horizontalLine.backgroundColor = [UIColor lightGrayColor];
        horizontalLine.autoresizingMask = 0x3f;
        [self.contentView addSubview:horizontalLine];
        
        verticalLine = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        verticalLine.backgroundColor = [UIColor lightGrayColor];
        verticalLine.autoresizingMask = 0x3f;
        [self.contentView addSubview:verticalLine];
        
        //CGFloat totalHeight = 140.0f;
		//UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, totalHeight)];
		
//        UIButton *topLeftButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        topLeftButton.backgroundColor = [UIColor clearColor];
//        topLeftButton.frame = CGRectMake(0, -10, 150, totalHeight/2.0);
//        [containerView addSubview:topLeftButton];
		// Top Left
		self.topLeftTitle = [self titleLabelWithFrame:CGRectZero text:nil];
		self.topLeftValue = [self valueLabelWithFrame:CGRectZero];
		[self.contentView addSubview:topLeftTitle];
		[self.contentView addSubview:topLeftValue];
        
		
		// Top Right
		self.topRightTitle = [self titleLabelWithFrame:CGRectZero text:nil];
		self.topRightValue = [self valueLabelWithFrame:CGRectZero];
		[self.contentView addSubview:topRightTitle];
		[self.contentView addSubview:topRightValue];
		
		
		// Bottom Left
		self.bottomLeftTitle = [self titleLabelWithFrame:CGRectZero text:nil];
		self.bottomLeftValue = [self valueLabelWithFrame:CGRectZero];
		[self.contentView addSubview:bottomLeftTitle];
		[self.contentView addSubview:bottomLeftValue];
		
		
		// Bottom Right
		self.bottomRightTitle = [self titleLabelWithFrame:CGRectZero text:@"title3"];
		self.bottomRightValue = [self valueLabelWithFrame:CGRectZero];
		[self.contentView addSubview:bottomRightTitle];
		[self.contentView addSubview:bottomRightValue];

		
		
		
//		self.backgroundColor = [UIColor clearColor];
////		
//		// Create the 2x2 pattern
//		UIImageView *imageView = [[[UIImageView alloc] init] autorelease];
//		imageView.image = [UIImage imageNamed:@"2x2-background.png"];
//		imageView.layer.cornerRadius = 15.0;
//		imageView.layer.masksToBounds = YES;
////        NSLog(@"%@",[UIColor lightGrayColor]);
//		imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//		imageView.layer.borderWidth = 1.5;
//		imageView.backgroundColor = [UIColor whiteColor];
//		self.backgroundView = imageView;
		
		self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (UILabel *)valueLabelWithFrame:(CGRect)frame {
	UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
	label.textColor = [UIColor darkTextColor];
	label.textAlignment = UITextAlignmentCenter;
	label.font = [UIFont boldSystemFontOfSize:32];
	label.backgroundColor = [UIColor clearColor];
    label.adjustsFontSizeToFitWidth = YES;

	return label;
}

- (UILabel *)titleLabelWithFrame:(CGRect)frame text:(NSString *)text {
	UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
	label.text = text;
	label.textColor = [UIColor colorWithRed:51.0f/255.0f green:102.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
	label.textAlignment = UITextAlignmentCenter;
	label.font = [UIFont boldSystemFontOfSize:12];	
	label.backgroundColor = [UIColor clearColor];
	
	return label;
}
//-(void)drawRect:(CGRect)rect{
//    [super drawRect:rect];
//    
//    //NSLog(@"%@",NSStringFromCGRect(rect));
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    UIColor *backgroundColor = [UIColor whiteColor];
//    [backgroundColor set];
//    CGContextFillRect(ctx, rect);
//    CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
//    CGContextSetLineWidth(ctx, 0.5);
//    
//    CGContextMoveToPoint(ctx, rect.size.width/2, 0);
//    CGContextAddLineToPoint(ctx, rect.size.width/2, rect.size.height);
//    
//    CGContextMoveToPoint(ctx, 0, self.bounds.size.height/2);
//    CGContextAddLineToPoint(ctx, self.bounds.size.width, self.bounds.size.height/2);
//    
//    CGContextStrokePath(ctx);
//    
//}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat totalHeight = self.contentView.bounds.size.height+1;
    CGFloat width = self.contentView.bounds.size.width;
    CGFloat columns = 2.0;
    if(bottomRightTitle.text != nil || bottomLeftTitle.text == nil){
        //two on top, no regard to bottom
        self.topLeftTitle.frame = CGRectMake(0, totalHeight*5.0/(9.0*numRows)+7, width/columns, totalHeight/(4.5*numRows)) ;
        self.topLeftValue.frame = CGRectMake(0, 7, width/columns, totalHeight*5.0/(9.0*numRows));
        
        self.topRightTitle.frame = CGRectMake(width/columns, 7+totalHeight*5.0/(9.0*numRows), width/columns, totalHeight/(4.5*numRows));
        self.topRightValue.frame = CGRectMake(width/columns, 7,width/columns, totalHeight*5.0/(9.0*numRows));
        verticalLine.frame = CGRectMake(width/2,0, 1, totalHeight/numRows);
    }
    else if(topRightTitle.text == nil){
        //one on top, no regard to bottom
        verticalLine.frame = CGRectMake(width/2, totalHeight/numRows, 1, 0);
        self.topLeftTitle.frame = CGRectMake(0, totalHeight*5.0/(9.0*numRows)+7, width, totalHeight/(4.5*numRows)) ;
        self.topLeftValue.frame = CGRectMake(0, 7, width, totalHeight*5.0/(9.0*numRows));
    }
    
    if(bottomLeftTitle.text != nil && bottomRightTitle.text != nil && numRows == 2){
        self.bottomLeftTitle.frame = CGRectMake(0, 7+totalHeight*7.0/9.0, width/columns, totalHeight/(9.0));
        self.bottomLeftValue.frame = CGRectMake(0, 7+totalHeight/2.0,width/columns, totalHeight*5.0/(18.0));
        
        
        self.bottomRightTitle.frame = CGRectMake(width/columns, 7+totalHeight*7.0/9.0, width/columns, totalHeight/(9.0));
        self.bottomRightValue.frame = CGRectMake(width/columns, 7+totalHeight/2.0, width/columns, totalHeight*5.0/(18.0));
        CGRect v_frame = verticalLine.frame;
        v_frame.size.height += totalHeight/2;
        verticalLine.frame = v_frame;
        horizontalLine.frame = CGRectMake(0, totalHeight/2, width, 1);
    }
    else{
        horizontalLine.frame = CGRectZero;
    }
}
- (void)dealloc {
  
	[topLeftTitle release];
	[topLeftValue release];
	
	[topRightTitle release];
	[topRightValue release];
	
	[bottomLeftTitle release];
	[bottomLeftValue release];
	
	[bottomRightTitle release];
	[bottomRightValue release];
	
	[super dealloc];
}


@end
