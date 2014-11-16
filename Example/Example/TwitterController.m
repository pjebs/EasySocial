//
//  TwitterController.m
//  Example
//
//  Created by PJ on 14/11/14.
//
//

#import "TwitterController.h"

@interface TwitterController ()

    @property (strong) UIView * loadScreen;
    @property (strong) NSArray *data;
    @property (weak) IBOutlet UITableView * table;

    -(IBAction)login:(id)sender;
    -(IBAction)sendTweet:(id)sender;
    -(IBAction)sendTweetWithImage:(id)sender;

@end

@implementation TwitterController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchTimeline)
                                                 name:EasyTwitterAccountSetNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchTimeline)
                                                 name:EasyTwitterTweetSentNotification object:nil];

    [super viewDidLoad];
    self.title = @"Twitter Example";
    
}

-(IBAction)login:(id)sender
{
    [EasyTwitter sharedEasyTwitterClient].delegate = self;
    [[EasyTwitter sharedEasyTwitterClient] requestPermissionForAppToUseTwitterSuccess:^(BOOL granted, BOOL accountsFound, NSArray *accounts) {
        if (granted)
            NSLog(@"granted!");
        
        if (accountsFound)
        {
            /*
            accountsFound represents an array filled with ACAccount objects.
            This assumes that the user gave permission to the app to access the twitter accounts
            registered with the system (iOS built-in Settings App->Twitter section).
            It also assumes that there are twitter accounts registered with iOS.
            If not, remind the user to set up a twitter account.
             
            You can search through all the ACAccount objects in the array to find the desired account.
            ACAccount contains two properties that are useful:
            .username (Type:string i.e finkd)
            .accountDescription (Type:string i.e. @finkd)
            */
            
            [EasyTwitter sharedEasyTwitterClient].account = [accounts firstObject];
        }
        
        
        
    } failure:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

-(IBAction)sendTweet:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tweet"
                                                    message:[NSString stringWithFormat:@"Write your tweet"]
                                                   delegate:self cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    alert.tag = 1;
    [alert show];
    
}

-(IBAction)sendTweetWithImage:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tweet"
                                                    message:[NSString stringWithFormat:@"Write your tweet. An image from https://www.google.com/images/srpr/logo11w.png will be included."]
                                                   delegate:self cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    alert.tag = 2;
    [alert show];
    
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((alert.tag != 1) && (alert.tag != 2))
        return;
    
    NSString *message = [[alert textFieldAtIndex:0] text];
    
    [EasyTwitter sharedEasyTwitterClient].delegate = self;
    
    if (alert.tag == 1)
    {
        [[EasyTwitter sharedEasyTwitterClient] sendTweetWithMessage:message twitterResponse:^(id responseJSON,NSDictionary *JSONError, NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            
            if (JSONError == nil)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tweet Sent!"
                                                                message:nil
                                                               delegate:self cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                //Twitter error codes can be found here: https://dev.twitter.com/overview/api/response-codes
                //JSON error code 187 - Tweet is duplicate
                //JSON error code 186 - Tweet is too long (over 140 characters)
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error code: %d", [[JSONError objectForKey:@"code"] intValue]]
                                                                message:[JSONError objectForKey:@"message"]
                                                               delegate:self cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            
        } failure:^(EasyTwitterIssues issue) {
            if (issue == EasyTwitterNoAccountSet)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tweet not sent"
                                                                message:[NSString stringWithFormat:@"No Account set"]
                                                               delegate:self cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
    else if (alert.tag == 2)
    {
        [[EasyTwitter sharedEasyTwitterClient] sendTweetWithMessage:message imageURL:[NSURL URLWithString:@"https://www.google.com/images/srpr/logo11w.png"] twitterResponse:^(id responseJSON, NSDictionary *JSONError, NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            
            if (JSONError == nil)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tweet Sent!"
                                                                message:nil
                                                               delegate:self cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                //Twitter error codes can be found here: https://dev.twitter.com/overview/api/response-codes
                //JSON error code 187 - Tweet is duplicate
                //JSON error code 186 - Tweet is too long (over 140 characters)
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error code: %d", [[JSONError objectForKey:@"code"] intValue]]
                                                                message:[JSONError objectForKey:@"message"]
                                                               delegate:self cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        } failure:^(EasyTwitterIssues issue) {
            if (issue == EasyTwitterNoAccountSet)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tweet not sent"
                                                                message:[NSString stringWithFormat:@"No Account set"]
                                                               delegate:self cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
    
}

- (void) fetchTimeline
{
    __weak typeof(self) weakSelf = self;
    [[EasyTwitter sharedEasyTwitterClient] loadTimelineWithCount:100 completion:^(NSArray *data, NSError *error) {
        if (data != nil)
        {
            /*
            data represents an array with the top 100 home-timeline tweets and retweets.
            NB: The home-timeline is different from the user-timeline.
            https://dev.twitter.com/rest/reference/get/statuses/home_timeline
            https://dev.twitter.com/rest/reference/get/statuses/user_timeline
             
            Use NSLog(@"data: %@", data) to observe contents to determine which information
            to extract.
             
            example:
             
            cell.textLabel.text = data[row] objectForKey:@"text"];
            cell.detailTextLabel.text = [data[row] objectForKey:@"user"] objectForKey:@"""screen_name"""];
             
            */
            weakSelf.data = data;
            [weakSelf.table reloadData];
        }
    }];
}

#pragma mark Table View Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.data != nil)
        return [self.data count];
    else
        return 1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    
    NSInteger row = indexPath.row;
    /*
    data represents an array with the top 100 home-timeline tweets and retweets.
    NB: The home-timeline is different from the user-timeline.
    https://dev.twitter.com/rest/reference/get/statuses/home_timeline
    https://dev.twitter.com/rest/reference/get/statuses/user_timeline

    Use NSLog(@"data: %@", data) to observe contents to determine which information
    to extract.

    example:

    cell.textLabel.text = [self.data[row] objectForKey:@"text"];
    cell.detailTextLabel.text = [[self.data[row] objectForKey:@"user"] objectForKey:@"""screen_name"""];

    */
    cell.textLabel.text = [self.data[row] objectForKey:@"text"];
    cell.detailTextLabel.text = [[self.data[row] objectForKey:@"user"] objectForKey:@"""screen_name"""];
    return cell;
}

- (void)showLoadingScreen:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //Show Load Screen
        [self.loadScreen removeFromSuperview];
        self.loadScreen = [[DBCameraLoadingView alloc] initWithFrame:(CGRect){ 0, 0, 100, 100 }];
        [self.loadScreen setCenter:self.view.center];
        [self.view addSubview:self.loadScreen];
    });
}

- (void)hideLoadingScreen:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //Remove Load Screen
        [self.loadScreen removeFromSuperview];
        self.loadScreen = nil;
    });
}

- (void) dealloc
{
    [self.loadScreen removeFromSuperview];
    self.loadScreen = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
