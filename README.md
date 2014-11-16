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

### First Part
1. Add `Social.framework` to your project
2. Add `Accounts.famework` to your project
3. Drag the `EasySocial` folder into your project (Ensure you check `Copy items into destination group's folder`)
4. Open `<Your Project Name>-Prefix.pch` file in the `Supporting Files` Folder within XCode.
	- Add to the bottom:

```objective-c
//Now you do not need to include those headers anywhere else in your project.
#import "EasyFacebook.h"
#import "EasyTwitter.h"
```
### Second Part
1. [Download](https://developers.facebook.com/docs/ios/getting-started/#sdk) and [Add `FacebookSDK.framework`](https://developers.facebook.com/docs/ios/getting-started/#configure)into your project.
2. [Register your app with Facebook to get an App ID](https://developers.facebook.com/docs/ios/getting-started/#appid)
	- Ensure that the `Bundle ID` you give your app on XCode matches what you register with facebook
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

A Tweet is a (*max*) 140 character `message` that is propagated to other Twitter users via the *Twittersphere*. URL links can be embedded in the `message.` They are automatically detected and *minimized* to save characters. Images can also be attached. All images are uploaded to Twitter's servers.

```objective-c
//Plain Tweet
- (void)sendTweetWithMessage:(NSString *) message twitterResponse:(void(^)(id responseJSON, NSDictionary *JSONError, NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error))response failure:(void(^)(EasyTwitterIssues issue))failure
//Tweet with an image in *NSData format
- (void)sendTweetWithMessage:(NSString *) message image:(NSData *) image mimeType:(NSString *) mimeType requestShowLoadScreen:(BOOL) show twitterResponse:(void(^)(id responseJSON, NSDictionary *JSONError, NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error))response failure:(void(^)(EasyTwitterIssues issue))failure
//Tweet with an image referred to by a URL
- (void)sendTweetWithMessage:(NSString *) message imageURL:(NSURL *) imageURL twitterResponse:(void(^)(id responseJSON, NSDictionary *JSONError, NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error))response failure:(void(^)(EasyTwitterIssues issue))failure
```

`(NSString *) message` is the message to tweet.

`(NSData *) image` refers to an image. If you have a `UIImage` object, it must be converted to a `NSData` object by using [`UIImageJPEGRepresentation`](https://developer.apple.com/library/ios/documentation/uikit/reference/UIKitFunctionReference/index.html#//apple_ref/c/func/UIImageJPEGRepresentation) or [`UIImagePNGRepresentation.`](https://developer.apple.com/library/ios/documentation/uikit/reference/UIKitFunctionReference/index.html#//apple_ref/c/func/UIImagePNGRepresentation)

`(NSString *) mimeType` refers to the [Mime Type](http://en.wikipedia.org/wiki/Internet_media_type) of the image. It should be one of `image/png,` `image/jpeg,` or `image/gif.` If unspecified, `image/png` will be assumed.

`(NSURL *) imageURL` refers to the URL address of the image file. It's [Mime Type](http://en.wikipedia.org/wiki/Internet_media_type) will be guessed by the file's extension.

`(BOOL) show` is *private* argument. Always set it to `YES.`

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

A user's `home-timeline` represents the most recent tweets and retweets. It should be noted that the [`home-time`](https://dev.twitter.com/rest/reference/get/statuses/home_timeline)is different from the [`user-timeline.`](https://dev.twitter.com/rest/reference/get/statuses/user_timeline)

```objective-c
- (void)loadTimelineWithCount:(int) count completion:(void (^)(NSArray *data, NSError *error))completion;
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
* `sendTweetWithMessage: imageURL:twitterResponse:failure:`
* `sendTweetWithMessage:twitterResponse:failure:`
* `loadTimelineWithCount:completion:`

EasyFacebook
------------


