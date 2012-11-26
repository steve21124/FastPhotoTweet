//
//  TWGetTimeline.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

#import "TWGetTimeline.h"

#define BLANK @""
#define API_VERSION @"1"

@implementation TWGetTimeline

+ (void)homeTimeline {

    @try {
        
        ACAccount *requestAccount = [TWAccounts currentAccount];
        
        //アカウントの取得
        NSLog(@"Get HomeTimeline: %@", requestAccount.username);
        
        //Twitterアカウントの確認
        if ( requestAccount == nil ) {
            
            //アカウントデータが空
            [ShowAlert error:@"アカウントが取得できませんでした。"];
            
            return;
        }
        
        //インターネット接続を確認
        if ( ![InternetConnection enable] ) return;
        
        [ActivityIndicator on];
        
        //タイムライン取得リクエストURL作成
        NSString *urlString = [[NSString alloc] initWithFormat:@"https://api.twitter.com/%@/statuses/home_timeline.json", API_VERSION];
        NSURL *reqUrl = [[NSURL alloc] initWithString:urlString];
        
        //リクエストパラメータを作成
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        //取得数
        [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"TimelineLoadCount"] forKey:@"count"];
        //エンティティの有効化
        [params setObject:@"1" forKey:@"include_entities"];
        //RT表示
        [params setObject:@"1" forKey:@"include_rts"];
        
        //差分取得
        if ( [[TWTweets topTweetID] isNotEmpty] ) {
            
            NSLog(@"Since: %@", [TWTweets topTweetID]);
            [params setObject:[TWTweets topTweetID] forKey:@"since_id"];
        }
        
        //リクエストを作成
        TWRequest *request = [[TWRequest alloc] initWithURL:reqUrl
                                                 parameters:params
                                              requestMethod:TWRequestMethodGET];
        
        //リクエストにアカウントを設定
        [request setAccount:requestAccount];
        
        //Timeline取得結果通知を作成
        NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
        [result setObject:@"Timeline" forKey:@"Type"];
        
        NSNotification *notification =[NSNotification notificationWithName:@"GetTimeline"
                                                                    object:self
                                                                  userInfo:result];
        
        //        NSLog(@"\nrequest:\n  URL: %@\n  UserName: %@\n  Parameters: %@", request.URL, request.account, request.parameters);
        
        [request performRequestWithHandler:
         ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
             
             NSLog(@"HomeTimeline receive response");
             
             if ( responseData ) {
                  
                 NSError *jsonError = nil;
                 NSMutableArray *timeline =
                 [NSMutableArray arrayWithArray:
                  [NSJSONSerialization JSONObjectWithData:responseData
                                                  options:NSJSONReadingMutableLeaves
                                                    error:&jsonError]];
                 
                 [result setObject:requestAccount.username forKey:@"Account"];
                 
                 //NSLog(@"timeline: %@", timeline);
                 
                 if ( timeline != nil ) {
                     
                     //t.coを全て展開する
                     timeline = [TWEntities replaceTcoAll:timeline];
                     timeline = [TWNgTweet ngAll:timeline];
                     
                     //取得完了を通知
                     [result setObject:@"TimelineSuccess" forKey:@"Result"];
                     [result setObject:timeline forKey:@"Timeline"];
                     
                 }else {
                     
                     [result setObject:@"TimelineError" forKey:@"Result"];
                     [NSNotificationCenter postNotificationCenterForName:@"GrayViewEnd"];
                 }
                 
                 //NSLog(@"Get HomeTimeline done");
                 
                 if ( [requestAccount.username isEqualToString:[TWAccounts currentAccountName]] ) {
                  
                     //通知を実行
                     [[NSNotificationCenter defaultCenter] postNotification:notification];
                     
                 }else {
                     
                     [NSNotificationCenter postNotificationCenterForName:@"GrayViewEnd"];
                 }
                 
                 [ActivityIndicator off];
             }
         }];
        
        NSLog(@"HomeTimeline request sended");
        
    }@catch ( NSException *e ) {
        
        NSLog(@"%@\n\n%@", e , [e callStackSymbols]);
    }
}

