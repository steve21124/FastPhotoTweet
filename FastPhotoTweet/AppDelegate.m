//
//  AppDelegate.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "TweetViewController.h"
#import "TimelineViewController.h"
#import "BaseNavigationController.h"
#import <mach/mach.h>
#import <mach/mach_host.h>

void uncaughtExceptionHandler(NSException *e) {
    
    NSLog(@"CRASH: %@", e);
    NSLog(@"Stack Trace: %@", [e callStackSymbols]);
    
    NSString *outputText = [NSString stringWithFormat:@"%@\n\n%@", e, [e callStackSymbols]];
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd_hh-mm-ss"];
    
    NSString *convertedDate = [formatter stringFromDate:now];
    
    NSMutableString *fileName = [NSMutableString stringWithFormat:@"%@.txt", convertedDate];
    NSString *dataPath = [LOGS_DIRECTORY stringByAppendingPathComponent:fileName];
    
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:dataPath] ) {
        
        [outputText writeToFile:dataPath atomically:NO
                 encoding:NSUTF8StringEncoding
                    error:nil];
    }
}

@interface AppDelegate ()

@property (strong, nonatomic) Stats *stats;

@property (nonatomic) BOOL pBoardWatch;
@property (nonatomic) BOOL debugMode;

@property (strong, nonatomic) NSArray *pBoardUrls;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (copy, nonatomic) NSString *lastCheckPasteBoardURL;

- (NSString *)getPlatformName;
- (void)memoryStatus;
- (void)startPasteBoardTimer;
- (void)stopPasteBoardTimer;
- (void)checkPasteBoard;

@end

@implementation AppDelegate

#pragma mark - Initialize

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //NSLog(@"FinishLaunching: %@", launchOptions);
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    if ( [USER_DEFAULTS objectForKey:@"HomePageURL"] == nil || [[USER_DEFAULTS objectForKey:@"HomePageURL"] isEqualToString:BLANK] ) {
        
        [USER_DEFAULTS setObject:@"http://www.google.co.jp/" forKey:@"HomePageURL"];
    }
    
    _statusBarInfo = [[StatusBarInfo alloc] initWithShowTime:@2.0f
                                           taskCheckInterval:@0.1f
                                           animationDuration:@0.3f
                                               animationType:StatusBarInfoAnimationTypeTopInToFadeOut
                                             backgroundColor:[UIColor colorWithRed:0.4f
                                                                             green:0.8f
                                                                              blue:1.0f
                                                                             alpha:1.0f]
                                                   textColor:[UIColor whiteColor]];
    [self.window addSubview:_statusBarInfo];
    
    //各種初期化
    _postText = BLANK;
    _postTextType = BLANK;
    _bookmarkUrl = BLANK;
    _urlSchemeDownloadUrl = BLANK;
    _reOpenUrl = BLANK;
    _addTwitpicAccountName = BLANK;
    
    _twitpicLinkMode = NO;
    _needChangeAccount = NO;
    _debugMode = NO;
    
    _startupUrlList = [NSArray arrayWithObject:[USER_DEFAULTS objectForKey:@"HomePageURL"]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    MainViewController *mainView = [[MainViewController alloc] init];
    BaseNavigationController *mainNavigation = [[BaseNavigationController alloc] initWithRootViewController:mainView];
    mainNavigation.viewControllers = @[mainView];
    mainNavigation.navigationBarHidden = YES;

    TimelineViewController *timelineView = [[TimelineViewController alloc] init];
    timelineView.title = @"Timeline";
    
    BaseNavigationController *timelineNavigation = [[BaseNavigationController alloc] initWithRootViewController:timelineView];
    timelineNavigation.viewControllers = @[timelineView];
    timelineNavigation.navigationBarHidden = YES;
    
    self.tabBarController = [[MainTabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:mainNavigation, timelineNavigation, nil];
    self.window.rootViewController = self.tabBarController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark - LocalNotification

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    NSLog(@"Notification: %@", notification.userInfo);
    
    if ( notification.userInfo != nil ) {
    
        NSNotification *pboardNotification =
        [NSNotification notificationWithName:@"pboardNotification"
                                      object:self
                                    userInfo:notification.userInfo];
        
        [[NSNotificationCenter defaultCenter] postNotification:pboardNotification];
    }
}

#pragma mark - URL Scheme

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)schemeURL {

    //NSLog(@"handleOpenURL: %@", schemeURL.absoluteString);

    if ( [schemeURL.absoluteString hasPrefix:@"fhttp"] || [schemeURL.absoluteString hasPrefix:@"fhttps"]) {
        
        _urlSchemeDownloadUrl = [schemeURL.absoluteString substringFromIndex:1];
    }
    
    return YES;
}

