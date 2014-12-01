//
//  TSUser.m
//  MC HW
//
//  Created by Eric Lubin on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TSUser.h"
#import <CoreData/CoreData.h>

@implementation TSUser
@synthesize object_id,firstName,lastName,email,userType,lastLogin,username,password,students,requirePasswordChange;

-(void)dealloc{
    [firstName release];
    [lastName release];
    [email release];
    [lastLogin release];
    [username release];
    [password release];
    [students release];
    [super dealloc];
}

-(NSString*)fullName{
    return [NSString stringWithFormat:@"%@ %@",firstName,lastName,nil];
}

-(NSUInteger)count{
    return 0;
}

-(BOOL)verifyStudentBelongs:(NSDictionary*)adminStudent{
    __block BOOL found = NO;
    [adminStudent[@"tutors"] enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        if([obj[@"pk"] integerValue] == self.object_id){
            found = YES;
        }
    }];
    
    return found;
}
-(NSInteger)indexOfFirstActiveStudent{
    NSInteger x = 0;
    for(NSDictionary *student in self.students){
        if([student[@"active"] boolValue])
            return x;
            
        x++;
    }
    return NSNotFound;
}

-(NSDictionary*)firstActiveStudent{
    NSInteger index = [self indexOfFirstActiveStudent];
    if(index == NSNotFound)
        return nil;
    return self.students[index];
}
@end