+ (void)userTimeline:(NSString *)screenName {
    
    NSLog(@"userTimeline");
    
    if ( [screenName hasPrefix:@"@"] ) {
        
        screenName = [screenName substringFromIndex:1];
    }
    
    ACAccount *requestAccount = [TWAccounts currentAccount];
    
    //Twitterアカウントの確認
    if ( requestAccount == nil ) {
        
        //アカウントデータが空
        [ShowAlert error:@"アカウントが取得できませんでした。"];
        
        return;
    }
    
    //インターネット接続を確認
    if ( ![InternetConnection enable] ) return;
    
    [ActivityIndicator on];
    
    //タイムライン取得リクエストURL作成
    NSString *urlString = [NSString stringWithFormat:@"https://api.twitter.com/%@/statuses/user_timeline.json", API_VERSION];
    NSURL *reqUrl = [NSURL URLWithString:urlString];
    
    //リクエストパラメータを作成
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    //表示するユーザー
    [params setObject:screenName forKey:@"screen_name"];
    //取得数
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"TimelineLoadCount"] forKey:@"count"];
    //エンティティの有効化
    [params setObject:@"1" forKey:@"include_entities"];
    //RT表示
    [params setObject:@"1" forKey:@"include_rts"];
    
    //リクエストを作成
    TWRequest *request = [[TWRequest alloc] initWithURL:reqUrl
                                             parameters:params
                                          requestMethod:TWRequestMethodGET];
    
    //リクエストにアカウントを設定
    [request setAccount:requestAccount];
    
    //Timeline取得結果通知を作成
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result setObject:@"UserTimeline" forKey:@"Type"];
    
    __block __weak NSMutableDictionary *weakResult = result;
    
    NSNotification *notification =[NSNotification notificationWithName:@"GetUserTimeline"
                                                                object:self
                                                              userInfo:result];
    
    [request performRequestWithHandler:
     ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
         
         if ( responseData ) {
             
             NSError *jsonError = nil;
             id responseJSONData = [NSJSONSerialization
                                    JSONObjectWithData:responseData
                                    options:NSJSONReadingMutableLeaves
                                    error:&jsonError];
             
             if ( [responseJSONData isKindOfClass:[NSArray class]] ) {
                 
                 NSMutableArray *userTimeline = [NSMutableArray arrayWithArray:responseJSONData];
                 
                 //                         NSLog(@"userTimeline: %@", userTimeline);
                 
                 [weakResult setObject:requestAccount.username forKey:@"Account"];
                 
                 if ( userTimeline != nil && userTimeline.count != 0 ) {
                     
                     NSLog(@"UserTimelineSuccess");
                     
                     //t.coを全て展開する
                     userTimeline = [TWEntities replaceTcoAll:userTimeline];
                     userTimeline = [TWNgTweet ngAll:userTimeline];
                     
                     //取得完了を通知
                     [weakResult setObject:@"UserTimelineSuccess" forKey:@"Result"];
                     [weakResult setObject:userTimeline forKey:@"UserTimeline"];
                     
                 }else {
                     
                     NSLog(@"UserTimelineError");
                     
                     NSString *responseDataString = [[NSString alloc] initWithData:responseData
                                                                          encoding:NSUTF8StringEncoding];
                     
                     NSLog(@"responseData: %@", responseDataString);
                     
                     if ( userTimeline == nil ) NSLog(@"timeline == nil");
                     if ( userTimeline.count == 0 ) NSLog(@"timeline.count == 0");
                     
                     [weakResult setObject:@"UserTimelineError" forKey:@"Result"];
                     [NSNotificationCenter postNotificationCenterForName:@"GrayViewEnd"];
                 }
                 
                 if ( [requestAccount.username isEqualToString:[TWAccounts currentAccountName]] ) {
                     
                     //通知を実行
                     [[NSNotificationCenter defaultCenter] postNotification:notification];
                 }
                 
             }else if ( [responseJSONData isKindOfClass:[NSDictionary class]] ) {
                 
                 NSDictionary *errorData = [NSDictionary dictionaryWithDictionary:responseJSONData];
                 
                 [ShowAlert error:[errorData objectForKey:@"error"]];
                 [NSNotificationCenter postNotificationCenterForName:@"GrayViewEnd"];
                 
             }else {
                 
                 [ShowAlert unknownError];
                 [NSNotificationCenter postNotificationCenterForName:@"GrayViewEnd"];
             }
             
             [ActivityIndicator off];
             
         }else {
             
             NSLog(@"responseData nil");
         }
         
         weakResult = nil;
     }];
    
    //NSLog(@"UserTimeline request sended");
}

