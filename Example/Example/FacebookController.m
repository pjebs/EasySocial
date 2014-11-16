//
//  FacebookController.m
//  Example
//
//  Created by PJ on 14/11/14.
//
//

#import "FacebookController.h"

@interface FacebookController ()
    -(IBAction)login:(id)sender;

    @property (weak) IBOutlet UIButton * login;
    @property (strong) UIView * loadScreen;
@end

@implementation FacebookController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Facebook Example";
    
    //Observe when user's basic information has been fetched.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayUserInformation)
                                                 name:EasyFacebookUserInfoFetchedNotification object:nil];
    //Observe when the user has logged out. Sometimes it can be unexpected and not due to an action within
    //your app.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookLoggedOutUnexpectedly)
                                                 name:EasyFacebookLoggedOutNotification object:nil];
    //Observe when the user has logged in. This can sometimes be due to auto-login when you app starts up.
    //i.e. if the user didn't log out after the previous time they used your app and logged in.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookLoggedIn)
                                                 name:EasyFacebookLoggedInNotification object:nil];
    
    [self updateUI];
    
    [EasyFacebook sharedEasyFacebookClient].delegate = self;
}

-(IBAction)login:(id)sender
{
    if ([[EasyFacebook sharedEasyFacebookClient] isLoggedIn])
    {
        //Currently logged in so let's log out.
        [[EasyFacebook sharedEasyFacebookClient] closeSession];
    }
    else
    {
        //Currently logged out so let's log in.
        [[EasyFacebook sharedEasyFacebookClient] openSession];
    }
}

- (void) updateUI
{
    if ([[EasyFacebook sharedEasyFacebookClient] isLoggedIn])
        [self.login setTitle:@"Log Out" forState:UIControlStateNormal];
    else
        [self.login setTitle:@"Log In" forState:UIControlStateNormal];
}

- (void) facebookLoggedOutUnexpectedly
{
    [self updateUI];
}

- (void) facebookLoggedIn
{
    
    [self updateUI];
}


- (void) displayUserInformation
{
    EasyFacebook *ef = [EasyFacebook sharedEasyFacebookClient];
    
    NSString *message = [[NSString alloc] initWithFormat:
                         @"Name: %@ \n Object ID: %@ \n Gender: %@ \n Link: %@ \n TimeZone: %@ \n", ef.UserName, ef.UserObjectID, ef.UserGender, ef.UserLink, ef.UserTimeZone];

    //User Information has been fetched
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"User Information"
                                                    message:message
                                                   delegate:self cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}


-(IBAction)getUserInformation:(id)sender
{
    if (![[EasyFacebook sharedEasyFacebookClient] isLoggedIn])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"EasySocial"
                                                        message:@"Please log on first"
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    /*
    Use this method to fetch most recent information. However, when the user logs on,
    this method is automatically called, so it is usually not necessary.
    
    We can observe Notification: EasyFacebookUserInfoFetchedNotification to know when
    the user information arrives. See [self displayUserInformation] above to see 
    how to view the user's basic information.
    */
    [[EasyFacebook sharedEasyFacebookClient] fetchUserInformation];
    
}


-(IBAction)publishStory:(id)sender
{
    if (![[EasyFacebook sharedEasyFacebookClient] isLoggedIn])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"EasySocial"
                                                        message:@"Please log on first"
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
        
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Share"
                                                    message:[NSString stringWithFormat:@"Write a message to timeline. A Google logo will also be added."]
                                                   delegate:self cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    alert.tag = 1;
    [alert show];
    
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alert.tag != 1)
        return;
    
    NSString *message = [[alert textFieldAtIndex:0] text];
    

    /*
    We can post to the user's timeline.
    */
    
    NSDictionary *params = @{@"link" : @"http://www.google.com",
                             @"name" : @"Google",
                             @"caption" : @"#1 search engine",
                             @"picture" : @"https://www.google.com/images/srpr/logo11w.png",
                             @"description" : @"Home page Logo",
                             @"message" : message
                             };
    
    [[EasyFacebook sharedEasyFacebookClient] publishStoryWithParams:params completion:^(BOOL success, NSError *error) {
        if (success == YES)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"EasySocial"
                                                            message:@"Published to User's timeline"
                                                           delegate:self cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
            
    }];
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
