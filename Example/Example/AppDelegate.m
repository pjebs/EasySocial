//
//  AppDelegate.m
//  Example
//
//  Created by PJ on 14/11/14.
//
//
#import "AppDelegate.h"

@implementation AppDelegate

/*
 
In order to use this Example project, you must do a few things.

1) Download and Drop In the FacebookSDK.framework folder into the project
    https://developers.facebook.com/docs/ios/getting-started/

2) Setup your app credentials with Facebook Developer's 'Portal'.
    - You can create a temporary app and put in the details into the Example Project to make it work.
    - Get an App ID
    - Create a bundle id for the app (via XCode) and then register it in Facebook's Developer 'Portal'
    - Make sure you enable "Single Sign On" as mentioned in https://developers.facebook.com/docs/ios/getting-started/#appid
    - Configure the Example-Info.plist file (found under "Supporting Files" folder) in XCode left-hand side
        -Add key: FacebookAppID
        -Add key: FacebookDisplayName
        -Add array key: URL types
        -Instructions: https://developers.facebook.com/docs/ios/getting-started/#configurePlist
 
3) Example Project will now work!
 
4) Sharing on user's timeline requires Facebook to approve your app. This feature won't work in this Example project
   UNLESS you add your facebook account as a "Developer" in the Developer 'Portal'

*/


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    return YES;
}

//Add this in
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL wasHandled1 = [EasyFacebook handleOpenURL:url sourceApplication:sourceApplication];
//    BOOL wasHandled2 = [GPPURLHandler handleURL:url sourceApplication:sourceApplication annotation:annotation];
//    BOOL wasHandled3 = [TumblrAPI handleURL:url];
    
    return wasHandled1;
//    return (wasHandled1 || wasHandled2 || wasHandled3);
    
}

@end
