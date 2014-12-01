//
//  ACTResult.m
//  MC HW
//
//  Created by Eric Lubin on 11/21/12.
//
//

#import "ACTResult.h"
#define ACTResultIDKey @"id"
#define ACTResultScoresKey @"sections"
#define ACTResultFormattedDateKey @"formatted_date"
#define ACTResultNotesKey @"notes"
#define ACTResultCompositeScoreKey @"composite_score"
#define ACTResultMonthKey @"month"
#define ACTResultYearKey @"year"

#define ACTResultSectionScoreKey @"score"
#define ACTResultSubSectionScoreKey @"sub_scores"



@interface ACTResult()
@property (nonatomic,strong) NSArray *initalizedScoresWhileEditing; //this is just used for covenience while editing;
@property (nonatomic) BOOL dirty;

@property (nonatomic,strong) NSNumber *compositeScore;

@property (nonatomic,strong) NSDateComponents *dateTaken;
@property (nonatomic,strong) NSArray *scores;
@property (nonatomic,strong)NSArray *allowedRanges;
@end
@implementation ACTResult
-(id)initWithID:(NSInteger)objectID allowedRanges:(NSArray*)allowedRanges{
    if(self = [super init]){
        _objectID = objectID;
        if(objectID == NSNotFound){
            _scoresDirty = YES;
        }
        _dateTaken = [[NSDateComponents alloc] init];
        _notes = @""; //this is the default value
        self.allowedRanges = allowedRanges;
        
    }
    
    return self;
}



-(NSArray*)initalizedScoresWhileEditing{
    if(_initalizedScoresWhileEditing == nil){
        [self initializeScores:self.sectionScores subsets:self.subScores];
    }
    return _initalizedScoresWhileEditing;
}


-(NSDateComponents*)dateTaken{
    return _dateTaken;
}


-(NSArray*)sectionScores{
    return [self.scores valueForKey:ACTResultSectionScoreKey];
}


-(NSArray*)subScores{
    return [self.scores valueForKey:ACTResultSubSectionScoreKey];
    
}

-(id)initWithDictionaryRepresentation:(NSDictionary*)actResult allowedRanges:(NSArray*)allowedRanges{
    if(self = [self initWithID:[actResult[ACTResultIDKey] integerValue] allowedRanges:allowedRanges]){
        _scores = actResult[ACTResultScoresKey];
        _dateString = actResult[ACTResultFormattedDateKey];
        _notes = actResult[ACTResultNotesKey];
        _compositeScore = actResult[ACTResultCompositeScoreKey];
        //NSDateComponents *components = [[NSDateComponents alloc] init];

        _dateTaken.year = [actResult[ACTResultYearKey] integerValue];
        _dateTaken.month = [actResult[ACTResultMonthKey] integerValue];
        
    }
    return self;
}





-(id)initWithAllowedRanges:(NSArray *)allowedRanges{
    if(self = [self initWithID:NSNotFound allowedRanges:allowedRanges]){
        
    }
    
    return self;
}


-(BOOL)isNew{
    return self.objectID == NSNotFound;
}

-(void)setBlankScores:(NSArray*)sectionNames verboseNames:(NSArray*)verboseNames{
    NSInteger numberOfSections = [sectionNames count];
    NSMutableArray *mainScores = [NSMutableArray arrayWithCapacity:numberOfSections];
    NSMutableArray *subsetScores = [NSMutableArray arrayWithCapacity:numberOfSections];
    for(int i=0;i<numberOfSections;i++){
        [mainScores addObject:[NSNull null]];
        NSMutableArray *subset = [NSMutableArray arrayWithCapacity:[verboseNames[i] count]];
        for(int j=0;j<[verboseNames[i] count];j++){
            [subset addObject:[NSNull null]];
        }
        [subsetScores addObject:subset];
    }
    
    [self initializeScores:mainScores subsets:subsetScores];
}

