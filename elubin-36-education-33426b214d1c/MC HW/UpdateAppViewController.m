//
//  UpdateAppViewController.m
//  MC HW
//
//  Created by Eric Lubin on 12/23/12.
//
//

#import "UpdateAppViewController.h"
#import "NewBuildOfApp.h"
#import "MoreInfoButton.h"
@interface UpdateAppViewController ()
@property (nonatomic,strong) NSDate *dateOpened;
@property (nonatomic,strong) NSTimer *expirationTimer;

@end

@implementation UpdateAppViewController



-(NSDate*)expirationDate{
    return [NSDate dateWithTimeIntervalSinceReferenceDate:[self.dateOpened timeIntervalSinceReferenceDate]+[self.app.expiration integerValue]*60];
}

- (id)init
{
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.dateOpened = [NSDate date];
        [self configureExpirationTimer];
        // Custom initialization
    }
    return self;
}
- (void)dealloc
{
    [self.expirationTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)configureExpirationTimer{
    self.expirationTimer = [NSTimer timerWithTimeInterval:[[self expirationDate] timeIntervalSinceDate:self.dateOpened] target:self selector:@selector(dismissViewController) userInfo:nil repeats:NO];
    
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = _app.appName;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewController)];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invalidateTimer) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configureExpirationTimer) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
}

-(void)invalidateTimer{
    if([self.expirationTimer isValid]){
        [self.expirationTimer invalidate];
    }
}

-(void)dismissViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1 + (int)([_app.releaseNotes length] > 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}
-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1){
        //if([self dictionaryIsTagTitle:dict]){
        id text = _app.releaseNotes;
        
        if(text != [NSNull null] && [text length] > 0){
            UIFont *cellFont = [UIFont systemFontOfSize:15.0f];
            CGFloat width = tableView.frame.size.width;
            if(self.tableView == tableView){
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                    width -= 45*2;
                else
                    width -= 10*2;
            }
            width-=50;
            
            CGSize constraintSize = CGSizeMake(width, MAXFLOAT);
            CGSize labelSize = [text sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
            CGFloat height = labelSize.height+10;
            if(height >= 45)
                return height;
            else
                return 45;
        }
    }
    
    
    return 75.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if(IS_IOS_7){
                UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
                [button setTitle:@"INSTALL" forState:UIControlStateNormal];
                [button addTarget:self action:@selector(installUpdate) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = button;
            }
            else{
                MoreInfoButton *button = [[MoreInfoButton alloc] init];
                button.title = @"INSTALL";
                [button addTarget:self action:@selector(installUpdate) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = button;
            }
            
        }
        
        cell.imageView.image = [UIImage imageNamed:@"iPhone"];
        cell.textLabel.text = [NSString stringWithFormat:@"Version %@",_app.version];
        cell.detailTextLabel.text = _app.formattedReleaseDate;
        return cell;
    }
    else{
        static NSString *CellIdentifier5 = @"Cell5";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier5];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier5];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        }
        cell.textLabel.text = _app.releaseNotes;
        return cell;
    }
    
    // Configure the cell...
    
    
}

-(void)installUpdate{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_app.url]];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 1)
        return @"Release Notes";
    
    return nil;
    
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        [self installUpdate];
    }
}

@end
