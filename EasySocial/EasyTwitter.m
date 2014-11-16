
#import "EasyTwitter.h"

@interface EasyTwitter ()
    
@end


@implementation EasyTwitter

+ (void)load
{
    [EasyTwitter sharedEasyTwitterClient];
}

- (void) setAccount:(ACAccount *)account
{
    if (_account != account)
    {
        _account = account;
        if (_account != nil)
            [[NSNotificationCenter defaultCenter] postNotificationName:EasyTwitterAccountSetNotification object:self];
    }
}

+ (EasyTwitter *)sharedEasyTwitterClient
{
    static EasyTwitter *_sharedEasyTwitterClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedEasyTwitterClient = [[self alloc] init];
    });
    
    return _sharedEasyTwitterClient;
}

- (void)requestPermissionForAppToUseTwitterSuccess:(void(^)(BOOL granted, BOOL accountsFound, NSArray *accounts))success failure:(void(^)(NSError *error))failure
{
    if ([self.delegate respondsToSelector:@selector(showLoadingScreen:)])
        [self.delegate showLoadingScreen:self];
    
    __weak typeof(self) weakSelf = self;
    
    ACAccountStore *account = [[ACAccountStore alloc] init]; //Ask for access to system accounts
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
     {
         if (error != nil)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (failure != nil)
                     failure(error);
                 
                 if ([weakSelf.delegate respondsToSelector:@selector(hideLoadingScreen:)])
                     [weakSelf.delegate hideLoadingScreen:weakSelf];
             });
             return;
         }
         
         if (granted == YES)
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:EasyTwitterPermissionGrantedNotification object:self];
             
             //Twitter granted
             NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
             if ((arrayOfAccounts == nil) || ([arrayOfAccounts count] == 0))
             {
                 //No twitter accounts
                 weakSelf.account = nil;
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (success != nil)
                         success(YES, NO, nil);
                 });
                 
             }
             else
             {
                 //Twitter accounts found
                 weakSelf.account = [arrayOfAccounts firstObject]; //Set first account as default
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (success != nil)
                         success(YES, YES, arrayOfAccounts);
                 });
             }
         }
         else
         {
             //Twitter not granted
             weakSelf.account = nil;
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (success != nil)
                     success(NO, NO, nil);
             });
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
             if ([weakSelf.delegate respondsToSelector:@selector(hideLoadingScreen:)])
                 [weakSelf.delegate hideLoadingScreen:weakSelf];
         });
         
     }];
    
}

- (void)sendTweetWithMessage:(NSString *) message twitterResponse:(void(^)(id responseJSON, NSDictionary *JSONError, NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error))response failure:(void(^)(EasyTwitterIssues issue))failure
{
    if ([self.delegate respondsToSelector:@selector(showLoadingScreen:)])
        [self.delegate showLoadingScreen:self];
    
    [self sendTweetWithMessage:message image:nil mimeType:nil requestShowLoadScreen:NO twitterResponse:response failure:failure];
}

- (void)sendTweetWithMessage:(NSString *) message imageURL:(NSURL *) imageURL twitterResponse:(void(^)(id responseJSON, NSDictionary *JSONError, NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error))response failure:(void(^)(EasyTwitterIssues issue))failure
{
    if ([self.delegate respondsToSelector:@selector(showLoadingScreen:)])
        [self.delegate showLoadingScreen:self];
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(concurrentQueue, ^{
        
        __block NSData *imageData = nil;
        
        dispatch_sync(concurrentQueue, ^{
            //Download image here
            imageData = [NSData dataWithContentsOfURL:imageURL];
        });
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSString *ext = [imageURL pathExtension];
            NSString *mimeType;
            
            if ([ext isEqualToString:@"png"] == YES)
                mimeType = @"image/png";
            else if (([ext isEqualToString:@"jpg"]) || ([ext isEqualToString:@"jpeg"]) == YES)
                mimeType = @"image/jpeg";
            else if ([ext isEqualToString:@"gif"] == YES)
                mimeType = @"image/gif";
            else
                mimeType = @"image/png";
            
            [weakSelf sendTweetWithMessage:message image:imageData mimeType:mimeType requestShowLoadScreen:NO twitterResponse:response failure:failure];
        });
    
    });
}

