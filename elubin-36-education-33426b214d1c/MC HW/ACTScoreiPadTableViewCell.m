//
//  ACTScoreiPadTableViewCell.m
//  MC HW
//
//  Created by Eric Lubin on 11/10/12.
//
//

#import "ACTScoreiPadTableViewCell.h"
#import "CustomBadge.h"
#import "ACTResult.h"
@interface ACTScoreiPadTableViewCell()
@property (nonatomic,strong) NSArray *sectionNames;//an array of section names to choose from when iterating over the scores
@property (nonatomic,strong) NSMutableArray *sectionLabels;
@property (nonatomic,strong) NSMutableArray *scoreBubbles;
@property (nonatomic,strong) CustomBadge *mainBadge;
@property (nonatomic,strong) UILabel *dateTaken;
@property (nonatomic,strong) UILabel *timestampLabel;
@end

@implementation ACTScoreiPadTableViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier sectionNames:(NSArray*)sections
{
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.sectionLabels = [NSMutableArray arrayWithCapacity:5];
        self.sectionNames = sections;
        self.scoreBubbles = [NSMutableArray arrayWithCapacity:5];
        
        // Initialization code
    }
    return self;
}
+ (NSInteger)heightForInfo:(ACTResult*)info{
    NSArray *scores = info.sectionScores;
    
    int count = 0;
    
    for(int i=0;i<[scores count];i++){
        if(scores[i] != [NSNull null])
            count++;
    }
    
    
    NSInteger numberOfLines = count;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        numberOfLines = ceil(count/2.0);
    
    return MAX(numberOfLines,2)*heightPerLabel+2*topAndBottomMargins;
}

-(void)setSectionScoreInfo:(ACTResult*)info{
    
    
    NSArray *scores = info.sectionScores;
    //NSArray *scores = [info[@"sections"] valueForKey:@"score"];
    int valid_scores = 0;
    for(int i=0;i<[scores count];i++){
        if(scores[i] != [NSNull null]){
            UILabel *label = nil;
            CustomBadge *badge = nil;
            if([_sectionLabels count] > i){
                label = _sectionLabels[valid_scores];
                badge = _scoreBubbles[valid_scores];
            }
            else{
                label = [[UILabel alloc] initWithFrame:CGRectZero];
                label.highlightedTextColor = [UIColor whiteColor];
                label.font = [UIFont boldSystemFontOfSize:20];
                [self.contentView addSubview:label];
                [_sectionLabels addObject:label];
                
                badge = [CustomBadge customBadgeWithString:nil
                                   withStringColor:[UIColor whiteColor]
                                    withInsetColor:[UIColor blueColor]
                                    withBadgeFrame:NO
                               withBadgeFrameColor:[UIColor whiteColor]
                                         withScale:1.0
                                       withShining:NO];
                [self.contentView addSubview:badge];
                [_scoreBubbles addObject:badge];
            }
            label.text = _sectionNames[valid_scores];
            //badge.badgeText =
            NSString *score = [NSString stringWithFormat:@"%@",scores[i]];
            if([score length] == 1){
                score = [@" " stringByAppendingString:score];
            }
            [badge autoBadgeSizeWithString:score];
            valid_scores++;
        }
    }
    
    //remove any extra objects
    NSInteger oldLength = [_sectionLabels count];
    for(int x=valid_scores;x<oldLength;x++){
        
        UILabel *label =_sectionLabels[x];
        [label removeFromSuperview];
        //[_sectionLabels removeObjectAtIndex:x];
        
        CustomBadge *badge = _scoreBubbles[x];
        [badge removeFromSuperview];
        //[_scoreBubbles removeObjectAtIndex:x];
    }
    NSInteger lengthOfRange = [_sectionLabels count]-valid_scores;
    if(lengthOfRange > 0){
        NSRange rangeToRemove = NSMakeRange(valid_scores, lengthOfRange);
        [_sectionLabels removeObjectsInRange:rangeToRemove];
        [_scoreBubbles removeObjectsInRange:rangeToRemove];
    }
    self.timestampLabel.text =info.dateString;
    [self.mainBadge autoBadgeSizeWithString:[NSString stringWithFormat:@"%@",info.compositeScore]];
}