+ (void)mentions {
    
    @autoreleasepool {
        
        NSLog(@"mentions");
        
        ACAccount *requestAccount = [TWAccounts currentAccount];
        
        //Twitterアカウントの確認
        if ( requestAccount == nil ) {
            
            //アカウントデータが空
            [ShowAlert error:@"アカウントが取得できませんでした。"];
            
            return;
        }
        
        //インターネット接続を確認
        if ( ![InternetConnection enable] ) return;
        
        [ActivityIndicator on];
        
        //タイムライン取得リクエストURL作成
        NSString *urlString = [NSString stringWithFormat:@"http://api.twitter.com/%@/statuses/mentions.json", API_VERSION];
        NSURL *reqUrl = [NSURL URLWithString:urlString];
        
        //リクエストパラメータを作成
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        //取得数
        [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"MentionsLoadCount"] forKey:@"count"];
        //エンティティの有効化
        [params setObject:@"1" forKey:@"include_entities"];
        
        //リクエストを作成
        TWRequest *request = [[TWRequest alloc] initWithURL:reqUrl
                                                 parameters:params
                                              requestMethod:TWRequestMethodGET];
        
        //リクエストにアカウントを設定
        [request setAccount:requestAccount];
        
        //Mentions取得結果通知を作成
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setObject:@"Mentions" forKey:@"Type"];
        
        __block __weak NSMutableDictionary *weakResult = result;
        
        NSNotification *notification =[NSNotification notificationWithName:@"GetMentions"
                                                                    object:self
                                                                  userInfo:result];
        
        [request performRequestWithHandler:
         ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
             
             if ( responseData ) {
                 
                 NSError *jsonError = nil;
                 NSMutableArray *mentions = (NSMutableArray *)[NSJSONSerialization JSONObjectWithData:responseData
                                                                                              options:NSJSONReadingMutableLeaves
                                                                                                error:&jsonError];
                 
                 //取得完了を通知
                 [weakResult setObject:@"MentionsSuccess" forKey:@"Result"];
                 [weakResult setObject:mentions forKey:@"Mentions"];
                 
                 if ( [requestAccount.username isEqualToString:[TWAccounts currentAccountName]] ) {
                     
                     //通知を実行
                     [[NSNotificationCenter defaultCenter] postNotification:notification];
                     
                 }else {
                     
                     [NSNotificationCenter postNotificationCenterForName:@"GrayViewEnd"];
                 }
                 
                 [ActivityIndicator off];
             }
             
             weakResult = nil;
         }];
        
        //NSLog(@"Mentions request sended");
    }
}

+ (void)favotites {
    
    @autoreleasepool {
        
        ACAccount *requestAccount = [TWAccounts currentAccount];
        
        //Twitterアカウントの確認
        if ( requestAccount == nil ) {
            
            //アカウントデータが空
            [ShowAlert error:@"アカウントが取得できませんでした。"];
            
            return;
        }
        
        //インターネット接続を確認
        if ( ![InternetConnection enable] ) return;
        
        [ActivityIndicator on];
        
        //タイムライン取得リクエストURL作成
        NSString *urlString = [NSString stringWithFormat:@"https://api.twitter.com/%@/favorites.json", API_VERSION];
        NSURL *reqUrl = [NSURL URLWithString:urlString];
        
        //リクエストパラメータを作成
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        //取得数
        [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"FavoritesLoadCount"] forKey:@"count"];
        //エンティティの有効化
        [params setObject:@"1" forKey:@"include_entities"];
        
        //リクエストを作成
        TWRequest *request = [[TWRequest alloc] initWithURL:reqUrl
                                                 parameters:params
                                              requestMethod:TWRequestMethodGET];
        
        //リクエストにアカウントを設定
        [request setAccount:requestAccount];
        
        //Mentions取得結果通知を作成
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setObject:@"Favorites" forKey:@"Type"];
        
        __block __weak NSMutableDictionary *weakResult = result;
        
        NSNotification *notification =[NSNotification notificationWithName:@"GetFavorites"
                                                                    object:self
                                                                  userInfo:result];
        
        [request performRequestWithHandler:
         ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
             
             if ( responseData ) {
                 NSError *jsonError = nil;
                 NSMutableArray *favorites = (NSMutableArray *)[NSJSONSerialization JSONObjectWithData:responseData
                                                                                               options:NSJSONReadingMutableLeaves
                                                                                                 error:&jsonError];
                 
                 [weakResult setObject:@"FavoritesSuccess" forKey:@"Result"];
                 [weakResult setObject:favorites forKey:@"Favorites"];
                 
                 if ( [requestAccount.username isEqualToString:[TWAccounts currentAccountName]] ) {
                     
                     //通知を実行
                     [[NSNotificationCenter defaultCenter] postNotification:notification];
                     
                 }else {
                     
                     [NSNotificationCenter postNotificationCenterForName:@"GrayViewEnd"];
                 }
                 
                 [ActivityIndicator off];
             }
             
             weakResult = nil;
         }];
        
        //NSLog(@"Favorites request sended");
    }
}

