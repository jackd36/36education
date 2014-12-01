//
//  GenericTestUploadHTTPRequest.h
//  MC HW
//
//  Created by Eric Lubin on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSHTTPRequest.h"
typedef enum{
    NoTestUpload=0,
    UncompletedTestUpload =1,
    CompletedTestUpload=2,
} TestUpload;
@interface GenericTestUploadHTTPRequest : TSHTTPRequest
@property (nonatomic,copy) ASIBasicBlock additionalFailureBlock;

- (id)initForUser:(NSInteger)uid WithAssignmentID:(NSInteger)assignmentID jsonAnswerString:(NSString*)json completed:(BOOL)completed sectionName:(NSString*)sectionName onRetry:(NSInteger)retrycount;
+ (id)requestForUser:(NSInteger)uid WithAssignmentID:(NSInteger)assignmentID jsonAnswerString:(NSString*)json completed:(BOOL)completed sectionName:(NSString*)sectionName onRetry:(NSInteger)retrycount;;


//convenience methods ot deal with assignment attempts that fail to upload successfully
+ (void)saveProgressInTest:(NSString*)json forUser:(NSInteger)uid assignmentID:(NSInteger)assignmentID completed:(BOOL)completed sectionName:(NSString*)sectionName;
+(void)deleteInstanceOfAssignment:(NSInteger)assignmentID sectionName:(NSString*)sectionName uid:(NSInteger)uid;


+(TestUpload)valueFromTestObject:(NSDictionary*)test;
+ (TestUpload)testUploadForAssignment:(NSInteger)assignmentID uid:(NSInteger)uid;
+ (TestUpload)testUploadForAssignment:(NSInteger)assignmentID sectionName:(NSString*)name uid:(NSInteger)uid;

+(NSArray*)unuploadedTestsWithStatus:(TestUpload)status forUploader:(NSInteger)uid;
+(NSArray*)allUnuploadedTestsForUser:(NSInteger)uid;
@end
