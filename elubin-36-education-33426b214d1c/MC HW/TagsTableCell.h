//
//  TagsTableCell.h
//  MC HW
//
//  Created by Eric Lubin on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TagsTableCell;
@protocol TagsTableCellDelegate <NSObject>
-(void)cell:(TagsTableCell*)tableViewCell tagSelectedAtIndex:(NSInteger)index title:(NSString*)title;
@end


@interface TagsTableCell : UITableViewCell{
    NSMutableArray *_tagCapsules;
}
@property (nonatomic,assign) id <TagsTableCellDelegate> delegate;

-(id)initWithTags:(NSArray*)tags;

+(CGFloat)heightForTags:(NSArray*)array forCellWidth:(CGFloat)width;
@end

