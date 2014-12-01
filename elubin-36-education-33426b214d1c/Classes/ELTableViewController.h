//
//  ELTableViewController.h
//  MC HW
//
//  Created by Eric Lubin on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//custom class to allow for a dynamically sized, title view that doesn't scroll in scrollview
@interface ELTableViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>{
    UITableViewStyle _style;
}
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) UITableView *tableView;
@property(nonatomic) BOOL clearsSelectionOnViewWillAppear;

- (id)initWithStyle:(UITableViewStyle)style;
@end
