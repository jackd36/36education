//
//  TSSection.h
//  MC HW
//
//  Created by Eric Lubin on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSTestTakingModel.h"
#import "TSTestAbstractBase.h"
NSString extern * const TSSectionTypeReading;
NSString extern * const TSSectionTypeMath;
NSString extern * const TSSectionTypeWriting;
NSString extern * const TSSectionTypeScience;

@interface TSSection : TSTestAbstractBase




//passage info
@property (nonatomic,strong) NSArray *passageIndices;
@property (nonatomic,strong) NSArray *passageTitles;
@property (nonatomic) NSInteger lengthInMinutes;
@property (nonatomic) BOOL started;
@property (nonatomic) BOOL complete;
@end
