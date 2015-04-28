EasySocial iOS Library for Twitter and Facebook
=================================================

This library allows your apps to use Twitter and Facebook with minimal understanding of the relevant SDK.
It is super easy to use and elegantly designed. It will save you time.

Many other libraries are overly complicated and offer functionality that you do not need in your app.
The included Example Project demonstrates most of the features offered.

EasySocial does only these things:

### Twitter
* Send Plain Tweets
* Send Tweets with images (via a URL or UIImage/NSData)
* Get Data from user's timeline

### Facebook
* Full Facebook Connect (Log In/Log Out and Auto-Log In)
* Fetch User Information (objectID, name etc...)
* Share and Publish messages in user's timeline


Installation
-------------

### CocoaPods

pod 'EasySocial', '~> 1.0'

### First Part
1. Add `Social.framework` to your project
2. Add `Accounts.framework` to your project
3. Drag the `EasySocial` folder into your project (Ensure you check `Copy items into destination group's folder`)
4. Open `<Your Project Name>-Prefix.pch` file in the `Supporting Files` Folder within XCode. For XCode 6, you will need to create a `pch` file [from scratch](http://stackoverflow.com/questions/24158648/why-isnt-projectname-prefix-pch-created-automatically-in-xcode-6).
	- Add to the bottom:

```objective-c
//Now you do not need to include those headers anywhere else in your project.
#import "EasyFacebook.h"
#import "EasyTwitter.h"
```
### Second Part
1. [Download](https://developers.facebook.com/docs/ios/getting-started/#sdk) and [Add `FacebookSDK.framework`](https://developers.facebook.com/docs/ios/getting-started/#configure)into your project.
2. [Register your app with Facebook to get an App ID](https://developers.facebook.com/docs/ios/getting-started/#appid)
	- Ensure that the `Bundle ID` you give your app on XCode matches what you register with Facebook
	- Ensure that you enable `"Single Sign On"` in Facebook
	- [Configure](https://developers.facebook.com/docs/ios/getting-started/#configurePlist) the `<Your Project Name>-Info.plist` file by inserting `FacebookAppID`, `FacebookDisplayName` and `URL types` keys
	- Register your own facebook account as a `Developer` account. That way you can test your app while you are developing it. In production, Facebook must approve your app to use some features
3. In your project's `AppDelegate.m` file, include:

```objective-c
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL wasHandled1 = [EasyFacebook handleOpenURL:url sourceApplication:sourceApplication];
//  BOOL wasHandled2 = [GPPURLHandler handleURL:url sourceApplication:sourceApplication annotation:annotation];
//  BOOL wasHandled3 = [TumblrAPI handleURL:url];
    
    return wasHandled1;
//  return (wasHandled1 || wasHandled2 || wasHandled3);
    
}
```

EasyTwitter
------------

### Methods

Before you can use EasyTwitter, you must instantiate the `EasyTwitter` class.

```objective-c
+ (EasyTwitter *)sharedEasyTwitterClient
```

The class is a singleton class meaning only one is **ever** created. In practice, the class is automatically instantiated without any action on your part. You can use the class by typing: `[EasyTwitter sharedEasyTwitterClient].XXX` or `[[EasyTwitter sharedEasyTwitterClient] XXX].`

### Methods - Requesting Permission & Setting Account

Before your app can use Twitter, the user must grant permission to your app.

```objective-c
- (void)requestPermissionForAppToUseTwitterSuccess:(void(^)(BOOL granted, BOOL accountsFound, NSArray *accounts))success failure:(void(^)(NSError *error))failure
```

`BOOL granted` will indicate if the user granted permission. If the user does not grant permission, they must go to the iOS built-in `Settings` App -> `Privacy` -> `Twitter` to grant permission in the future.

`BOOL accountsFound` will indicate if any system-stored Twitter Accounts were found (provided `granted==YES`). If none were found, remind the user to save their Twitter credentials in `Settings` App -> `Twitter`.

`NSArray *accounts` will contain `ACAccount` objects. These represent the Twitter accounts found. You can search through all the `ACAccount` objects to select the desired Twitter account to send tweets from.

* `ACAccount` contains two properties that are useful:
	- **.username** (Type:string i.e *finkd*)
	- **.accountDescription** (Type:string i.e. *@finkd*)

Once you discover the required account, set it.

```objective-c
//In practice, set it to the required account. This is the default setting automatically set.
[EasyTwitter sharedEasyTwitterClient].account = [accounts firstObject];
```
### Methods - Sending Tweets

A Tweet is a (*max*) 140 character `message` that is propagated to other Twitter users via the *Twittersphere*. URL links can be embedded in the `message.` They are automatically detected and *minified* to save characters. Images can also be attached. All images are uploaded to Twitter's servers.

```objective-c
//Plain Tweet
- (void)sendTweetWithMessage:(NSString *) message twitterResponse:(void(^)(id responseJSON, NSDictionary *JSONError, NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error))response failure:(void(^)(EasyTwitterIssues issue))failure
//Tweet with an image in *NSData format
- (void)sendTweetWithMessage:(NSString *) message image:(NSData *) image mimeType:(NSString *) mimeType requestShowLoadScreen:(BOOL) show twitterResponse:(void(^)(id responseJSON, NSDictionary *JSONError, NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error))response failure:(void(^)(EasyTwitterIssues issue))failure
//Tweet with an image referred to by a URL
- (void)sendTweetWithMessage:(NSString *) message imageURL:(NSURL *) imageURL twitterResponse:(void(^)(id responseJSON, NSDictionary *JSONError, NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error))response failure:(void(^)(EasyTwitterIssues issue))failure
```

`(NSString *) message` is the message to tweet.

`(NSData *) image` refers to an image. If you have a `UIImage` object, it must be converted to a `NSData` object by using [`UIImageJPEGRepresentation()`](https://developer.apple.com/library/ios/documentation/uikit/reference/UIKitFunctionReference/index.html#//apple_ref/c/func/UIImageJPEGRepresentation) or [`UIImagePNGRepresentation().`](https://developer.apple.com/library/ios/documentation/uikit/reference/UIKitFunctionReference/index.html#//apple_ref/c/func/UIImagePNGRepresentation)

`(NSString *) mimeType` refers to the [Mime Type](http://en.wikipedia.org/wiki/Internet_media_type) of the image. It should be one of `image/png,` `image/jpeg,` or `image/gif.` If unspecified, `image/png` will be assumed.

`(NSURL *) imageURL` refers to the URL address of the image file. It's [Mime Type](http://en.wikipedia.org/wiki/Internet_media_type) will be guessed by the file's extension.

`(BOOL) show` is a *private* argument. Always set it to `YES.`

`NSDictionary *JSONError` is part of the response back from [Twitter's REST API](https://dev.twitter.com/rest/reference/post/statuses/update). If `JSONError == nil,` the tweet was posted successfully. If it is not `nil,`there was an issue.

The issue can be determined by reading the [**error code**](https://dev.twitter.com/overview/api/response-codes) and **error message**.

```objective-c
//pseudo code
int errorCode = [[JSONError objectForKey:@"code"] intValue]; //JSON error code as opposed to HTTP error code
NSString *errorMessage = [JSONError objectForKey:@"message"];
```

[Common Error Codes](https://dev.twitter.com/overview/api/response-codes):

* **187** indicates a duplicate tweet.
* **186** indicates the tweet was too long (over 140 characters).

`EasyTwitterIssues issue` is returned by the `failure` block. It represents an error before [Twitter's REST API](https://dev.twitter.com/rest/reference/post/statuses/update) is even called. 

If `issue == EasyTwitterNoAccountSet,` it means that you attempted to send a tweet without setting a Twitter account.


### Methods - Timeline

A user's `home-timeline` represents the most recent tweets and retweets. It should be noted that the [`home-timeline`](https://dev.twitter.com/rest/reference/get/statuses/home_timeline)is different from the [`user-timeline.`](https://dev.twitter.com/rest/reference/get/statuses/user_timeline)

```objective-c
- (void)loadTimelineWithCount:(int) count completion:(void (^)(NSArray *data, NSError *error))completion
```

`(int) count` refers to how many recent items from the home-timeline you want returned. The maximum is 200.

`NSArray *data` will contain `NSDictionary` objects which represent an item from the timeline. The most recent item is at`index==0.`During development, you can observe the contents of each item using: `NSLog(@"data: %@", data)`

Finally you can extract the desired data like this:

```objective-c
//pseudo code
cell.textLabel.text = [data[row] objectForKey:@"text"]; //Main contents of item
cell.detailTextLabel.text = [[data[row] objectForKey:@"user"] objectForKey:@"""screen_name"""]; //Screen name of owner of item
```

### Notifications

`EasyTwitterPermissionGrantedNotification` - Posted when the user grants permission to access system-stored Twitter accounts. It does not imply that any twitter accounts were found.

`EasyTwitterAccountSetNotification` - Posted when you set an`ACAccount`object as the Twitter account to tweet from. This notification is also posted when the default Twitter account is set automatically (without any action on your part).

`EasyTwitterTweetSentNotification` - Posted when a tweet was successfully sent. It is usually more useful to monitor the `NSDictionary *JSONError` argument in the `response` callback block of the `sendTweetWithMessage:` methods. A `nil` error response indicates a successful tweet.

### EasyTwitterDelegate

Both methods prescribed in the protocol are `optional.` You will have to set the `delegate` property appropriately to subscribe to the protocol. It may be useful to implement them as demonstrated in the accompanying`Example Project.` 

`showLoadingScreen:` is called **before** a potentially time-consuming activity begins.
`hideLoadingScreen:` is called **after** a time-consuming activity finishes.

It is expected that you show the user that background activity is occurring via a UI element.

The delegate methods are called before and after:

* `requestPermissionForAppToUseTwitterSuccess:failure:`
* `sendTweetWithMessage:image:mimeType:requestShowLoadScreen:twitterResponse:failure:`
* `sendTweetWithMessage:imageURL:twitterResponse:failure:`
* `sendTweetWithMessage:twitterResponse:failure:`
* `loadTimelineWithCount:completion:`

EasyFacebook
------------

### Methods

Before you can use EasyFacebook, you must instantiate the `EasyFacebook` class.

```objective-c
+ (EasyFacebook *)sharedEasyFacebookClient
```

The class is a singleton class meaning only one is **ever** created. In practice, the class is automatically instantiated without any action on your part. You can use the class by typing: `[EasyFacebook sharedEasyFacebookClient].XXX` or `[[EasyFacebook sharedEasyFacebookClient] XXX].`

### Methods - Log in & Log out

Before you can interact with the FacebookSDK, you must have a logged in user.

```objective-c
- (void)openSession  //For logging in
- (void)closeSession //For logging out
- (BOOL)isLoggedIn   //For checking logged in status
```

By calling the `openSession` method, the user will undergo the standard logging in process. This usually involves opening up the official Facebook app (if installed). Otherwise Safari browser will be opened instead. The user will be asked to grant permission to your app to access their details. Once approved, any future calls to `openSession` will briefly open up the Facebook app but will almost immediately transfer back to your app - since the user had already granted approval in the past (provided the approval is not later revoked).

The `closeSession` method will immediately log out the user.

The `(BOOL)isLoggedIn` method will return whether the user is currently logged in or out.

If the user logs in and later exits your app, a cached token will usually be saved locally. When your app is opened again, the user will usually not have to log in again. This is part of the **Auto-Log In** feature.

For security reasons, if you want to turn off **Auto-Log In** behaviour, you can listen to [UIApplicationWillTerminateNotification](https://developer.apple.com/Library/ios/documentation/UIKit/Reference/UIApplication_Class/index.html#//apple_ref/c/data/UIApplicationWillTerminateNotification) and call `closeSession` to log out the user.

When the user is being logged in, the FacebookSDK requires the initial permissions requested.
The default permissions are:

* [`public_profile`](https://developers.facebook.com/docs/facebook-login/permissions/v2.2#reference-public_profile)
* [`email`](https://developers.facebook.com/docs/facebook-login/permissions/v2.2#reference-email)
* [`user_friends`](https://developers.facebook.com/docs/facebook-login/permissions/v2.2#reference-user_friends)

If you want to modify the permissions requested, **before** calling `openSession` you can set `readPermissions:`

```objective-c
//Set the readPermissions to what ever you want
[EasyFacebook sharedEasyFacebookClient].readPermissions = @[@"public_profile", @"email", @"user_friends"];
```

Read the `Notifications` section below if you want to what know state changes are available to you.

### Methods - Fetching basic user information

After the user logs in, a call to fetch the user's basic information is automatically done. However, if you want the latest information on demand then call this method.

```objective-c
- (void)fetchUserInformation
```
Once the information arrives, the `EasyFacebookUserInfoFetchedNotification` notification is posted. Once posted, you can extract the latest details using these properties:

* [`@property NSString *UserEmail`](https://developers.facebook.com/docs/facebook-login/permissions/v2.2#reference-email) - Only available if `email` permission is requested. By default, it is requested.
* [`@property NSString *UserFirstName`](https://developers.facebook.com/docs/facebook-login/permissions/v2.2#reference)
* [`@property NSString *UserGender`](https://developers.facebook.com/docs/facebook-login/permissions/v2.2#reference)
* [`@property NSString *UserObjectID`](https://developers.facebook.com/docs/facebook-login/permissions/v2.2#reference) - usually referred to as `id` (unique to the user - store in databases)
* [`@property NSString *UserLastName`](https://developers.facebook.com/docs/facebook-login/permissions/v2.2#reference)
* [`@property NSString *UserLink`](https://developers.facebook.com/docs/facebook-login/permissions/v2.2#reference)
* [`@property NSString *UserLocale`](https://developers.facebook.com/docs/facebook-login/permissions/v2.2#reference)
* [`@property NSString *UserName`](https://developers.facebook.com/docs/facebook-login/permissions/v2.2#reference)
* [`@property NSString *UserTimeZone`](https://developers.facebook.com/docs/facebook-login/permissions/v2.2#reference)
* [`@property NSString *UserVerified`](https://developers.facebook.com/docs/facebook-login/permissions/v2.2#reference)

### Methods - Publishing Rights

Publishing to the timeline requires the [`publish_actions`](https://developers.facebook.com/docs/facebook-login/permissions/v2.2#reference-publish_actions) permission. You will also require Facebook approval once your app is ready to go to production.

```objective-c
- (BOOL)isPublishPermissionsAvailableQuickCheck
- (void)isPublishPermissionsAvailableFullCheck:(void(^)(BOOL result, NSError *error))responseHandler
- (void)requestPublishPermissions:(void(^)(BOOL granted, NSError *error))responseHandler
```

`(BOOL)isPublishPermissionsAvailableQuickCheck` checks if [`publish_actions`](https://developers.facebook.com/docs/facebook-login/permissions/v2.2#reference-publish_actions) permission is granted to the current `access token.` It is 99% accurate since the permissions granted could have changed since the `access token` was issued. The permissions could also be changed by the user *via* the Facebook website external to your app. The method will immediately return however since it does not make any REST API calls.

`(void)isPublishPermissionsAvailableFullCheck` will perform a 100% accurate check for [`publish_actions`](https://developers.facebook.com/docs/facebook-login/permissions/v2.2#reference-publish_actions) permission. It will make a REST API call and will return with a `BOOL result` response. If `result==YES,` then publishing permission is available.

If publishing permission is not available, you will have to request it by calling `(void)requestPublishPermissions` method. A response where `granted==YES` will indicate that the user has granted permission.

### Methods - Publishing Content

To publish and share content, [`publish_actions`](https://developers.facebook.com/docs/facebook-login/permissions/v2.2#reference-publish_actions) permission is required. By calling the `publishStoryWithParams:completion:` method below, it automatically also calls the `requestPublishPermissions:` method.

```objective-c
- (void)publishStoryWithParams:(NSDictionary *)params completion:(void(^)(BOOL success, NSError *error))completion
```

`(NSDictionary *)params` can have [these parameters](https://developers.facebook.com/docs/ios/share#link):

* [link](https://developers.facebook.com/docs/reference/ios/current/class/FBLinkShareParams#link) - the url we want to share
* [name](https://developers.facebook.com/docs/reference/ios/current/class/FBLinkShareParams#name) - a title
* [caption](https://developers.facebook.com/docs/reference/ios/current/class/FBLinkShareParams#caption) - a subtitle
* [picture](https://developers.facebook.com/docs/reference/ios/current/class/FBLinkShareParams#picture) - the url of a thumbnail to associate with the post
* [description](https://developers.facebook.com/docs/reference/ios/current/class/FBLinkShareParams#linkDescription) - a snippet of text describing the content of the link
* message - main message appears above everything else

`BOOL success` will be the response in the `completion` block. If `success==YES,` the share post was successful.

As an example:

```objective-c
NSDictionary *params = @{@"link" : @"http://www.google.com",
                         @"name" : @"Google",
                         @"caption" : @"#1 search engine",
                         @"picture" : @"https://www.google.com/images/srpr/logo11w.png",
                         @"description" : @"Home page Logo",
                         @"message" : @"hello"
                        };
```
The output will be:

![Screen shot of a sample Share Post](https://raw.github.com/pjebs/EasySocial/master/share_post.png)

### Notifications

`EasyFacebookLoggedInNotification` - Posted when the user successfully logs in. The notification is also posted after an auto-log in.

`EasyFacebookLoggedOutNotification` - Posted when the user logs out intentionally or due to unexpected reasons.

`EasyFacebookUserInfoFetchedNotification` - Posted when the user's basic information becomes available. This will happen automatically shortly after the user logs in, or after `fetchUserInformation` method is explicitly called. See above for information on what basic information is available.

`EasyFacebookUserCancelledLoginNotification` - Posted when the user is given the opportunity to log in but decides to cancel the process. The user is usually taken outside the app to the official Facebook app to log in. If the app is not installed, Safari browser is opened with the log in dialog shown via a website.

`EasyFacebookPublishPermissionGrantedNotification` - Posted when the user grants permission for the app to publish on their timeline.

`EasyFacebookPublishPermissionDeclinedNotification` - Posted when the user declines to grant permission for the app to publish on their timeline.

`EasyFacebookStoryPublishedNotification` - Posted when the share attempt is successfully published on the user's timeline.

### EasyFacebookDelegate

Both methods prescribed in the protocol are `optional.` You will have to set the `delegate` property appropriately to subscribe to the protocol. It may be useful to implement them as demonstrated in the accompanying`Example Project.` 

`showLoadingScreen:` is called **before** a potentially time-consuming activity begins.
`hideLoadingScreen:` is called **after** a time-consuming activity finishes.

It is expected that you show the user that background activity is occurring via a UI element.

The delegate methods are called before and after:

* `publishStoryWithParams:completion:`

### Diagnostics

`@property BOOL preventAppShutDown` - iOS 8 incorporates a different Memory Management Policy. If you find that your app is getting shut down by iOS after the user is taken to the Facebook app as part of the log in process, then set this property to `YES.`

`@property BOOL facebookLoggingBehaviourOn` - For diagnostic purposes, if you want the FacebookSDK to log full details (in the debug window) on what it is doing behind the scenes, then set this property to `YES.`


Final Notes
------------

If you found this library useful, please **Star** it on github. Feel free to fork or provide pull requests. Any bug reports will be warmly received.

