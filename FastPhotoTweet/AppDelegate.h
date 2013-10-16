//
//  AppDelegate.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import "MainTabBarController.h"
#import "Stats.h"
#import "StatusBarInfo.h"

#define RELEASE_SAFETY(object) [object release]; object = nil;
#define REMOVE_SAFETY(object) [object removeFromSuperview]; object = nil;

#define BLANK_ARRAY [NSArray array]
#define BLANK_M_ARRAY [NSMutableArray array]
#define BLANK_DIC [NSDictionary dictionary]
#define BLANK_M_DIC [NSMutableDictionary dictionary]

#define FIREFOX_USER_AGENT @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:13.0) Gecko/20100101 Firefox/13.0.1"
#define IPAD_USER_AGENT @"Mozilla/5.0 (iPad; CPU OS 5_1_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B176 Safari/7534.48.3"
#define IPHONE_USER_AGENT @"Mozilla/5.0 (iPhone; CPU iPhone OS 5_1_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Mobile/9B206"

void uncaughtExceptionHandler(NSException *exception);

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainTabBarController *tabBarController;
@property (strong, nonatomic) StatusBarInfo *statusBarInfo;

@property (copy, nonatomic) NSString *postText;
@property (copy, nonatomic) NSString *postTextType;
@property (copy, nonatomic) NSString *bookmarkUrl;
@property (copy, nonatomic) NSString *urlSchemeDownloadUrl;
@property (copy, nonatomic) NSString *reOpenUrl;
@property (copy, nonatomic) NSString *addTwitpicAccountName;
@property (strong, nonatomic) NSArray *startupUrlList;
//@property (nonatomic, weak) NSTimer *pBoardWatchTimer;

@property (nonatomic) BOOL twitpicLinkMode;
@property (nonatomic) BOOL needChangeAccount;

@end
