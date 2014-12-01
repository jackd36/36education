//
//  UnuploadedTestsViewController.h
//  MC HW
//
//  Created by Eric Lubin on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericTestUploadHTTPRequest.h"

NSString extern * const DID_COMPLETE_UPLOADING_FALLBACKS;
@interface UnuploadedTestsViewController : UITableViewController{
    NSInteger uid;
}
- (id)initWithUID:(NSInteger)user;
- (id)initWithUID:(NSInteger)user testCompletionType:(TestUpload)type;
@end