+ (void)twitterSearch:(NSString *)searchWord {
    
    @autoreleasepool {
        
        ACAccount *requestAccount = [TWAccounts currentAccount];
        
        //Twitterアカウントの確認
        if ( requestAccount == nil ) {
            
            //アカウントデータが空
            [ShowAlert error:@"アカウントが取得できませんでした。"];
            
            return;
        }
        
        //インターネット接続を確認
        if ( ![InternetConnection enable] ) return;
        
        [ActivityIndicator on];
        
        //タイムライン取得リクエストURL作成
        NSURL *reqUrl = [NSURL URLWithString:@"http://search.twitter.com/search.json"];
        
        //リクエストパラメータを作成
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        //サーチワード
        [params setObject:searchWord forKey:@"q"];
        //取得数
        [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"TimelineLoadCount"] forKey:@"count"];
        //エンティティの有効化
        [params setObject:@"1" forKey:@"include_entities"];
        //日本
        [params setObject:@"ja" forKey:@"lang"];
        
        //リクエストを作成
        TWRequest *request = [[TWRequest alloc] initWithURL:reqUrl
                                                 parameters:params
                                              requestMethod:TWRequestMethodGET];
        
        //リクエストにアカウントを設定
        [request setAccount:requestAccount];
        
        //Mentions取得結果通知を作成
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setObject:@"Search" forKey:@"Type"];
        
        __block __weak NSMutableDictionary *weakResult = result;
        
        NSNotification *notification =[NSNotification notificationWithName:@"GetSearch"
                                                                    object:self
                                                                  userInfo:result];
        
        [request performRequestWithHandler:
         ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
             
             if ( responseData ) {
                 
                 NSError *jsonError = nil;
                 NSDictionary *searchResult = [NSJSONSerialization JSONObjectWithData:responseData
                                                                              options:NSJSONReadingMutableLeaves
                                                                                error:&jsonError];
                 
                 //NSLog(@"searchResult: %@", searchResult);
                 
                 //レスポンスを整形する
                 NSArray *results = [TWGetTimeline fixTwitterSearchResponse:[searchResult objectForKey:@"results"]];
                 
                 //t.coを全て展開する
                 results = [TWEntities replaceTcoAll:results];
                 searchResult = @{ @"results" : results };
                 
                 //NSLog(@"searchResult: %@", searchResult);
                 
                 //取得完了を通知
                 [weakResult setObject:@"SearchSuccess" forKey:@"Result"];
                 [weakResult setObject:[searchResult objectForKey:@"results"] forKey:@"Search"];
                 
                 if ( [requestAccount.username isEqualToString:[TWAccounts currentAccountName]] ) {
                     
                     //通知を実行
                     [[NSNotificationCenter defaultCenter] postNotification:notification];
                     
                 }else {
                     
                     [NSNotificationCenter postNotificationCenterForName:@"GrayViewEnd"];
                 }
                 
                 [ActivityIndicator off];
             }
             
             weakResult = nil;
         }];
        
        //NSLog(@"Favorites request sended");
    }
}

+ (NSArray *)fixTwitterSearchResponse:(NSArray *)twitterSearchResponse {
    
    //差異修正済みTweetを格納する
    NSMutableArray *fixedResponse = [NSMutableArray array];
    
    //TwitterSearch形式のTweetを順に差異修正する
    for ( id tweet in twitterSearchResponse ) {
        
        //修正のため可変長に変換する
        NSMutableDictionary *fixedTweet = [NSMutableDictionary dictionaryWithDictionary:tweet];
        
        //user以下を作成する
        NSMutableDictionary *user = [NSMutableDictionary dictionary];
        [user setObject:[fixedTweet objectForKey:@"from_user"] forKey:@"screen_name"];
        [user setObject:[fixedTweet objectForKey:@"profile_image_url"] forKey:@"profile_image_url"];
        [user setObject:[fixedTweet objectForKey:@"from_user_id_str"] forKey:@"id_str"];
        
        //sourceの文字参照を置換する
        NSMutableString *source = [fixedTweet objectForKey:@"source"];
        [source replaceOccurrencesOfString:@"&gt;"  withString:@">" options:0 range:NSMakeRange(0, [source length] )];
        [source replaceOccurrencesOfString:@"&lt;"  withString:@"<" options:0 range:NSMakeRange(0, [source length] )];
        [source replaceOccurrencesOfString:@"&amp;" withString:@"&" options:0 range:NSMakeRange(0, [source length] )];
        [source replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:0 range:NSMakeRange(0, [source length] )];
        
        //Tweetにセット
        [fixedTweet setObject:user forKey:@"user"];
        [fixedTweet setObject:source forKey:@"source"];
        
        //修正済みTweetを配列に追加
        [fixedResponse addObject:fixedTweet];
    }
    
    //固定長配列にして返す
    return [NSArray arrayWithArray:fixedResponse];
}

@end
