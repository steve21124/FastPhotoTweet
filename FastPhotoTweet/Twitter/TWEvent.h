//
//  TWEvent.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/11.
//

#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import <Foundation/Foundation.h>
#import "TWGetAccount.h"
#import "ShowAlert.h"
#import "ActivityIndicator.h"
#import "JSON.h"

@interface TWEvent : NSObject {
    
@public
    ACAccount *twAccount;
}

+ (void)favorite:(NSString *)tweetId;
+ (void)reTweet:(NSString *)tweetId;
+ (void)favoriteReTweet:(NSString *)tweetId;
+ (void)getProfile:(NSString *)screenName;
+ (void)getTweet:(NSString *)tweetId;

+ (void)unFavorite:(NSString *)tweetId;

+ (ACAccount *)canAction;

@end