NSInteger const heightPerLabel = 30;
NSInteger const topAndBottomMargins = 5;
-(void)layoutSubviews{
    [super layoutSubviews];
    
    [self.timestampLabel sizeToFit];
    self.timestampLabel.frame = CGRectMake(self.contentView.bounds.size.width-topAndBottomMargins-self.timestampLabel.bounds.size.width,topAndBottomMargins,self.timestampLabel.bounds.size.width,self.timestampLabel.bounds.size.height);
    
    NSInteger leftMargin = 10;
    NSInteger widthOfMainBadge = self.mainBadge.bounds.size.width;
    if([self isEditing]){
        widthOfMainBadge = 0;

    }
    NSInteger width = (self.contentView.bounds.size.width-2*leftMargin-widthOfMainBadge)/2;
    NSInteger height = heightPerLabel;
    NSInteger smallMargin = 5;
    
    for(int x=0;x<[_sectionLabels count];x++){
        UILabel *sectionLabel = _sectionLabels[x];
        CustomBadge *badgeView = _scoreBubbles[x];
        NSInteger widthOfSmallerBadge = badgeView.frame.size.width;
        NSInteger timeStampOrigin = self.timestampLabel.frame.origin.x;
        if([self isEditing]){
            timeStampOrigin = self.contentView.bounds.size.width;
        }
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){

            sectionLabel.frame = CGRectMake(leftMargin+smallMargin+widthOfSmallerBadge+width*(x%2),topAndBottomMargins+height*floor(x/2.0),MIN(width-widthOfSmallerBadge-smallMargin-leftMargin,(timeStampOrigin-leftMargin-widthOfSmallerBadge)/2),height);
            
        }
        else{
            sectionLabel.frame = CGRectMake(leftMargin+smallMargin+widthOfSmallerBadge,topAndBottomMargins+height*x,MIN(self.contentView.bounds.size.width-leftMargin-smallMargin-widthOfSmallerBadge-widthOfMainBadge,(timeStampOrigin-leftMargin-widthOfSmallerBadge)/2),height);
            
        }
        sectionLabel.center = CGPointMake(sectionLabel.center.x,sectionLabel.frame.origin.y+height/2);
        badgeView.frame = CGRectMake(sectionLabel.frame.origin.x-smallMargin-widthOfSmallerBadge,0,widthOfSmallerBadge,badgeView.frame.size.height);
        badgeView.center = CGPointMake(badgeView.center.x,sectionLabel.center.y);
        
    }
    

    
    self.mainBadge.frame = CGRectMake(self.contentView.bounds.size.width-topAndBottomMargins-self.mainBadge.bounds.size.width,self.contentView.bounds.size.height-self.mainBadge.bounds.size.height-topAndBottomMargins,self.mainBadge.bounds.size.width,self.mainBadge.bounds.size.height);
    

}

-(CustomBadge*)mainBadge{
    if (!_mainBadge) {
        _mainBadge = [CustomBadge customBadgeWithString:nil withStringColor:[UIColor whiteColor] withInsetColor:[UIColor greenColor] withBadgeFrame:YES withBadgeFrameColor:[UIColor yellowColor] withScale:1.6 withShining:YES];

        [self.contentView addSubview:_mainBadge];
    }
    return _mainBadge;
}

- (UILabel*)timestampLabel {
    if (!_timestampLabel) {
        _timestampLabel = [[UILabel alloc] init];
        _timestampLabel.font = [UIFont systemFontOfSize:13];
        _timestampLabel.textColor = RGBCOLOR(36, 112, 216);
        _timestampLabel.highlightedTextColor = [UIColor whiteColor];
        _timestampLabel.contentMode = UIViewContentModeLeft;
        [self.contentView addSubview:_timestampLabel];
    }
    return _timestampLabel;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    for(UILabel *label in self.sectionLabels){
        [label setHighlighted:selected];
//        if(selected) {
//            label.textColor = [UIColor whiteColor];
//        }
//        else
//            label.textColor = [UIColor blackColor];
    }
    // Configure the view for the selected state
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    for(UILabel *label in self.sectionLabels){
        [label setHighlighted:highlighted];
    }
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    
    self.timestampLabel.hidden = editing;
    self.mainBadge.hidden = editing;
}

@end
