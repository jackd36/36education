//
//  GenericTestUploadHTTPRequest.m
//  MC HW
//
//  Created by Eric Lubin on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "TestTakingViewController.h"
#import "GenericTestUploadHTTPRequest.h"
@interface GenericTestUploadHTTPRequest ()
@property (nonatomic,copy) ASIBasicBlock completedBlock;

@end

@implementation GenericTestUploadHTTPRequest
@synthesize completedBlock,additionalFailureBlock;
- (void)dealloc
{
    [completedBlock release];
    [additionalFailureBlock release];
    [super dealloc];
}
-(id)initForUser:(NSInteger)uid WithAssignmentID:(NSInteger)assignmentID jsonAnswerString:(NSString*)json completed:(BOOL)completed sectionName:(NSString*)sectionName onRetry:(NSInteger)retrycount{
    if(self = [self initWithPathComponent:[NSString stringWithFormat:@"hw/%d/upload/",assignmentID]]){
        self.useSVProgressHUD = YES;
        self.progressMaskType = SVProgressHUDMaskTypeClear;
        self.shouldContinueWhenAppEntersBackground = YES;
        self.timeOutSeconds = 25;
        self.cachePolicy = ASIDoNotWriteToCacheCachePolicy | ASIDoNotReadFromCacheCachePolicy;
        
        [self addPostValue:json forKey:@"json"];
        [self addPostValue:[[NSNumber numberWithBool:completed] description] forKey:@"completed"];
        [self addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
        
        __block typeof(self) blockSelf = self;
        
        //fixed this on 6/24 Literally one humongous retain cycle. FML. thank god.
        //the block was retaining the test taking view controllers, but the block was never being released because there was a retain cycle on the request and another block, so the completion block was never being released so the controller was never being released all leading to zombie notifications when the controller wasn't present
        self.failedBlock = ^{
            
            [[blockSelf class] saveProgressInTest:json forUser:uid assignmentID:assignmentID completed:completed sectionName:sectionName onRetry:retrycount];

            if(blockSelf.additionalFailureBlock){
                blockSelf.additionalFailureBlock();
            }


            
        };
        self.completedBlock = ^{
            [[blockSelf class] deleteInstanceOfAssignment:assignmentID sectionName:sectionName uid:uid];
        };
    }
    return self;
}

+(void)deleteInstanceOfAssignment:(NSInteger)assignmentID sectionName:(NSString*)sectionName uid:(NSInteger)uid{
    //edit the  NSUserDefaults to remove all instances of unuploaded tests if any are present for the given user
    NSMutableArray *array = [NSMutableArray array];
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:UnuploadedTestsKey];
    NSArray *existing = [[NSUserDefaults standardUserDefaults] objectForKey:UnuploadedTestsKey];
    if([existing count] >0)
        [array addObjectsFromArray:existing];
    
    //not using the uid parameter because we want to avoid conflicts. we assume that the person who is submitting now has the most update copy, they would be helplessly out of sync anyway if we kept both
    NSArray *hits = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"assignmentID == %d && section_type == %@",assignmentID,sectionName]];
    [array removeObjectsInArray:hits];
    //NSDictionary *hit = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"assignmentID == %d",assignmentID
    
    [[NSUserDefaults standardUserDefaults] setValue:array forKey:UnuploadedTestsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)saveProgressInTest:(NSString*)json forUser:(NSInteger)uid assignmentID:(NSInteger)assignmentID completed:(BOOL)completed sectionName:(NSString*)sectionName{
    [self saveProgressInTest:json forUser:uid assignmentID:assignmentID completed:completed sectionName:sectionName onRetry:0];
}

