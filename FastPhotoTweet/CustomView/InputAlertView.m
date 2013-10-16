//
//  InputAlertView.m
//

#import "InputAlertView.h"

@interface InputAlertView () <UITextFieldDelegate>

typedef enum {
    TextFieldIndexTop,
    TextFieldIndexBottom,
} TextFieldIndex;

@end

@implementation InputAlertView

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle inputStyle:(InputAlertViewStyle)inputStyle {
    
    return [self initWithTitle:title
                       message:message
                      delegate:delegate
             cancelButtonTitle:cancelButtonTitle
                 okButtonTitle:okButtonTitle
            cancelButtonAction:nil
                okButtonAction:nil
                    inputStyle:inputStyle];
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle cancelButtonAction:(SEL)cancelButtonAction okButtonAction:(SEL)okButtonAction  inputStyle:(InputAlertViewStyle)inputStyle {
    
    self = [super initWithTitle:title
                        message:message
                       delegate:delegate
              cancelButtonTitle:cancelButtonTitle
              otherButtonTitles:okButtonTitle, nil];
    
    if ( self ) {
        
        [self setCancelButtonAction:cancelButtonAction];
        [self setOkButtonAction:okButtonAction];
        [self setInputStyle:inputStyle];
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////

- (void)setInputStyle:(InputAlertViewStyle)inputStyle {
    
    switch ( inputStyle ) {
            
        case InputAlertViewStyleNone:
            [self setAlertViewStyle:UIAlertViewStyleDefault];
            break;
            
        case InputAlertViewStyleSingle:
            [self setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [self.topTextField setDelegate:self.delegate];
            [self.topTextField setPlaceholder:@""];
            break;
            
        case InputAlertViewStyleSingleSecure:
            [self setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [self.topTextField setSecureTextEntry:YES];
            [self.topTextField setDelegate:self.delegate];
            [self.topTextField setPlaceholder:@""];
            break;
            
        case InputAlertViewStyleDouble:
            [self setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
            [self.bottomTextField setSecureTextEntry:NO];
            [self.topTextField setDelegate:self.delegate];
            [self.bottomTextField setDelegate:self.delegate];
            [self.topTextField setPlaceholder:@""];
            [self.bottomTextField setPlaceholder:@""];
            break;
            
        case InputAlertViewStyleDoubleSecure:
            [self setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
            [self.topTextField setDelegate:self.delegate];
            [self.bottomTextField setDelegate:self.delegate];
            [self.topTextField setPlaceholder:@""];
            [self.bottomTextField setPlaceholder:@""];
            break;
            
        default:
            [self setAlertViewStyle:UIAlertViewStyleDefault];
            break;
    }
}

////////////////////////////////////////////////////////////////////////////////

- (UITextField *)topTextField {
    
    if ( self.alertViewStyle != UIAlertViewStyleDefault ) {
        
        return [self textFieldAtIndex:TextFieldIndexTop];
        
    } else {
        
        return nil;
    }
}

- (NSString *)topTextFieldText {
    
    return [[self topTextField] text];
}

- (void)setTopTextFieldText:(NSString *)text placeholder:(NSString *)placeholder {
    
    UITextField *topTextField = [self topTextField];
    [topTextField setText:text];
    [topTextField setPlaceholder:placeholder];
}

- (UITextField *)bottomTextField {
    
    if ( self.alertViewStyle != UIAlertViewStyleDefault ) {
        
        return [self textFieldAtIndex:TextFieldIndexBottom];
        
    } else {
        
        return nil;
    }
}

- (NSString *)bottomTextFieldText {
    
    return [[self bottomTextField] text];
}

- (void)setBottomTextFieldText:(NSString *)text placeholder:(NSString *)placeholder {
    
    UITextField *bottomTextField = [self bottomTextField];
    [bottomTextField setText:text];
    [bottomTextField setPlaceholder:placeholder];
}

////////////////////////////////////////////////////////////////////////////////

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ( self.inputStyle == InputAlertViewStyleSingle ||
         self.inputStyle == InputAlertViewStyleSingleSecure ) {
        
        if ( self.okButtonAction ) {
            
            if ( [self.delegate respondsToSelector:self.okButtonAction] ) {
                
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self.delegate performSelector:self.okButtonAction
                                    withObject:nil];
#pragma clang diagnostic pop
            }
        }
        
    } else if ( self.inputStyle == InputAlertViewStyleDouble ||
                self.inputStyle == InputAlertViewStyleDoubleSecure ) {
        
        if ( textField == self.bottomTextField ) {
            
            if ( self.okButtonAction ) {
                
                if ( [self.delegate respondsToSelector:self.okButtonAction] ) {
                    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [self.delegate performSelector:self.okButtonAction
                                        withObject:nil];
#pragma clang diagnostic pop
                }
                
            } else {
                
                [self.topTextField becomeFirstResponder];
            }
        }
    }
    
    return YES;
}

@end
