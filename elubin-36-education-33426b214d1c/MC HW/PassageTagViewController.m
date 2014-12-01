//
//  PassageTagViewController.m
//  MC HW
//
//  Created by Eric Lubin on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PassageTagViewController.h"
#import "PassageCell.h"
@interface PassageTagViewController ()

@end

@implementation PassageTagViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"Passage Tag";
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section ==2){
        NSDictionary *attempt = [[self arrayOfActiveSegment] objectAtIndex:indexPath.row];
        
        
        
        static NSString *CellIdentifierSectionInfo3 = @"SectionInfo3123";
        PassageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierSectionInfo3];
        if(cell == nil){
            cell = [[[PassageCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierSectionInfo3] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.object = attempt;
        cell.detailTextLabel.text = [attempt valueForKey:@"testID"];
        
        return cell;
        
        
        
        // Configure the cell...
        
        
    }
    else{
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}
-(NSString*)headerTitleForAggregates{
    return @"Passages";
}
@end
