//
//  NewBuildOfApp.h
//  MC HW
//
//  Created by Eric Lubin on 12/23/12.
//
//

#import <Foundation/Foundation.h>

@interface NewBuildOfApp : NSObject
@property (nonatomic,copy) NSString *appName;
@property (nonatomic,copy) NSString *formattedReleaseDate;
@property (nonatomic,copy) NSString *releaseNotes;
@property (nonatomic,copy ) NSString *version;
@property (nonatomic,copy) NSString *url;
@property (nonatomic,strong) NSNumber *expiration;
@end
