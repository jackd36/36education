//
//  TSPassage.m
//  MC HW
//
//  Created by Eric Lubin on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSPassage.h"

@implementation TSPassage
@synthesize title,index,numChoices,offset;

- (void)dealloc {
    [title release];
    [super dealloc];
}

-(NSInteger)lengthOfTest{
    return 0;
}

-(NSDictionary*)dictionaryRepresentation{

    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:index],@"index",[NSNumber numberWithInteger:self.contentType],@"content_type",self.testID,@"testID",self.sectionName,@"sectionName",[self.questions valueForKey:@"dictionaryRepresentation"],@"questions",[NSNumber numberWithFloat:self.unassignedTime],@"unassignedTime",self.testInfo,@"testInfo", nil];
}

-(NSString*)titleForSection:(NSInteger)section{
    if(title == nil || [title isEqualToString:@""])
        return [NSString stringWithFormat:@"Passage %d",index+1];
    else
        return [NSString stringWithFormat:@"%d - %@",index+1,title];
}
-(NSInteger)initialNumbering{
    return offset;
}
-(NSIndexPath*)sectionOfQuestion:(NSInteger)questionIndex{
    return [NSIndexPath indexPathForRow:questionIndex inSection:0];
}
-(NSIndexPath*)indexPathOfQuestion:(NSInteger)questionIndex{
    return [NSIndexPath indexPathForRow:questionIndex inSection:0];
}


-(NSInteger)numberOfRows{
    return [self.questions count];
}
-(NSInteger)questionIndexForIndexPath:(NSIndexPath*)indexPath{
    return indexPath.row;
}

//-(NSInteger)questionNumberForIndex:(NSInteger)i{
//    return [super questionNumberForIndex:i]+offset;
//}
-(NSInteger)numberOfSections{
    return 1;
}
-(NSInteger)numberOfRowsInSection:(NSInteger)section{
    return [self.questions count];
}
@end