#pragma mark - System

- (NSString *)getPlatformName {
    
    struct utsname u;
    uname(&u);
    NSString *hardwareName = [NSString stringWithFormat:@"%s", u.machine];
    
    if ( [hardwareName hasPrefix:@"iPhone2"] ) {
        hardwareName = @"iPhone 3GS";
    } else if ( [hardwareName hasPrefix:@"iPhone3"] ) {
        hardwareName = @"iPhone 4";
    } else if ( [hardwareName hasPrefix:@"iPhone4"] ) {
        hardwareName = @"iPhone 4S";
    } else if ( [hardwareName hasPrefix:@"iPhone5,1"] ) {
        hardwareName = @"iPhone 5";
    } else if ( [hardwareName hasPrefix:@"iPhone5,2"] ) {
        hardwareName = @"iPhone 5 CDMA";
    } else if ( [hardwareName hasPrefix:@"iPhone5,3"] ) {
        hardwareName = @"iPhone 5c";
    } else if ( [hardwareName hasPrefix:@"iPhone5,4"] ) {
        hardwareName = @"iPhone 5c CDMA";
    } else if ( [hardwareName hasPrefix:@"iPhone6,1"] ) {
        hardwareName = @"iPhone 5s";
    } else if ( [hardwareName hasPrefix:@"iPhone6,2"] ) {
        hardwareName = @"iPhone 5s CDMA";
    } else if ( [hardwareName hasPrefix:@"iPad1"] ) {
        hardwareName = @"iPad";
    } else if ( [hardwareName hasPrefix:@"iPad2"] ) {
        hardwareName = @"iPad 2gen";
    } else if ( [hardwareName hasPrefix:@"iPad3"] ) {
        hardwareName = @"iPad 3gen";
    } else if ( [hardwareName hasPrefix:@"x86_64"] ||
                [hardwareName hasPrefix:@"i386"] ) {
        hardwareName = @"iOS Simulator";
    } else {
        hardwareName = @"OtherDevice";
    }
    
    NSLog(@"Run with %@@%@", hardwareName, FIRMWARE_VERSION);
    return hardwareName;
}

- (void)memoryStatus {
    
    if ( _debugMode ) {
     
        [_stats removeFromSuperview];
        _stats = nil;
        _debugMode = NO;
        
    } else {

        _stats = [[Stats alloc] initWithFrame:CGRectMake(5, 25, 100.0, 60.0)];
        [self.window addSubview:_stats];
        _debugMode = YES;
    }
}

#pragma mark - PasteBoard

- (void)startPasteBoardTimer {
    
    NSLog(@"startPasteBoardTimer");
    
    @try {
        
        _lastCheckPasteBoardURL = P_BOARD.string;
        
    } @catch ( NSException *e ) {
        
        [P_BOARD setString:BLANK];
        _lastCheckPasteBoardURL = BLANK;
    }
    
    _pBoardUrls = BLANK_ARRAY;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            
            [self setPBoardWatch:YES];
            while (self.pBoardWatch) {
                
                NSString *pBoardString = [P_BOARD valueForPasteboardType:@"public.text"];
                if ( ![EmptyCheck string:pBoardString] ) {
                    
                    pBoardString = P_BOARD.URL.absoluteString;
                }
                
                //文字列がない場合は終了
                if ( ![EmptyCheck string:pBoardString] ) {
                    
                    continue;
                }
                
                //ペーストボードの内容が変化チェック
                if ( ![pBoardString isEqualToString:_lastCheckPasteBoardURL] ) {
                    
                    //URLがあるか確認
                    _pBoardUrls = [NSArray arrayWithArray:[pBoardString URLs]];
                    
                    if ( _pBoardUrls.count == 0 ) {
                        
                        continue;
                    }
                    
                    _lastCheckPasteBoardURL = pBoardString;
                    
                    //通知を行う
                    UILocalNotification *localPush = [[UILocalNotification alloc] init];
                    localPush.timeZone = [NSTimeZone defaultTimeZone];
                    localPush.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
                    localPush.alertBody = _lastCheckPasteBoardURL;
                    localPush.userInfo = @{ @"pboardURL" : [_pBoardUrls objectAtIndex:0] };
                    [[UIApplication sharedApplication] scheduleLocalNotification:localPush];
                }
                
                [NSThread sleepForTimeInterval:0.1];
            }
            
            UIApplication  *application = [UIApplication sharedApplication];
            [application endBackgroundTask:self.backgroundTask];
            [self setBackgroundTask:UIBackgroundTaskInvalid];
        });
    });
    
