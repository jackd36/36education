//
//  UnuploadedTestTableViewCell.h
//  MC HW
//
//  Created by Eric Lubin on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum{
  ELUploadingStateComplete=3,
  ELUploadingStateFailed=2,
  ELUploadingStateLoading=1,
  ELUploadingStateNone=0,
  ELUploadingStateAlertFailed=4//this one has an exclamation point
} ELUploadingState;

@interface UnuploadedTestTableViewCell : UITableViewCell

@property (nonatomic) ELUploadingState state;

@end
