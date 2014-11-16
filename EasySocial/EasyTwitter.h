#import <Social/Social.h>
#import <Accounts/Accounts.h>

@protocol EasyTwitterDelegate;

//Twitter error codes can be found here: https://dev.twitter.com/overview/api/response-codes
//JSON error code 187 - Tweet is duplicate
//JSON error code 186 - Tweet is too long (over 140 characters)


static NSString *EasyTwitterClientErrorDomain = @"EasyTwitterClientErrorDomain";

static NSString *EasyTwitterPermissionGrantedNotification = @"EasyTwitterPermissionGrantedNotification";
static NSString *EasyTwitterAccountSetNotification = @"EasyTwitterAccountSetNotification";
static NSString *EasyTwitterTweetSentNotification = @"EasyTwitterTweetSentNotification";

typedef enum {
    EasyTwitterNoAccountsFound = 1,
    EasyTwitterPermissionNotGranted = 2,
    EasyTwitterNoAccountSet = 3,
    EasyTwitterUnknown = 99,
} EasyTwitterIssues;

@interface EasyTwitter : NSObject

    + (EasyTwitter *)sharedEasyTwitterClient;

    /* SET UP DESIRED TWITTER ACCOUNT
     
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
    - (void)requestPermissionForAppToUseTwitterSuccess:(void(^)(BOOL granted, BOOL accountsFound, NSArray *accounts))success failure:(void(^)(NSError *error))failure;

    /* SEND TWEET
    
    NB: If there is a url embedded in the message, it will be detected and 'wrapped'.
    sendTweetWithMessage: - Sends an ordinary tweet
    sendTweetWithMessage:imageURL: - Sends a tweet with an accompanying image (via a image url)
    sendTweetWithMessage:image:mimeType: - Sends a tweet with an accompanying image (*NSData)
     
    NB: All images are saved in Twitter servers.
    
    */
    - (void)sendTweetWithMessage:(NSString *) message image:(NSData *) image mimeType:(NSString *) mimeType requestShowLoadScreen:(BOOL) show twitterResponse:(void(^)(id responseJSON, NSDictionary *JSONError, NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error))response failure:(void(^)(EasyTwitterIssues issue))failure;
    - (void)sendTweetWithMessage:(NSString *) message imageURL:(NSURL *) imageURL twitterResponse:(void(^)(id responseJSON, NSDictionary *JSONError, NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error))response failure:(void(^)(EasyTwitterIssues issue))failure;
    - (void)sendTweetWithMessage:(NSString *) message twitterResponse:(void(^)(id responseJSON, NSDictionary *JSONError, NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error))response failure:(void(^)(EasyTwitterIssues issue))failure;

    /* LOAD TIMELINE
     
    data represents an array with the top (count=100) home-timeline tweets and retweets.
    NB: The home-timeline is different from the user-timeline.
    https://dev.twitter.com/rest/reference/get/statuses/home_timeline
    https://dev.twitter.com/rest/reference/get/statuses/user_timeline

    Use NSLog(@"data: %@", data) to observe contents to determine which information
    to extract.

    example:

    cell.textLabel.text = [data[row] objectForKey:@"text"];
    cell.detailTextLabel.text = [[data[row] objectForKey:@"user"] objectForKey:@"""screen_name"""];

    */
    - (void)loadTimelineWithCount:(int) count completion:(void (^)(NSArray *data, NSError *error))completion;

    @property (nonatomic, weak) id<EasyTwitterDelegate>delegate;
    @property (nonatomic, strong) ACAccount *account;

@end



@protocol EasyTwitterDelegate <NSObject>
@optional
    - (void)showLoadingScreen:(id)sender;
    - (void)hideLoadingScreen:(id)sender;
@end

