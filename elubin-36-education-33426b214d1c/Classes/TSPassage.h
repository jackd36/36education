//
//  TSPassage.h
//  MC HW
//
//  Created by Eric Lubin on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSTestTakingModel.h"
#import "TSTestAbstractBase.h"
@interface TSPassage : TSTestAbstractBase

@property (nonatomic,copy) NSString *title;
@property (nonatomic) NSInteger index;
@property (nonatomic) NSInteger offset; //this is used for passages other than passage 1 where the question indices don't necessarilly start at 0.
-(NSDictionary*)dictionaryRepresentation;
@end
