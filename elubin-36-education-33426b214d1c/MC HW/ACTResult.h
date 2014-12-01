//
//  ACTResult.h
//  MC HW
//
//  Created by Eric Lubin on 11/21/12.
//
//

#import <Foundation/Foundation.h>

@interface ACTResult : NSObject




@property (nonatomic,strong) NSString *dateString;
@property (nonatomic,strong) NSString *notes;
@property (nonatomic) NSInteger objectID;
@property (nonatomic) BOOL scoresDirty; // set to true in EditACTScoreViewControlle when modifying the initializedScoresWhileEditing array

-(BOOL)isNew;
-(id)initWithAllowedRanges:(NSArray*)allowedRanges;
-(id)initWithID:(NSInteger)objectID allowedRanges:(NSArray*)allowedRanges;
-(id)initWithDictionaryRepresentation:(NSDictionary*)actResult allowedRanges:(NSArray*)allowedRanges;
-(NSArray*)sectionScores;
-(NSArray*)subScores;
-(NSArray*)initalizedScoresWhileEditing;
 
-(void)setBlankScores:(NSArray*)sectionNames verboseNames:(NSArray*)verboseNames;

-(NSNumber*)compositeScore; //cached
-(NSDateComponents*)dateTaken; //read-only
-(NSArray*)scores; //read-only

-(BOOL)saveAndClose;//runs save and then frees up the memory stored in _initializedScoresWhileEditing, returns the dirty bit and then resets it

-(NSDictionary*)postDictionary;//used when saving changes to the database
-(BOOL)isValid;

@end
