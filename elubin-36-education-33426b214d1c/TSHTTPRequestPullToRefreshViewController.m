//
//  TSHTTPRequestPullToRefreshViewController.m
//  MC HW
//
//  Created by Eric Lubin on 1/17/13.
//
//

#import "TSHTTPRequestPullToRefreshViewController.h"

@interface TSHTTPRequestPullToRefreshViewController ()

@end

@implementation TSHTTPRequestPullToRefreshViewController

-(void)reloadTableViewDataSource{
    TSHTTPRequest *request = [TSHTTPRequest requestWithPathComponent:[self uniqueURLPath]];
    [self customizeRequest:request];
    __weak TSHTTPRequest *weakRequest = request;
    
    request.completionBlock = ^{
        id info = [[weakRequest responseData] JSONValue];
        [self requestCompleted:info];
        [self.tableView reloadData];
        [self doneLoadingTableViewDataWithSuccess:weakRequest.didLoadFromWeb];
    };
    request.failedBlock = ^{
        [self doneLoadingTableViewDataWithSuccess:NO];
        [self requestFailed:weakRequest];
    };
    
    [request startAsynchronous];
}

-(void)customizeRequest:(TSHTTPRequest *)request{
    //for subclasses to override
}

-(void)requestCompleted:(id)jsonValue{
    //for subclasses to override
}

-(void)requestFailed:(TSHTTPRequest *)request{
    //for subclasses to override as needed
}

@end
