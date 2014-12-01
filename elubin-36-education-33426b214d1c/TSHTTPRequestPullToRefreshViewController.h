//
//  TSHTTPRequestPullToRefreshViewController.h
//  MC HW
//
//  Created by Eric Lubin on 1/17/13.
//
//

#import "PullToRefreshTableViewController.h"

@interface TSHTTPRequestPullToRefreshViewController : PullToRefreshTableViewController


-(void)customizeRequest:(TSHTTPRequest*)request; //for subclasses to override before the request is initiated
-(void)requestCompleted:(id)jsonValue;
-(void)requestFailed:(TSHTTPRequest*)request;
@end
