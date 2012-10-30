//
//  TWParser
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

/////////////////////////////
//////// ARC ENABLED ////////
/////////////////////////////

#import "TWParser.h"

#define DATE_FORMAT @"HH:mm:ss"
#define BLANK @""
#define OFFSET 64800

@implementation TWParser

//in: create_at
//out: JSTタイムゾーン適用済み時刻
+ (NSString *)JSTDate:(NSString *)tweetData {
    
    NSString *jstDate = BLANK;
    
    @try {
        
        //時刻のトリム開始位置
        int from = 11;
        
        //,がある場合はTwitterSearchのパターン
        //トリム開始位置を変更
        if ( [tweetData rangeOfString:@","].location != NSNotFound ) from = 17;
        
        //時刻フォーマットを指定
        NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
        [inputDateFormatter setDateFormat:DATE_FORMAT];
        
        //JSTタイムゾーンを適用し、時刻部分を抜き出す
        jstDate = [[[NSDate dateWithTimeInterval:OFFSET sinceDate:[inputDateFormatter dateFromString:[tweetData substringWithRange:NSMakeRange(from, 8)]]] description] substringWithRange:NSMakeRange(11, 8)];
        
        inputDateFormatter = nil;
        tweetData = nil;
        
    }@catch ( NSException *e ) {
        
        return BLANK;
    }
    
    //JSTタイムゾーン適用済み時刻をHH:mm:ss形式で返却
    return jstDate;
}

+ (NSString *)date:(NSString *)tweetData {
    
    return [tweetData substringWithRange:NSMakeRange(11,8)];
}

//in: source
//out: クライアント名
+ (NSString *)client:(NSString *)tweetData {
    
    NSString *clientName = BLANK;
    
    @try {
        
        if ( tweetData == nil )return BLANK;
        
        if ( [tweetData isEqualToString:@"web"] ) return @"web";
        
        NSError *error = nil;
        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@">.{1,160}<"
                                                                                options:0
                                                                                  error:&error];
        
        //エラーの場合は空白文字を返す
        if ( error ) return BLANK;
        
        NSTextCheckingResult *match = [regexp firstMatchInString:tweetData
                                                         options:0
                                                           range:NSMakeRange(0, tweetData.length)];
        
        if ( match.numberOfRanges != 0 ) {
            
            //クライアント名が取得できた場合
            tweetData = [tweetData substringWithRange:[match rangeAtIndex:0]];
            clientName = [tweetData substringWithRange:NSMakeRange( 1, tweetData.length-2 )];
        }
        
        //クライアント名が取得できなかった場合
        if ( clientName == nil ) return BLANK;
        
        tweetData = nil;
        error = nil;
        regexp = nil;
        match = nil;
        
    }@catch ( NSException *e ) {
        
        return BLANK;
    }
    
    return clientName;
}

+ (NSDictionary *)rtText:(NSDictionary *)tweet {
    
    NSMutableDictionary *mTweet = [NSMutableDictionary dictionaryWithDictionary:tweet];
    
    NSMutableDictionary *rtStatus = [NSMutableDictionary dictionaryWithDictionary:[mTweet objectForKey:@"retweeted_status"]];
    NSMutableDictionary *rtStatusUser = [NSMutableDictionary dictionaryWithDictionary:[[mTweet objectForKey:@"retweeted_status"] objectForKey:@"user"]];
    
    [rtStatus removeObjectForKey:@"contributors"];
    [rtStatus removeObjectForKey:@"coordinates"];
    [rtStatus removeObjectForKey:@"geo"];
    [rtStatus removeObjectForKey:@"truncated"];
    [rtStatus removeObjectForKey:@"place"];
    
    [rtStatusUser removeObjectForKey:@"contributors_enabled"];
    [rtStatusUser removeObjectForKey:@"default_profile"];
    [rtStatusUser removeObjectForKey:@"default_profile_image"];
    [rtStatusUser removeObjectForKey:@"follow_request_sent"];
    [rtStatusUser removeObjectForKey:@"geo_enabled"];
    [rtStatusUser removeObjectForKey:@"friends_count"];
    [rtStatusUser removeObjectForKey:@"is_translator"];
    [rtStatusUser removeObjectForKey:@"listed_count"];
    [rtStatusUser removeObjectForKey:@"notifications"];
    [rtStatusUser removeObjectForKey:@"profile_background_color"];
    [rtStatusUser removeObjectForKey:@"profile_background_image_url"];
    [rtStatusUser removeObjectForKey:@"profile_background_image_url_https"];
    [rtStatusUser removeObjectForKey:@"profile_background_tile"];
    [rtStatusUser removeObjectForKey:@"profile_image_url_https"];
    [rtStatusUser removeObjectForKey:@"profile_link_color"];
    [rtStatusUser removeObjectForKey:@"profile_sidebar_border_color"];
    [rtStatusUser removeObjectForKey:@"profile_sidebar_fill_color"];
    [rtStatusUser removeObjectForKey:@"profile_text_color"];
    [rtStatusUser removeObjectForKey:@"profile_use_background_image"];
    [rtStatusUser removeObjectForKey:@"time_zone"];
    [rtStatusUser removeObjectForKey:@"utc_offset"];
    [rtStatusUser removeObjectForKey:@"verified"];
    [rtStatusUser removeObjectForKey:@"statuses_count"];
    
    [rtStatus setObject:rtStatusUser forKey:@"user"];
    [mTweet setObject:rtStatus forKey:@"retweeted_status"];
    
    NSString *originalText =  [[mTweet objectForKey:@"retweeted_status"] objectForKey:@"text"];
    NSString *postUser =     [[[mTweet objectForKey:@"retweeted_status"] objectForKey:@"user"] objectForKey:@"screen_name"];
    NSString *postUserIcon = [[[mTweet objectForKey:@"retweeted_status"] objectForKey:@"user"] objectForKey:@"profile_image_url"];
    NSString *rtUser = [[tweet objectForKey:@"user"] objectForKey:@"screen_name"];
    
    NSMutableDictionary *user = [NSMutableDictionary dictionaryWithDictionary:[mTweet objectForKey:@"user"]];
    [user setObject:postUser forKey:@"screen_name"];
    [user setObject:postUserIcon forKey:@"profile_image_url"];
    
    [mTweet setObject:[NSString stringWithFormat:@"%@\nRetweeted by @%@", originalText, rtUser] forKey:@"text"];
    [mTweet setObject:user forKey:@"user"];
    [mTweet setObject:rtUser forKey:@"rt_user"];
    
    rtStatus = nil;
    rtStatusUser = nil;
    originalText = nil;
    postUser = nil;
    postUserIcon = nil;
    rtUser = nil;
    user = nil;
    
    return [NSDictionary dictionaryWithDictionary:mTweet];
}

@end
