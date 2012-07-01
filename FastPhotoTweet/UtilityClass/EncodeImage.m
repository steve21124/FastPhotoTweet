//
//  EncodeImage.m
//  UtilityClass
//
//  Created by @peace3884 on 12/04/15.
//

#import "EncodeImage.h"

@implementation EncodeImage

+ (NSData *)image:(UIImage *)encodeImage {
    
    //NSLog(@"encodeImage");
    
    NSData *encodedImageData;
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    if ( [[d objectForKey:@"SaveImageType"] isEqualToString:@"JPG(Low)"] ) {
        encodedImageData = UIImageJPEGRepresentation(encodeImage, 0.6);
    }else if ( [[d objectForKey:@"SaveImageType"] isEqualToString:@"JPG"] ) {
        encodedImageData = UIImageJPEGRepresentation(encodeImage, 0.8);
    }else if ( [[d objectForKey:@"SaveImageType"] isEqualToString:@"JPG(High)"] ) {
        encodedImageData = UIImageJPEGRepresentation(encodeImage, 0.95);
    }else if ( [[d objectForKey:@"SaveImageType"] isEqualToString:@"PNG"] ) {
        encodedImageData = UIImagePNGRepresentation(encodeImage);
    }else {
        encodedImageData = UIImageJPEGRepresentation(encodeImage, 0.8);
    }
    
    return encodedImageData;
}

+ (NSData *)jpgLow:(UIImage *)encodeImage {
    
    return UIImageJPEGRepresentation(encodeImage, 0.6);
}

+ (NSData *)jpg:(UIImage *)encodeImage {
    
    return UIImageJPEGRepresentation(encodeImage, 0.8);
}

+ (NSData *)jpgHigh:(UIImage *)encodeImage {
    
    return UIImageJPEGRepresentation(encodeImage, 0.95);
}

+ (NSData *)png:(UIImage *)encodeImage {
    
    return UIImagePNGRepresentation(encodeImage);
}

@end
