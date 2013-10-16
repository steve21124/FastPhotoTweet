//
//  InputAlertView.h
//

#import <UIKit/UIKit.h>

#define INPUT_ALERT_NOTOFICATION_NAME @"INPUT_ALERT_NOTOFICATION_NAME"

@interface InputAlertView : UIAlertView

typedef enum {
    InputAlertViewStyleNone,
    InputAlertViewStyleSingle,
    InputAlertViewStyleSingleSecure,
    InputAlertViewStyleDouble,
    InputAlertViewStyleDoubleSecure, // bottomTextField is secure style
} InputAlertViewStyle;

@property (nonatomic) InputAlertViewStyle inputStyle;
@property (nonatomic) SEL cancelButtonAction;
@property (nonatomic) SEL okButtonAction;

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                     delegate:(id)delegate
            cancelButtonTitle:(NSString *)cancelButtonTitle
                okButtonTitle:(NSString *)okButtonTitle
                   inputStyle:(InputAlertViewStyle)inputStyle NS_AVAILABLE_IOS(5_0);

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                     delegate:(id)delegate
            cancelButtonTitle:(NSString *)cancelButtonTitle
                okButtonTitle:(NSString *)okButtonTitle
           cancelButtonAction:(SEL)cancelButtonAction
               okButtonAction:(SEL)okButtonAction
                   inputStyle:(InputAlertViewStyle)inputStyle NS_AVAILABLE_IOS(5_0);

- (UITextField *)topTextField NS_AVAILABLE_IOS(5_0);
- (NSString *)topTextFieldText NS_AVAILABLE_IOS(5_0);

- (void)setTopTextFieldText:(NSString *)text placeholder:(NSString *)placeholder NS_AVAILABLE_IOS(5_0);

- (UITextField *)bottomTextField NS_AVAILABLE_IOS(5_0);
- (NSString *)bottomTextFieldText NS_AVAILABLE_IOS(5_0);
- (void)setBottomTextFieldText:(NSString *)text placeholder:(NSString *)placeholder NS_AVAILABLE_IOS(5_0);

@end
