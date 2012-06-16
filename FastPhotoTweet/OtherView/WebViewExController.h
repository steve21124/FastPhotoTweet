//
//  WebViewExController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/05/02.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Reachability.h"
#import "WebViewEx.h"
#import "UtilityClass.h"
#import "DeleteWhiteSpace.h"
#import "BookmarkViewController.h"

@interface WebViewExController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate, UITextFieldDelegate, NSXMLParserDelegate> {
    
    AppDelegate *appDelegate;
    GrayView *grayView;

    UIAlertView *alert;
    UITextField *alertText;
    
    NSUserDefaults *d;
    NSString *accessURL;
    NSString *saveFileName;
    NSURLConnection *asyncConnection;
    NSMutableData *asyncData;
    NSMutableArray *urlList;
    
    int actionSheetNo;
    int alertTextNo;
    
    BOOL openBookmark;
    BOOL fullScreen;
    BOOL editing;
}

@property (retain, nonatomic) IBOutlet WebViewEx *wv;

@property (retain, nonatomic) IBOutlet UIToolbar *topBar;
@property (retain, nonatomic) IBOutlet UITextField *urlField;
@property (retain, nonatomic) IBOutlet UITextField *searchField;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *searchButton;

@property (retain, nonatomic) IBOutlet UIToolbar *bottomBar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *composeButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *reloadButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *flexibleSpace;


- (IBAction)pushSearchButton:(id)sender;
- (IBAction)pushCloseButton:(id)sender;
- (IBAction)pushReloadButton:(id)sender;
- (IBAction)pushBackButton:(id)sender;
- (IBAction)pushForwardButton:(id)sender;
- (IBAction)pushComposeButton:(id)sender;
- (IBAction)pushMenuButton:(id)sender;

- (IBAction)enterSearchField:(id)sender;
- (IBAction)enterURLField:(id)sender;

- (IBAction)onUrlField: (id)sender;
- (IBAction)leaveUrlField: (id)sender;

- (IBAction)onSearchField: (id)sender;
- (IBAction)leaveSearchField: (id)sender;

- (IBAction)fullScreenGesture:(id)sender;

- (void)checkPasteBoardUrlOption;
- (void)openPasteBoardUrl:(NSString *)urlString;
- (void)becomeActive:(NSNotification *)notification;
- (void)setSearchEngine;
- (void)updateWebBrowser;
- (void)backForwordButtonVisible;
- (void)closeWebView;
- (void)rotateView:(int)mode;
- (void)saveImage;
- (void)requestStart;

@end