-(void)initializeScores:(NSArray*)mainscores subsets:(NSArray*)subsets{
    //NSMutableArray *textfields = [NSMutableArray arrayWithCapacity:[mainscores count]];
    NSMutableArray *finalOutput = [NSMutableArray arrayWithCapacity:[mainscores count]];
    for(int x = 0; x<[mainscores count];x++){
        NSMutableArray *subscores = [subsets[x] mutableCopy];
        [subscores insertObject:mainscores[x] atIndex:0];
        [finalOutput addObject:subscores];
    }
    self.initalizedScoresWhileEditing = finalOutput;
}



-(void)setNotes:(NSString *)notes{
    if(![notes isEqualToString:_notes]){
        _notes = notes;
        _dirty = YES;
    }
}


-(void)setDateString:(NSString *)dateString{
    if(![dateString isEqualToString:_dateString]){
        _dateString = dateString;
        _dirty = YES;
    }
}

-(NSArray*)scores{
    return _scores;
}


-(BOOL)save{
    
    if(!_dirty){
        return NO;
    }
    else if(!_scoresDirty){
        return YES;
    }
    else{
        //we need to transcribe the changes in initalizedScoresWhileEditing and regenereate the scores array.
        NSMutableArray *newScoresArray = [NSMutableArray arrayWithCapacity:[_initalizedScoresWhileEditing count]];
        for(NSArray *scores in _initalizedScoresWhileEditing){
            NSNumber *sectionScore = scores[0];
            NSArray *subscores = nil;
            NSInteger totalItems = [scores count];
            if(totalItems > 1){
                subscores = [scores objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, totalItems-1)]];
                
            }
            else{
                subscores = @[];
            }
            
            NSDictionary *newScoreItem = @{ACTResultSectionScoreKey:sectionScore,ACTResultSubSectionScoreKey:subscores};
            [newScoresArray addObject:newScoreItem];
        }
        self.scores = newScoresArray;
        return YES;
    }
}


-(void)setScoresDirty:(BOOL)scoresDirty{
    //setting scoresDirty to True should also set dirty to true
    
    _scoresDirty = scoresDirty;
    if(scoresDirty){
        _dirty = YES;
        _compositeScore = nil;
    }
}
-(NSInteger)numberOfScoresEntered{
    int i = 0;
    if(_initalizedScoresWhileEditing != nil){//use this array, it is guaranteed to be more up to date
        for(NSArray *scores in _initalizedScoresWhileEditing){
            id item = scores[0];
            if(item != [NSNull null]){
                i++;
            }
        }
    }
    else {
        for(id item in self.sectionScores){
            if(item != [NSNull null]){
                i++;
            }
        }
    }
    return i;
}

-(BOOL)isValid{
    return self.dateString != nil && [self numberOfScoresEntered] >= 1;
}
-(NSNumber*)compositeScore{
    if(_compositeScore == nil){
        //TODO: need to dynamically calculate composite score here from the scores array. we assume that the composite score will only need to be calculated when editing is done, not while editing, so the intializedScoresWhileEditing array is unimportant
        
        
        NSArray *sectionScores = self.sectionScores;
        
        int i = 0,count = 0,sum=0;
        for(NSArray *scores in self.allowedRanges) {
            NSValue *value = scores[0];
            NSRange range = [value rangeValue];
            
            if(range.location + range.length == MAXIMUM_SCORE_FOR_SECTION){
                if(sectionScores[i] != [NSNull null]){
                    sum+= [sectionScores[i] integerValue];
                    count++;
                }
            }
            
            i++;
        }
        
        
        if(count == 0)
            _compositeScore = @(NSNotFound);
        else{
            _compositeScore = @(sum/count);
        }
        
    }
    return _compositeScore;
}
-(BOOL)saveAndClose{
    BOOL dirty = [self save];
    self.initalizedScoresWhileEditing = nil;
    _dirty = NO;
    _scoresDirty = NO;
    return dirty;
}

-(NSDictionary*)postDictionary{
    return @{ACTResultMonthKey:[NSString stringWithFormat:@"%d",self.dateTaken.month],ACTResultYearKey:[NSString stringWithFormat:@"%d",self.dateTaken.year],ACTResultNotesKey:_notes,ACTResultScoresKey:[self.scores JSONRepresentation]};
}
@end
