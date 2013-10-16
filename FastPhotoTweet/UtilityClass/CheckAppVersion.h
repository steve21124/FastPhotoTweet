//
//  CheckAppVersion.h
//  FastPhotoTweet
//

#import <Foundation/Foundation.h>

@interface CheckAppVersion : NSObject <UIAlertViewDelegate>

- (oneway void)versionInfoURL:(NSString *)versionInfoURL updateIpaURL:(NSString *)updateIpaURL;

+ (BOOL)isBuildSDK7later;

@end
