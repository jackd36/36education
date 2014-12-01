#import "JSONToObjC.h"
#import "TSTest.h"
#import "TSSection.h"
#import "TSTestAbstractBase.h"
#import "TestQueueViewController.h"
#import "TestTakingViewController.h"
#import "TSPassage.h"

UIViewController *testTakingViewControllerFromJson(NSDictionary *dict,NSDictionary *assignmentInfo){
    //assignmentInfo contains a dictionary with two keys: textLabel and detailTextLabel, these help describe the assignment in a tableview in the case it fails to upload correctly.
    
    NSMutableDictionary *info = [[assignmentInfo mutableCopy] autorelease];
    
    if([info valueForKey:@"detailTextLabel"] == nil || [info valueForKey:@"detailTextLabel"] == [NSNull null]){//is a test
        [info setValue:[info valueForKey:@"textLabel"] forKey:@"detailTextLabel"];
        [info removeObjectForKey:@"textLabel"];
    }
    
    NSDictionary *objectInfo = [dict valueForKey:@"object_info"];
    NSDictionary *attemptInfo = [dict valueForKey:@"attempt_info"];
    
    NSString *className = [objectInfo valueForKey:@"class_name"];
    
    //UIViewController *vc = nil;
    
    if(className == nil){//test, construct the tree of tests/sections/passages
        NSMutableArray *arrayOfSections = [NSMutableArray arrayWithCapacity:[[objectInfo valueForKey:@"sections"] count]];
        for(NSDictionary *section in [objectInfo valueForKey:@"sections"]){
            TSSection *s = sectionFromDict(section);
            s.testInfo = info;
            [arrayOfSections addObject:s];
        }
        
        
        TSTest *test = [[[TSTest alloc] init] autorelease];
        test.sections = arrayOfSections;
        test.testID = [[test.sections lastObject] testID];
        test.assignmentID = [[objectInfo valueForKey:@"assignment_id"] integerValue];
        
        test.contentType = [[objectInfo valueForKey:@"content_type"] integerValue];
        
        //if the atempt had aleady been started, this sets the answers and completion statuses accordingly
        id sections = [attemptInfo valueForKey:@"sections"];
        if(sections != [NSNull null] && [sections count] > 0){
            for(NSDictionary *section in [attemptInfo valueForKey:@"sections"]){
                TSSection *section_inst = nil;
                
                for(TSSection *obj in test.sections){
                    if([obj.sectionName isEqualToString:[section valueForKey:@"section_name"]]){
                        section_inst = obj;
                        break;
                    }
                }
                
                //section_inst.testInfo = info;
                section_inst.started=[[section objectForKey:@"started"] boolValue];
                section_inst.answers = [section objectForKey:@"answers"];
                //[section_inst setAnswers:[section valueForKey:@"answers"]];
                //section_inst.answers = [section valueForKey:@"answers"];
                section_inst.unassignedTime = [[section valueForKey:@"unassigned_time"] floatValue];
                section_inst.complete = [[section valueForKey:@"completed"] boolValue];
                section_inst.totalTimeSpentThusFar = [[section valueForKey:@"time_spent"] floatValue];
                section_inst.assignmentID = [[objectInfo valueForKey:@"assignment_id"] integerValue];
                //section_inst.timedTest = [[objectInfo valueForKey:@"timed_test"] boolValue];
            }
        }
        
        
        TestQueueViewController *vc2= [[TestQueueViewController alloc] initWithStyle:UITableViewStyleGrouped];
        vc2.test = test;
    
        return vc2;
        
    }
    else{
        
        TSTestAbstractBase *testTakingModel = nil;
        if([className isEqualToString:NSStringFromClass([TSPassage class])]){
            TSPassage *passage = [[[TSPassage alloc] init] autorelease];
            passage.numberOfQuestions = [[objectInfo valueForKey:@"num_questions"] integerValue];
            passage.index = [[objectInfo valueForKey:@"index"] integerValue];
            passage.title= [objectInfo valueForKey:@"title"];
            passage.testID = [objectInfo valueForKey:@"test"];
            passage.sectionName = [objectInfo valueForKey:@"section_name"];
            passage.objectID = [[objectInfo valueForKey:@"object_id"] integerValue];
            passage.numChoices = [[objectInfo valueForKey:@"num_choices"] integerValue];
            passage.offset = [[objectInfo valueForKey:@"offset"] integerValue];
            passage.testInfo = info;
            testTakingModel = passage;
            
        }
        else if([className isEqualToString:NSStringFromClass([TSSection class])]){
            TSSection *section = sectionFromDict(objectInfo);
            section.testInfo=info;
            testTakingModel = section;
        }
        testTakingModel.assignmentID = [[objectInfo valueForKey:@"assignment_id"] integerValue];
        testTakingModel.timedTest = [[objectInfo valueForKey:@"timed_test"] boolValue];
        testTakingModel.contentType = [[objectInfo valueForKey:@"content_type"] integerValue];
        testTakingModel.correct_answers = [objectInfo valueForKey:@"correct_answers"];
        id answers = [attemptInfo valueForKey:@"answers"];
        if(answers != nil && answers != [NSNull null]){
            testTakingModel.answers = answers;
//            [testTakingModel setAnswers:answers afterTimeLimit:[attemptInfo valueForKey:@"over_time_limit"]];
            //testTakingModel.answers = answers;
            testTakingModel.unassignedTime = [[attemptInfo valueForKey:@"unassigned_time"] floatValue];
            testTakingModel.totalTimeSpentThusFar = [[attemptInfo valueForKey:@"time_spent"] floatValue];
        }
        
        TestTakingViewController *vc2 = [[TestTakingViewController alloc] initWithDataModel:testTakingModel];
        return vc2;
        
    }
    
    
    
}


TSSection *sectionFromDict(NSDictionary* dict){
    TSSection *section = [[[TSSection alloc] init] autorelease];
    section.objectID = [[dict valueForKey:@"object_id"] integerValue];
    section.correct_answers = [dict valueForKey:@"correct_answers"];
    section.sectionName = [dict valueForKey:@"section_name"];
    section.testID = [dict valueForKey:@"test"];
    section.timedTest = [[dict valueForKey:@"timed_test"] boolValue];
    NSInteger numQuestions = [[dict valueForKey:@"num_questions"] integerValue];
    section.numberOfQuestions = numQuestions;
    section.passageTitles = [dict valueForKey:@"passage_titles"];
    section.passageIndices = [dict valueForKey:@"passage_indices"];
    section.lengthInMinutes = [[dict valueForKey:@"length"] integerValue];
    section.numChoices  = [[dict valueForKey:@"num_choices"] integerValue];
    section.contentType = [[dict valueForKey:@"content_type"] integerValue];
    return section;
}

