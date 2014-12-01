//
//  TSUser.h
//  MC HW
//
//  Created by Eric Lubin on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum{
    TSUserTypeNone,
    TSUserTypeTutor,
    TSUserTypeStudent
} TSUserType;

@interface TSUser : NSObject
@property (nonatomic) NSInteger object_id;
@property (nonatomic,copy) NSString *firstName;
@property (nonatomic,copy) NSString *lastName;
@property (nonatomic,copy) NSString *email;
@property (nonatomic) TSUserType userType;
@property (nonatomic,strong) NSDate *lastLogin;
@property (nonatomic,copy) NSString *username;
@property (nonatomic,copy) NSString *password;
@property (nonatomic,strong) NSArray *students;
//@property (nonatomic,strong) NSArray *locations;
@property (nonatomic) BOOL requirePasswordChange;
@property (nonatomic,getter=isStaff) BOOL staff;//denotes if the tutor is a staffmember and can perform admin functions
@property (nonatomic,getter=isAdmin) BOOL admin;//


-(NSDictionary*)firstActiveStudent;
-(NSString*)fullName;
-(BOOL)verifyStudentBelongs:(NSDictionary*)adminStudent;
@end