+(void)saveProgressInTest:(NSString*)json forUser:(NSInteger)uid assignmentID:(NSInteger)assignmentID completed:(BOOL)completed sectionName:(NSString*)sectionName onRetry:(NSInteger)retrycount{
    //this is where the test will be saved locally if it cannot be uploaded immediately, should also check for another instance of the test already saved locally, if it was a case of try, retry, and fail
    NSMutableArray *array = [NSMutableArray array];
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:UnuploadedTestsKey];
    NSArray *existing = [[NSUserDefaults standardUserDefaults] objectForKey:UnuploadedTestsKey];
    if([existing count] >0)
        [array addObjectsFromArray:existing];
    NSArray *hits = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"assignmentID == %d && section_type == %@",assignmentID,sectionName]];
    BOOL newCompleted = NO;
    for (NSDictionary *hit in hits){
        if ([[hit valueForKey:@"completed"] boolValue]) {
            newCompleted = YES;
            break;
        }
    }
    
    [array removeObjectsInArray:hits];
    //NSDictionary *hit = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"assignmentID == %d",assignmentID
    //if(retrycount < 5){
    NSDictionary *archivedTest=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:assignmentID],@"assignmentID",json,@"JSON",[NSNumber numberWithBool:completed || newCompleted],@"completed",sectionName,@"section_type", [NSNumber numberWithInt:retrycount+1],@"retry_count",[NSNumber numberWithInteger:uid],@"uid",nil];
    [array addObject:archivedTest];
    //}
    [[NSUserDefaults standardUserDefaults] setValue:array forKey:UnuploadedTestsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (TestUpload)testUploadForAssignment:(NSInteger)assignmentID sectionName:(NSString*)name uid:(NSInteger)uid{
    NSMutableString *formatString = [NSMutableString stringWithFormat:@"assignmentID == %d",assignmentID];
    if(name != nil)
        [formatString appendFormat:@" && section_type == \"%@\"",name];
    if(uid != NSNotFound)
        [formatString appendFormat:@" && uid == %d",uid];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:formatString];
    NSArray *existing = [[NSUserDefaults standardUserDefaults] objectForKey:UnuploadedTestsKey];

    NSArray *subarray = [existing filteredArrayUsingPredicate:predicate];
    if([subarray count] == 0){
        return NoTestUpload;
    }
    else{
        if(name != nil){ // can only be 1 result
            NSDictionary *test = [subarray lastObject];
            return [self valueFromTestObject:test];
        }
        else{
            if([subarray count] == 1){
                NSDictionary *test = [subarray lastObject];
                return [self valueFromTestObject:test];
            }
            else{
                TestUpload type = NoTestUpload;
                for(NSDictionary *test in subarray){
                    type |= [self valueFromTestObject:test];
                }
                return type;
                
            }
        }
    }
    
}
+ (TestUpload)testUploadForAssignment:(NSInteger)assignmentID uid:(NSInteger)uid{
    return [self testUploadForAssignment:assignmentID sectionName:nil uid:uid];
}
+(TestUpload)valueFromTestObject:(NSDictionary*)test{
    BOOL completed = [[test valueForKey:@"completed"] boolValue];
    if(completed){
        return CompletedTestUpload;
    }
    else
        return UncompletedTestUpload;
}

+(id)requestForUser:(NSInteger)uid WithAssignmentID:(NSInteger)assignmentID jsonAnswerString:(NSString*)json completed:(BOOL)completed sectionName:(NSString*)sectionName onRetry:(NSInteger)retrycount{
    return [[[self alloc] initForUser:uid WithAssignmentID:assignmentID jsonAnswerString:json completed:completed sectionName:sectionName onRetry:retrycount] autorelease];
}
-(void)clearDelegatesAndCancel{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(completedBlock){
            [completedBlock release];
            completedBlock = nil;
        }
        if(additionalFailureBlock){
            [additionalFailureBlock release];
            additionalFailureBlock = nil;
        }
        
    });
    [super clearDelegatesAndCancel];
}



-(void)requestFinished{
    #if NS_BLOCKS_AVAILABLE
        if(completedBlock){
            completedBlock();
        }
    #endif
    [super requestFinished];
}

+(NSArray*)unuploadedTestsWithStatus:(TestUpload)status forUploader:(NSInteger)uid{
    NSArray *existing = [[NSUserDefaults standardUserDefaults] objectForKey:UnuploadedTestsKey];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        if(uid == NSNotFound || [[evaluatedObject valueForKey:@"uid"] integerValue] == uid){
            BOOL completed = [[evaluatedObject valueForKey:@"completed"] boolValue];
            
            return (status & UncompletedTestUpload && !completed) || (status & CompletedTestUpload && completed) || status == NoTestUpload;
        }
        return NO;
    }];
    
    return [existing filteredArrayUsingPredicate:predicate];
}
//
//+(NSArray*)unuploadedTestsWithStatus:(TestUpload)status{
//    return [self unuploadedTestsWithStatus:status forUploader:NSNotFound];
//}


+(NSArray*)allUnuploadedTestsForUser:(NSInteger)uid{
    return [self unuploadedTestsWithStatus:NoTestUpload forUploader:uid];
}
//-(void)failWithError:(NSError *)theError{
//
//     //show alert instance variable
//     if(self.showAlertMessages){
//        static NSString * errorMessage = @"Connection error!\n The test could not be uploaded. Please wait until there is a better connection and try again later.";
//         //at this point i need to notify the testtakingviewcontroller to disable further entry. In addition, I need to make sure that if the app is closed, the app will be saved with COMPLETED KEY equal to true, although it will default to false. Maybe add a spot in the UI to view uncompleted tests? TODO TODO
//        if([self useSVProgressHUD])
//            [SVProgressHUD dismissWithError:errorMessage afterDelay:5];
//        else{
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
//            [alert show];
//            [alert release];
//        }
//     }
////    [self performSelectorOnMainThread:@selector(reportFinished) withObject:nil waitUntilDone:[NSThread isMainThread]];
//    [super failWithError:theError];
//}
@end
