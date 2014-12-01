//
//  ACTScoreiPadTableViewCell.h
//  MC HW
//
//  Created by Eric Lubin on 11/10/12.
//
//

#import <UIKit/UIKit.h>
@class ACTResult;
@interface ACTScoreiPadTableViewCell : UITableViewCell
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier sectionNames:(NSArray*)sections;
- (void)setSectionScoreInfo:(ACTResult*)info;
+ (NSInteger)heightForInfo:(NSDictionary*)info;
@end

