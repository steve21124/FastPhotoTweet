//
//  ImageWindow.h
//

#import <UIKit/UIView.h>
#import <QuartzCore/QuartzCore.h>
#import "ShowAlert.h"
#import "FullSizeImage.h"

@interface ImageWindow : UIView <NSURLConnectionDelegate, UIActionSheetDelegate>

- (void)loadImage:(NSString *)imageUrl viewRect:(CGRect)viewRect baseViewTopMargin:(CGFloat)baseViewTopMargin;

@end
