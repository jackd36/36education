//
//  TagsTableCell.m
//  MC HW
//
//  Created by Eric Lubin on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TagsTableCell.h"
#import "TagCapsuleControl.h"

static const CGFloat kCellPaddingY    = 3;
static const CGFloat kPaddingX        = 8;
static const CGFloat kSpacingY        = 6;
static const CGFloat kPaddingRatio    = 1.75;

@implementation TagsTableCell
@synthesize delegate;
-(id)initWithTags:(NSArray*)tags{
    if(self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _tagCapsules = [[NSMutableArray alloc] init];
        for(NSString *tag in tags){
            [self addCapsuleWithString:tag];
        }
        
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    return self;
}
-(BOOL)hasTags{
    return [_tagCapsules count] > 0;
}

+(CGFloat)heightForTags:(NSArray*)array forCellWidth:(CGFloat)width{
    width-=53;
    if([array count] == 0)
        return 45;
    
    CGFloat fontHeight = [TagCapsuleControl capsuleFont].ttLineHeight;
    CGFloat lineIncrement = fontHeight + kCellPaddingY*2 + kSpacingY;
    CGFloat marginY = floor(fontHeight/kPaddingRatio);
    CGFloat marginLeft =  kPaddingX;
    CGFloat marginRight = kPaddingX;
    
    CGPoint origin = CGPointMake(marginLeft, marginY);
    
    for(NSString *tag in array){
        CGSize cellSize = [TagCapsuleControl dimensionsForTitle:tag constrainedToWidth:width-marginLeft-marginRight];
        
                           
        CGFloat lineWidth = origin.x + cellSize.width + marginRight;
        if (lineWidth >= width) {
            origin.x = marginLeft;
            origin.y += lineIncrement;
            
        }
        
        origin.x += cellSize.width + kPaddingX;
        
        
    }
    return origin.y+fontHeight+marginY;
}

- (void)dealloc
{
    [_tagCapsules release];
    [super dealloc];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}
    // Configure the view for the selected state
//}
-(void)addCapsuleWithString:(NSString*)description{
    TagCapsuleControl *control = [[TagCapsuleControl alloc] initWithTitle:description];
    [control addTarget:self action:@selector(capsuleTouched:) forControlEvents:UIControlEventTouchUpInside];
    [_tagCapsules addObject:control];
    [self.contentView addSubview:control];
    [control release];
    //[control release];
}

-(void)capsuleTouched:(TagCapsuleControl*)control{
    NSInteger index = [_tagCapsules indexOfObject:control];
    if([delegate respondsToSelector:@selector(cell:tagSelectedAtIndex:title:)]){
        [delegate cell:self tagSelectedAtIndex:index title:control.description];
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if(![self hasTags]){
        self.textLabel.text = @"No tags";//@"Add tags…";
        return;
    }
    self.textLabel.text = nil;
    CGFloat fontHeight = [TagCapsuleControl capsuleFont].ttLineHeight;
    CGFloat lineIncrement = fontHeight + kCellPaddingY*2 + kSpacingY;
    CGFloat marginY = floor(fontHeight/kPaddingRatio);
    CGFloat marginLeft =  kPaddingX;
    CGFloat marginRight = kPaddingX;
    
    CGPoint origin = CGPointMake(marginLeft, marginY);
    //NSInteger lineCount = 1;
    
    
    
    for (TagCapsuleControl* cell in _tagCapsules) {
        //[cell sizeToFit];
        
        CGFloat lineWidth = origin.x + cell.width + marginRight;
        if (lineWidth >= self.contentView.width) {
            origin.x = marginLeft;
            origin.y += lineIncrement;
            //lineCount++;
            CGFloat overflow = cell.width+marginRight-self.contentView.width;
            if(overflow >0){
                cell.width-=overflow;
            }
        }
        cell.origin = CGPointMake(origin.x,origin.y-kCellPaddingY);
        //cell.frame = CGRectMake(origin.x, origin.y-kCellPaddingY,
                                //cell.width, cell.height);
        origin.x += cell.frame.size.width + kPaddingX;
    }

    
    //return origin.y + fontHeight + marginY;
}
@end
