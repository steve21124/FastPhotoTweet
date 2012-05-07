//
//  ResizeImage.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/03/08.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ResizeImage : NSObject

+ (UIImage *)aspectResize:(UIImage *)image;
+ (UIImage *)aspectResize:(UIImage *)image maxSize:(int)maxSize;
+ (UIImage *)resetImageSeze:(MPMediaItemArtwork *)artwork;

@end