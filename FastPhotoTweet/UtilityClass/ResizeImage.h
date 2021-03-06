//
//  ResizeImage.h
//  UtilityClass
//
//  Created by @peace3884 on 12/03/08.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

@interface ResizeImage : NSObject

+ (UIImage *)aspectResize:(UIImage *)image;
+ (UIImage *)aspectResizeForMaxSize:(UIImage *)image maxSize:(CGFloat)maxSize;

@end