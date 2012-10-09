//
//  TimelineViewController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

#import <UIKit/UIKit.h>
#import "QuartzCore/CALayer.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "AppDelegate.h"
#import "TimelineCellController.h"
#import "TWTwitterHeader.h"
#import "UtilityClass.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import <CFNetwork/CFNetwork.h>
#import "JSON.h"
#import "WebViewExController.h"

#import <Three20UI/Three20UI.h>
#import <Three20Style/Three20Style.h>
#import "Three20UICommon/TTGlobalUICommon.h"

@interface TimelineViewController : UIViewController <UIActionSheetDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
    
    AppDelegate *appDelegate;
    
    NSUserDefaults *d;
    NSFileManager *fileManager;
    NSMutableArray *timelineArray;
    NSMutableArray *timelineAppend;
    NSMutableArray *inReplyTo;
    NSMutableArray *reqedUser;
    NSMutableArray *iconUrls;
    NSMutableArray *currentList;
    NSMutableDictionary *allTimelines;
    NSMutableDictionary *sinceIds;
    NSMutableDictionary *icons;
    NSMutableDictionary *allLists;
    NSArray *mentionsArray;
    NSArray *selectTweetIds;
    NSArray *tweetInUrls;
    NSDictionary *currentTweet;
    NSDictionary *selectTweet;
    NSString *userStreamAccount;
    NSString *lastUpdateAccount;
    NSString *timelineTopTweetId;
    NSString *selectAccount;
    NSString *alertSearchUserName;
    
    UIPasteboard *pboard;
    UIImage *startImage;
    UIImage *stopImage;
    UIImage *listImage;
    UIImage *defaultActionButtonImage;
    UIAlertView *alertSearch;
    UITextField *alertSearchText;
    
    UIView *pickerBase;
    UIToolbar *pickerBar;
    UIPickerView *eventPicker;
    UIBarButtonItem *pickerBarDoneButton;
    UIBarButtonItem *pickerBarCancelButton;
    
    ACAccount *twAccount;
    
    BOOL userStream;
    BOOL openStreamAfter;
    BOOL userStreamFirstResponse;
    BOOL webBrowserMode;
    BOOL otherTweetsMode;
    BOOL viewWillAppear;
    BOOL userStreamBuffer;
    BOOL alertSearchType;
    BOOL listMode;
    BOOL pickerVisible;
    BOOL searchStream;
    
    int selectRow;
    int longPressControl;
    int timelineScroll;
    
    //PulllDownRefresh
    TTTableHeaderDragRefreshView *headerView;
    UIView *activityTable;
    BOOL isLoading;
}

@property (retain, nonatomic) IBOutlet UIToolbar *topBar;
@property (retain, nonatomic) IBOutlet UITableView *timeline;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *flexibleSpace;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *fixedSpace;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *postButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *reloadButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *timelineControlButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *actionButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *closeOtherTweetsButton;
@property (retain, nonatomic) IBOutlet UIImageView *accountIconView;
@property (retain, nonatomic) IBOutlet UISegmentedControl *timelineSegment;
@property (strong, nonatomic) NSURLConnection *connection;

- (IBAction)pushPostButton:(UIBarButtonItem *)sender;
- (IBAction)pushReloadButton:(UIBarButtonItem *)sender;
- (IBAction)pushTimelineControlButton:(UIBarButtonItem *)sender;
- (IBAction)pushActionButton:(UIBarButtonItem *)sender;
- (IBAction)pushCloseOtherTweetsButton:(UIBarButtonItem *)sender;

- (IBAction)swipeTimelineRight:(UISwipeGestureRecognizer *)sender;
- (IBAction)swipeTimelineLeft:(UISwipeGestureRecognizer *)sender;
- (IBAction)longPressTimeline:(UILongPressGestureRecognizer *)sender;

- (IBAction)changeSegment:(UISegmentedControl *)sender;

- (oneway void)setNotifications;
- (oneway void)setTimelineHeight;
- (void)createPullDownRefreshHeader;

- (void)createTimeline;
- (void)loadTimeline:(NSNotification *)center;
- (void)loadMentions:(NSNotification *)center;
- (void)loadFavorites:(NSNotification *)center;
- (void)getIconWithTweetArray:(NSMutableArray *)tweetArray;
- (void)getIconWithSequential;
- (void)changeAccount:(NSNotification *)notification;
- (void)appendTimelineUnit;
- (BOOL)appendTimelineUnitScroll;
- (void)getInReplyToChain:(NSDictionary *)tweetData;
- (void)scrollTimelineForNewTweet;
- (void)scrollTimelineToTop:(BOOL)animation;
- (void)refreshTimelineCell:(NSNumber *)index;
- (void)copyTweetInUrl:(NSArray *)urlList;

- (void)openStream;
- (void)closeStream;
- (void)userStreamDelete:(NSDictionary *)receiveData;
- (void)userStreamMyAddFavEvent:(NSDictionary *)receiveData;
- (void)userStreamMyRemoveFavEvent:(NSDictionary *)receiveData;
- (void)userStreamReceiveFavEvent:(NSDictionary *)receiveData;
- (void)userStreamReceiveTweet:(NSDictionary *)receiveData newTweet:(NSArray *)newTweet;

- (void)openSearchStream:(NSString *)searchWord;
- (void)closeSearchStream;
- (void)searchStreamReceiveTweet:(NSDictionary *)receiveData;

- (void)showTwitterAccountSelectActionSheet:(NSArray *)ids;
- (void)openTwitterService:(NSString *)username serviceType:(int)serviceType;

- (void)receiveProfile:(NSNotification *)notification;
- (void)enterBackground:(NSNotification *)notification;
- (void)becomeActive:(NSNotification *)notification;

- (oneway void)getMyAccountIcon;
- (void)timelineDidListChanged;
- (void)showListSelectView;

- (void)showPickerView;
- (void)pickerDone;
- (void)pickerCancel;
- (void)hidePicker;

@end