//    _pBoardWatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
//                                                        target:self
//                                                      selector:@selector(checkPasteBoard)
//                                                      userInfo:nil
//                                                       repeats:YES];
//    [_pBoardWatchTimer fire];
}

- (void)stopPasteBoardTimer {
    
    NSLog(@"stopPasteBoardTimer");
    
    [self setPBoardWatch:NO];
//    [_pBoardWatchTimer invalidate];
}

- (void)checkPasteBoard {
    
    @try {
        
        //NSLog(@"checkPasteBoard");
        
        NSString *pBoardString = P_BOARD.string;
        
        if ( ![EmptyCheck string:pBoardString] ) {
            
            pBoardString = P_BOARD.URL.absoluteString;
        }
        
        //文字列がない場合は終了
        if ( ![EmptyCheck string:pBoardString] ) {
         
            return;
        }
        
        //ペーストボードの内容が変化チェック
        if ( ![pBoardString isEqualToString:_lastCheckPasteBoardURL] ) {
            
            //URLがあるか確認
            _pBoardUrls = [NSArray arrayWithArray:[pBoardString URLs]];
            
            if ( _pBoardUrls.count == 0 ) {
                
                return;
            }
            
            _lastCheckPasteBoardURL = pBoardString;
            
            //通知を行う
            UILocalNotification *localPush = [[UILocalNotification alloc] init];
            localPush.timeZone = [NSTimeZone defaultTimeZone];
            localPush.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
            localPush.alertBody = _lastCheckPasteBoardURL;
            localPush.userInfo = @{ @"pboardURL" : [_pBoardUrls objectAtIndex:0] };
            [[UIApplication sharedApplication] scheduleLocalNotification:localPush];
        }
        
        [self setBackgroundTask:UIBackgroundTaskInvalid];
        
    } @catch ( NSException *e ) { }
}

#pragma mark - Application

- (void)applicationWillResignActive:(UIApplication *)application {
    
//    NSLog(@"applicationWillResignActive");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
//    NSLog(@"applicationWillEnterForeground");
    
    NSNotification *statusBarNotification = [NSNotification notificationWithName:@"StartStatusBarTimer"
                                                                          object:self
                                                                        userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:statusBarNotification];
    
    [self stopPasteBoardTimer];
//    if ( _pBoardWatchTimer.isValid ) {
//        
//    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    //NSLog(@"applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    //NSLog(@"applicationWillTerminate");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
//    NSLog(@"applicationDidEnterBackground");
    
    NSNotification *statusBarNotification = [NSNotification notificationWithName:@"StopStatusBarTimer"
                                                                          object:self
                                                                        userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:statusBarNotification];
    
    self.backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
        
        if ( self.backgroundTask != UIBackgroundTaskInvalid ) {
            
            [application endBackgroundTask:self.backgroundTask];
            [self setBackgroundTask:UIBackgroundTaskInvalid];
        }
    }];
    
    [self startPasteBoardTimer];
    
//    if ( !_pBoardWatchTimer.isValid ) {
//        
//        
//    }
}

#pragma mark - View

- (void)dealloc {

//    if ( _pBoardWatchTimer.isValid ) [self stopPasteBoardTimer];
    
    self.tabBarController = nil;
    self.window = nil;
}

@end
