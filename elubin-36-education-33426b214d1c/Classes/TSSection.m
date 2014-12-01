//
//  TSSection.m
//  MC HW
//
//  Created by Eric Lubin on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSSection.h"
#import "TSPassage.h"
NSString * const TSSectionTypeReading =@"Reading";
NSString * const TSSectionTypeMath = @"Math";
NSString * const TSSectionTypeWriting = @"Writing";
NSString * const TSSectionTypeScience = @"Science";
@interface TSSection ()
-(TSPassage*)passageWithIndex:(NSInteger)index;
@end
@implementation TSSection
@synthesize passageIndices,passageTitles,lengthInMinutes,complete,started;

-(NSDictionary*)dictionaryRepresentation{
    NSMutableArray *passages = [NSMutableArray arrayWithCapacity:[passageIndices count]];
    
    for(int x = 0;x<[passageIndices count]; x++){
        [passages addObject:[[self passageWithIndex:x] dictionaryRepresentation]];
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:passages,@"passages",self.sectionName,@"sectionName",self.testID,@"testID",[NSNumber numberWithInteger:self.contentType],@"content_type",[NSNumber numberWithBool:complete],@"complete",[NSNumber numberWithFloat:self.unassignedTime],@"unassignedTime",self.testInfo,@"testInfo", nil];
}
-(TSPassage*)passageWithIndex:(NSInteger)index{
    TSPassage *passage = [[TSPassage alloc] init];
    passage.title = [passageTitles objectAtIndex:index];
    passage.index = index;
    NSInteger currentIndex = [[passageIndices objectAtIndex:index] integerValue];
    NSInteger nextIndex=0;
    if(index+1 < [passageIndices count])
        nextIndex = [[passageIndices objectAtIndex:index+1] integerValue];
    else
        nextIndex=self.numberOfRows;
    
    passage.questions = [self.questions subarrayWithRange:NSMakeRange(currentIndex, nextIndex-currentIndex)];
    passage.testID = self.testID;
    passage.sectionName = self.sectionName;
    return [passage autorelease];
}
- (void)dealloc {

    [passageIndices release];
    [passageTitles release];
    [super dealloc];
}
-(NSInteger)lengthOfTest{
    //return 6;
    return lengthInMinutes;
}

-(NSString*)titleForSection:(NSInteger)section{
    if([self.sectionName isEqualToString:TSSectionTypeMath])
        return nil;
    
    return passageTitles[section];

}
-(NSInteger)numberOfRows{
    return [self.questions count];
}
-(NSIndexPath*)indexPathOfQuestion:(NSInteger)questionIndex{
    if([passageIndices count] == 0)
        return [NSIndexPath indexPathForRow:questionIndex inSection:0];
    else{
        NSInteger index = -1;
        for(NSNumber *passageCutoff in passageIndices){
            //[0,45,55,60]
            if([passageCutoff integerValue] > questionIndex)
                break;
            index++;
        }
        return [NSIndexPath indexPathForRow:questionIndex-[[passageIndices objectAtIndex:index] integerValue] inSection:index];
    }
}
-(NSInteger)numberOfSections{
    if([passageIndices count] == 0)
        return 1;
    return [passageIndices count];
}

-(NSInteger)numberOfRowsInSection:(NSInteger)section{
    if([passageIndices count] == 0)
        return [self.questions count];
    else if(section == [passageIndices count] -1)
        return [self.questions count] - [[passageIndices objectAtIndex:section] integerValue];
    else
        return [[passageIndices objectAtIndex:section+1] integerValue] - [[passageIndices objectAtIndex:section] integerValue];
}




-(NSInteger)questionIndexForIndexPath:(NSIndexPath*)indexPath{
    return [[passageIndices objectAtIndex:indexPath.section] integerValue]+indexPath.row;
}

@end