- (void)sendTweetWithMessage:(NSString *) message image:(NSData *) image mimeType:(NSString *) mimeType requestShowLoadScreen:(BOOL) show twitterResponse:(void(^)(id responseJSON, NSDictionary *JSONError, NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error))response failure:(void(^)(EasyTwitterIssues issue))failure
{
    if (show)
        if ([self.delegate respondsToSelector:@selector(showLoadingScreen:)])
            [self.delegate showLoadingScreen:self];
    
    if (self.account == nil) //No account is set
    {
        if (failure != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(EasyTwitterNoAccountSet);
            });
        }
        
        if ([self.delegate respondsToSelector:@selector(hideLoadingScreen:)])
            [self.delegate hideLoadingScreen:self];
        
        return;
    }
    
    NSDictionary *tweet = @{@"status": [[NSString alloc] initWithFormat:@"%@", message], @"wrap_links": @"true"};
    
    BOOL uploadMedia = NO;
    
    NSString *ext;
    if (image != nil)
    {
        uploadMedia = YES;
        
        if ((mimeType == nil) || [mimeType isEqualToString:@""])
            mimeType = @"image/png";
        
        if ([mimeType isEqualToString:@"image/png"])
            ext = @"png";
        else if ([mimeType isEqualToString:@"image/jpeg"])
            ext = @"jpg";
        else if ([mimeType isEqualToString:@"image/gif"])
            ext = @"gif";
        else
            ext = @"png";
    }
    
    NSURL *requestURL = (uploadMedia) ? [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update_with_media.json"] :
    [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
    
    SLRequest *postRequest = [SLRequest
                              requestForServiceType:SLServiceTypeTwitter
                              requestMethod:SLRequestMethodPOST
                              URL:requestURL parameters:tweet];
    
    if (uploadMedia) //Name:media or media[]??
        [postRequest addMultipartData:image withName:@"media" type:mimeType filename:[[NSString alloc] initWithFormat:@"image.%@",ext]];
    
    postRequest.account = self.account;

    __weak typeof(self) weakSelf = self;
    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
     {
         if ([urlResponse statusCode] == 200)
             [[NSNotificationCenter defaultCenter] postNotificationName:EasyTwitterTweetSentNotification object:self];
         
         if (response != nil)
         {
             id jsonResponse = nil;
             if (responseData != nil)
                 jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
             
             id jsonError;
             if (([urlResponse statusCode] == 403) || ([urlResponse statusCode] == 401))
                 jsonError = [[jsonResponse objectForKey:@"errors"] firstObject];

             dispatch_async(dispatch_get_main_queue(), ^{
                 response(jsonResponse, jsonError, responseData, urlResponse, error);
             });
         }
//             NSString *json = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//             NSLog(@"Twitter HTTP response: %i", (int)[urlResponse statusCode]);
//             NSLog(@"Twitter json response: %@", json);
         
         dispatch_async(dispatch_get_main_queue(), ^{
             if ([weakSelf.delegate respondsToSelector:@selector(hideLoadingScreen:)])
                 [weakSelf.delegate hideLoadingScreen:weakSelf];
         });
     }];
    
}

- (void)loadTimelineWithCount:(int) count completion:(void (^)(NSArray *data, NSError *error))completion
{
    if ([self.delegate respondsToSelector:@selector(showLoadingScreen:)])
        [self.delegate showLoadingScreen:self];
    
    NSString *url = [[NSString alloc] initWithFormat:@"https://api.twitter.com/1.1/statuses/home_timeline.json?count=%d", count];
    
    NSURL *requestURL = [NSURL URLWithString:url];
    SLRequest *request = [SLRequest
                              requestForServiceType:SLServiceTypeTwitter
                              requestMethod:SLRequestMethodGET
                              URL:requestURL parameters:nil];
    
    
    [request setAccount:self.account];
    __weak typeof(self) weakSelf = self;
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error == nil)
        {
//            NSLog(@"data %@:", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
            
            if ([urlResponse statusCode] == 200)
            {
                NSError *jsonError = nil;
                id jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&jsonError];
                
                if ([jsonResponse isKindOfClass:[NSArray class]])
                {
                    if (completion != nil)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(jsonResponse, nil);
                        });
                    }
                    
                }
                else
                {
                    //Error - json response is unexpected format
                    NSError *error = [NSError errorWithDomain:EasyTwitterClientErrorDomain
                                                         code:9999
                                                     userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Unexpected response received from Twitter API.", nil)}];
                    
                    if (completion != nil)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(nil, error);
                        });
                    }
                }
            }
            else
            {
                //Status code != 200 - indicates something is wrong
                
                if (completion != nil)
                {
                    NSError *error = [NSError errorWithDomain:EasyTwitterClientErrorDomain
                                                         code:[urlResponse statusCode]
                                                     userInfo:@{NSLocalizedDescriptionKey:[NSHTTPURLResponse localizedStringForStatusCode:[urlResponse statusCode]]}];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil, error);
                    });
                }
                
            }

        }
        else
        {
            if (completion != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, error);
                });
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.delegate respondsToSelector:@selector(hideLoadingScreen:)])
                [weakSelf.delegate hideLoadingScreen:weakSelf];
        });
    }];
    
}



@end