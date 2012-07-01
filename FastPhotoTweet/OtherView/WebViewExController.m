//
//  WebViewExController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/05/02.
//

/////////////////////////////
//////// ARC ENABLED ////////
/////////////////////////////

#import "WebViewExController.h"

#define TOP_BAR [NSArray arrayWithObjects:urlField, searchField, searchButton, nil]
#define BOTTOM_BAR [NSArray arrayWithObjects:closeButton, flexibleSpace, reloadButton, flexibleSpace, backButton, flexibleSpace, forwardButton, flexibleSpace, composeButton, flexibleSpace, bookmarkButton, flexibleSpace, menuButton, nil]
#define EXTENSIONS [NSArray arrayWithObjects:@"zip", @"mp4", @"mov", @"m4a", @"rar", @"dmg", @"deb", nil]

#define BLANK @""

@implementation WebViewExController
@synthesize wv;
@synthesize topBar;
@synthesize urlField;
@synthesize searchField;
@synthesize bottomBar;
@synthesize closeButton;
@synthesize reloadButton;
@synthesize backButton;
@synthesize forwardButton;
@synthesize composeButton;
@synthesize menuButton;
@synthesize flexibleSpace;
@synthesize bookmarkButton;
@synthesize bytesLabel;
@synthesize progressBar;
@synthesize downloadCancelButton;
@synthesize searchButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self ) {
    }
    
    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];
    
    pboard = [UIPasteboard generalPasteboard];
    
    grayView = [[GrayView alloc] init];
    [wv addSubview:grayView];
    
    urlList = [NSMutableArray array];
    
    reloadButtonImage = [UIImage imageNamed:@"reload.png"];
    stopButtonImage = [UIImage imageNamed:@"stop.png"];
    
    openBookmark = NO;
    fullScreen = NO;
    editing = NO;
    downloading = NO;
    loading = NO;
    openUrlMode = NO;
    
    //アプリがアクティブになった場合の通知を受け取る設定
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(becomeActive:)
                               name:UIApplicationDidBecomeActiveNotification
                             object:nil];
    
    d = [NSUserDefaults standardUserDefaults];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [d boolForKey:@"ClearBrowserSearchField"] ? ( searchField.clearsOnBeginEditing = YES ) : ( searchField.clearsOnBeginEditing = NO );
    
    accessURL = BLANK;
    
    [self setSearchEngine];
    
    //ツールバーにボタンをセット
    [bottomBar setItems:BOTTOM_BAR animated:NO];
    
    //ペーストボードURL展開を確認
    [self checkPasteBoardUrlOption];
    
    //URLが1つ以上、FastGoogleモードではないなら中止
    if ( urlList.count > 1 ) return;
    
    //ページをロード
    [wv loadRequestWithString:appDelegate.openURL];
    
    appDelegate.isBrowserOpen = [NSNumber numberWithInt:1];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //NSLog(@"viewWillAppear");
    
    //NSLog(@"Bookmark: %@", appDelegate.bookmarkUrl);
    
    if ( openBookmark ) {
        
        openBookmark = NO;
        
        if ( [EmptyCheck check:appDelegate.bookmarkUrl] ) {
            
            //ブックマークで選択したURLを読み込み
            [wv loadRequestWithString:appDelegate.bookmarkUrl];
            appDelegate.bookmarkUrl = BLANK;
        }
    }
}

- (void)checkPasteBoardUrlOption {
    
    //ペーストボード内のURLを開く設定が有効かチェック
    if ( [d boolForKey:@"OpenPasteBoardURL"] || openUrlMode ) {
        
        //PasteBoardがテキストかチェック
        if ( [PasteboardType isText] ) {
            
            @try {
            
                //URLを抽出
                urlList = [RegularExpression urls:pboard.string];
                
            }@catch ( NSException *e ) {
                
                urlList = [NSArray array];
            }
            
            if ( [EmptyCheck check:urlList] ) {
                
                if (urlList.count == 1 ) {
                    
                    [self openPasteBoardUrl:[urlList objectAtIndex:0]];
                
                }else if (urlList.count == 2 ) {
                    
                    actionSheetNo = 2;
                    
                    UIActionSheet *sheet = [[UIActionSheet alloc]
                                            initWithTitle:@"URL選択"
                                            delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle:nil
                                            otherButtonTitles:[urlList objectAtIndex:0], 
                                                              [urlList objectAtIndex:1], nil];
                    [sheet showInView:self.view];
                    
                }else if (urlList.count == 3 ) {
                    
                    actionSheetNo = 3;
                    
                    UIActionSheet *sheet = [[UIActionSheet alloc]
                                            initWithTitle:@"URL選択"
                                            delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle:nil
                                            otherButtonTitles:[urlList objectAtIndex:0], 
                                                              [urlList objectAtIndex:1], 
                                                              [urlList objectAtIndex:2], nil];
                    [sheet showInView:self.view];
                    
                }else if (urlList.count == 4 ) {
                    
                    actionSheetNo = 4;
                    
                    UIActionSheet *sheet = [[UIActionSheet alloc]
                                            initWithTitle:@"URL選択"
                                            delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle:nil
                                            otherButtonTitles:[urlList objectAtIndex:0], 
                                                              [urlList objectAtIndex:1], 
                                                              [urlList objectAtIndex:2], 
                                                              [urlList objectAtIndex:3], nil];
                    [sheet showInView:self.view];
                    
                }else if (urlList.count == 5 ) {
                    
                    actionSheetNo = 5;
                    
                    UIActionSheet *sheet = [[UIActionSheet alloc]
                                            initWithTitle:@"URL選択"
                                            delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle:nil
                                            otherButtonTitles:[urlList objectAtIndex:0], 
                                                              [urlList objectAtIndex:1], 
                                                              [urlList objectAtIndex:2], 
                                                              [urlList objectAtIndex:3],
                                                              [urlList objectAtIndex:4], nil];
                    [sheet showInView:self.view];
                    
                }else if (urlList.count >= 6 ) {
                    
                    actionSheetNo = 6;
                    
                    UIActionSheet *sheet = [[UIActionSheet alloc]
                                            initWithTitle:@"URL選択"
                                            delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle:nil
                                            otherButtonTitles:[urlList objectAtIndex:0], 
                                                              [urlList objectAtIndex:1], 
                                                              [urlList objectAtIndex:2], 
                                                              [urlList objectAtIndex:3],
                                                              [urlList objectAtIndex:4],
                                                              [urlList objectAtIndex:5], nil];
                    [sheet showInView:self.view];
                }
            }
        }
    }
}

- (void)openPasteBoardUrl:(NSString *)urlString {
    
    if ( openUrlMode ) {
        
        openUrlMode = NO;
        
        //URLを設定
        appDelegate.openURL = urlString;
        
        return;
    }
    
    //直前にペーストボードから開いたURLでないかチェック
    if ( ![urlString isEqualToString:[d objectForKey:@"LastOpendPasteBoardURL"]] ) {
        
        //開いたURLを保存
        [d setObject:urlString forKey:@"LastOpendPasteBoardURL"];
        
        //URLを設定
        appDelegate.openURL = urlString;
    }
}

- (void)becomeActive:(NSNotification *)notification {
    
    //NSLog(@"WebViewEx becomeActive");
    
    actionSheetNo = 14;
    
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"動作選択"
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"Tweet", @"FastGoogle", @"ペーストボードのURLを開く", nil];

	[sheet showInView:self.view];
}

- (void)setSearchEngine {
    
    if ( ![EmptyCheck check:[d objectForKey:@"SearchEngine"]] ) [d setObject:@"Google" forKey:@"SearchEngine"];
    
    searchField.placeholder = [d objectForKey:@"SearchEngine"];
}

- (IBAction)pushSearchButton:(id)sender {
    
    actionSheetNo = 0;
    
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"検索エンジン切り替え"
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"Google", @"Amazon", @"Yahoo!オークション", 
                                              @"Wikipedia", @"Twitter検索", @"Wikipedia (Suggestion)", nil];
    [sheet showInView:self.view];
}

- (IBAction)pushComposeButton:(id)sender {
 
    if ( downloading ) {
        
        actionSheetNo = 12;
        
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"ファイルダウンロード中です。\nダウンロードは継続されますが、閉じた場合はキャンセルが出来なくなります。"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:@"ブラウザを閉じる", nil];
        [sheet showInView:self.view];    
        
    }else {
    
        appDelegate.openURL = [[wv.request URL] absoluteString];
    
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)pushCloseButton:(id)sender {
    
    if ( downloading ) {
        
        actionSheetNo = 11;
        
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"ファイルダウンロード中です。\nダウンロードは継続されますが、閉じた場合はキャンセルが出来なくなります。"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:@"ブラウザを閉じる", nil];
        [sheet showInView:self.view];    
        
    }else {
     
        appDelegate.openURL = [d objectForKey:@"HomePageURL"];
        
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)pushReloadButton:(id)sender {
    
    if ( [self reachability] ) {
        
        if ( loading ) {
            
            [wv stopLoading];
            [ActivityIndicator off];
            reloadButton.image = reloadButtonImage;
            
        }else {
            
            [wv loadRequestWithString:accessURL];
        }
    }
}

- (IBAction)pushBackButton:(id)sender {
    
    if ( [self reachability] ) [wv goBack];
}

- (IBAction)pushForwardButton:(id)sender {
    
    if ( [self reachability] ) [wv goForward];
}

- (IBAction)pushMenuButton:(id)sender {
    
    actionSheetNo = 1;
    
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"機能選択"
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"開いているページを投稿", @"選択文字を引用して投稿", 
                                              @"選択文字で検索", @"保存", @"ブックマークに登録",
                                              @"Safariで開く", @"ホームページを変更", @"FastEverで開く", 
                                              @"PC版UAで開き直す", nil];
    [sheet showInView:self.view];
}

- (IBAction)pushBookmarkButton:(id)sender {
    
    openBookmark = YES;
    
    BookmarkViewController *dialog = [[BookmarkViewController alloc] init];
    dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:dialog animated:YES];
}

- (IBAction)enterSearchField:(id)sender {
    
    if ( [searchField.text isEqualToString:BLANK] ) {
        
        [searchField resignFirstResponder];
        
        return;
    }
    
    NSString *searchURL = nil;
    
    if ( [[d objectForKey:@"SearchEngine"] isEqualToString:@"Google"] ) {
        
        searchURL = @"http://www.google.co.jp/search?q=";
        
    }else if ( [[d objectForKey:@"SearchEngine"] isEqualToString:@"Amazon"] ) {
        
        searchURL = @"http://www.amazon.co.jp/s/field-keywords=";
        
    }else if ( [[d objectForKey:@"SearchEngine"] isEqualToString:@"Yahoo!オークション"] ) {
        
        searchURL = @"http://auctions.search.yahoo.co.jp/search?tab_ex=commerce&rkf=1&p=";
        
    }else if ( [[d objectForKey:@"SearchEngine"] isEqualToString:@"Wikipedia"] ) {
        
        searchURL = @"http://ja.m.wikipedia.org/wiki/";
        
    }else if ( [[d objectForKey:@"SearchEngine"] isEqualToString:@"Twitter"] ) {
        
        searchURL = @"https://mobile.twitter.com/search?q=";
    
    }else if ( [[d objectForKey:@"SearchEngine"] isEqualToString:@"Wikipedia (Suggestion)"] ) {
        
        searchURL = @"http://google.com/complete/search?output=toolbar&hl=ja&q=";
    }
    
    NSString *encodedSearchWord = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
                                                                                                (__bridge CFStringRef)searchField.text, 
                                                                                                NULL, 
                                                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]", 
                                                                                                kCFStringEncodingUTF8);
    
    if ( ![[d objectForKey:@"SearchEngine"] isEqualToString:@"Wikipedia (Suggestion)"] ) {
        
        [wv loadRequestWithString:[NSString stringWithFormat:@"%@%@", searchURL, encodedSearchWord]];
    
    }else {
        
        dispatch_queue_t globalQueue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
        dispatch_async( globalQueue, ^{
            dispatch_queue_t syncQueue = dispatch_queue_create( "info.ktysne.fastphototweet", NULL );
            dispatch_sync( syncQueue, ^{
                
                [ActivityIndicator on];
                
                NSString *xmlString = [[NSString alloc] initWithContentsOfURL:
                                       [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", searchURL, encodedSearchWord]]
                                                                     encoding:NSShiftJISStringEncoding
                                                                        error:nil];
                
                NSString *suggestion = [RegularExpression strRegExp:xmlString
                                                      regExpPattern:@"<suggestion data=\".{1,50}\"/><num_queries"];
                
                if ( ![EmptyCheck check:suggestion] ) {
                    
                    [ShowAlert error:@"サジェストがありません。"];
                    return;
                }
                
                suggestion = [ReplaceOrDelete deleteWordReturnStr:suggestion deleteWord:@"<suggestion data=\""];
                suggestion = [ReplaceOrDelete deleteWordReturnStr:suggestion deleteWord:@"\"/><num_queries"];
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    //UIの更新
                    searchField.text = suggestion;
                    searchField.placeholder = @"Wikipedia";
                });

                [d setObject:@"Wikipedia" forKey:@"SearchEngine"];
                [self enterSearchField:nil];
            });
            
            [ActivityIndicator off];
            dispatch_release(syncQueue);
        });
    }
}

- (IBAction)enterURLField:(id)sender {
    
    if ( [urlField.text isEqualToString:BLANK] ) {
        
        [urlField resignFirstResponder];
        
        return;
    }
    
    NSString *encodedUrl = [DeleteWhiteSpace string:urlField.text];
    [wv loadRequestWithString:encodedUrl];
}

- (IBAction)onUrlField: (id)sender {
    
    //URLフィールドが選択された場合はプロトコルありの物に差し替える
    urlField.text = [wv.request URL].absoluteString;
    
    editing = NO;

    [self shouldAutorotateToInterfaceOrientation:[[UIDevice currentDevice] orientation]];
}

- (IBAction)leaveUrlField: (id)sender {
    
    //URLフィールドから選択が外れた場合はプロトコルなしの表示にする
    urlField.text = [ProtocolCutter url:urlField.text];
    
    editing = NO;
    
    [self shouldAutorotateToInterfaceOrientation:[[UIDevice currentDevice] orientation]];
}

- (IBAction)onSearchField: (id)sender {
    
    editing = YES;
    
    [self shouldAutorotateToInterfaceOrientation:[[UIDevice currentDevice] orientation]];
}

- (IBAction)leaveSearchField: (id)sender {
    
    editing = NO;
    
    [self shouldAutorotateToInterfaceOrientation:[[UIDevice currentDevice] orientation]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //NSLog(@"No: %d Index: %d", actionSheetNo, buttonIndex);
    
    if ( actionSheetNo == 0 ) {
        
        NSString *searchEngineName = nil;
        
        if ( buttonIndex == 0 ) {
            searchEngineName = @"Google";
        }else if ( buttonIndex == 1 ) {
            searchEngineName = @"Amazon";
        }else if ( buttonIndex == 2 ) {
            searchEngineName = @"Yahoo!オークション";
        }else if ( buttonIndex == 3 ) {
            searchEngineName = @"Wikipedia";
        }else if ( buttonIndex == 4 ) {
            searchEngineName = @"Twitter";
        }else if ( buttonIndex == 5 ) {
            searchEngineName = @"Wikipedia (Suggestion)";
        }else {
            return;
        }
        
        searchField.placeholder = searchEngineName;
        [d setObject:searchEngineName forKey:@"SearchEngine"];
        [searchField becomeFirstResponder];
        
    }else if ( actionSheetNo == 1 ) {
        
        if ( buttonIndex == 0 ) {
            
            NSString *postText = BLANK;
            
            if ( [EmptyCheck check:[d objectForKey:@"WebPagePostFormat"]] ) {
                
                postText = [d objectForKey:@"WebPagePostFormat"];
                
            }else {
                
                postText = @" \"[title]\" [url] ";
                [d setObject:postText forKey:@"WebPagePostFormat"];
            }
            
            postText = [ReplaceOrDelete replaceWordReturnStr:postText 
                                                 replaceWord:@"[title]" 
                                                replacedWord:wv.pageTitle];
            
            postText = [ReplaceOrDelete replaceWordReturnStr:postText 
                                                 replaceWord:@"[url]" 
                                                replacedWord:[[wv.request URL] absoluteString]];
            
            appDelegate.postTextType = @"WebPage";
            appDelegate.postText = postText;
            
            [self pushComposeButton:nil];
        
        }else if ( buttonIndex == 1 ) {
            
            //NSLog(@"selectString: %@", wv.selectString);
            
            if ( [EmptyCheck check:wv.selectString] ) {
                
                actionSheetNo = 7;
                
                UIActionSheet *sheet = [[UIActionSheet alloc]
                                        initWithTitle:@"引用投稿"
                                        delegate:self
                                        cancelButtonTitle:@"Cancel"
                                        destructiveButtonTitle:nil
                                        otherButtonTitles:@"選択文字を投稿", @"選択文字に引用符を付けて投稿",
                                        @"URL･タイトルと選択文字を投稿", nil];
                [sheet showInView:self.view];
                
            }else {
                
                [ShowAlert error:@"文字が選択されていません。"];
            }
        
        }else if ( buttonIndex == 2 ) {
            
            actionSheetNo = 8;
            
            UIActionSheet *sheet = [[UIActionSheet alloc]
                                    initWithTitle:@"選択文字検索"
                                    delegate:self
                                    cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                    otherButtonTitles:@"Google", @"Amazon", @"Yahoo!オークション", 
                                    @"Wikipedia", @"Twitter検索", @"Wikipedia (Suggestion)", nil];
            [sheet showInView:self.view];
        
        }else if ( buttonIndex == 3 ) {
            
            if ( [EmptyCheck check:urlField.text] ) {
                
                NSError *error = nil;
                NSString *documentTitle = wv.pageTitle;
                
                NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@".*[0-9,]+×[0-9,]+ ?(pixels|ピクセル)$" 
                                                                                        options:0 
                                                                                          error:&error];
                
                NSTextCheckingResult *match = [regexp firstMatchInString:documentTitle 
                                                                 options:0 
                                                                   range:NSMakeRange(0, documentTitle.length)];
                
                @autoreleasepool {
                    
                    [grayView performSelectorInBackground:@selector(on) withObject:nil];
                }
                
                if ( match.numberOfRanges != 0 ) {
                    
                    //NSLog(@"Image save");
                    
                    @autoreleasepool {
                        
                        //画像保存開始
                        [self performSelectorInBackground:@selector(saveImage) withObject:nil];
                    }
                    
                }else {
                    
                    //NSLog(@"File save");
                    
                    //ファイル保存開始
                    [self selectDownloadUrl];
                }
            }
            
        }else if ( buttonIndex == 4 ) {
            
            if ( ![EmptyCheck check:[d arrayForKey:@"Bookmark"]] ) {
                
                [d setObject:[NSArray array] forKey:@"Bookmark"];
            }
            
            NSMutableArray *bookMarkArray = [[NSMutableArray alloc] initWithArray:[d arrayForKey:@"Bookmark"]];
            
            //登録済みURLのチェック
            BOOL check = YES;
            for ( NSDictionary *dic in bookMarkArray ) {
                
                if ( [[dic objectForKey:@"URL"] isEqualToString:[[wv.request URL] absoluteString]] ) {
                    
                    check = NO;
                }
            }
            
            if ( check ) {
                
                NSMutableDictionary *addBookmark = [NSMutableDictionary dictionaryWithObject:wv.pageTitle forKey:@"Title"];
                [addBookmark setValue:[[wv.request URL] absoluteString] forKey:@"URL"];
                
                [bookMarkArray addObject:addBookmark];
                
                [d setObject:bookMarkArray forKey:@"Bookmark"];
                
            }else {
                
                [ShowAlert error:@"登録済みのURLです。"];
            }
            
        }else if ( buttonIndex == 5 ) {
            
            //Safariで開く
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:accessURL]];
        
        }else if ( buttonIndex == 6 ) {
            
            alertTextNo = 1;
            
            alert = [[UIAlertView alloc] initWithTitle:@"ホームページURL" 
                                               message:@"\n"
                                              delegate:self 
                                     cancelButtonTitle:@"キャンセル" 
                                     otherButtonTitles:@"確定", nil];
            
            alertText = [[UITextField alloc] initWithFrame:CGRectMake(12, 40, 260, 25)];
            [alertText setBackgroundColor:[UIColor whiteColor]];
            alertText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            alertText.delegate = self;
            
            [alert addSubview:alertText];
            [alert show];
            [alertText becomeFirstResponder];
            
        }else if ( buttonIndex == 7 ) {
            
            if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fastever://"]] ) {
                
                NSString *reqUrl = BLANK;
            
                if ( [EmptyCheck check:wv.selectString] ) {
                    
                    reqUrl = [NSString stringWithFormat:@"fastever://?text=%@\n%@\n>>%@\n", wv.pageTitle, accessURL, wv.selectString];
                    
                }else {
                    
                    reqUrl = [NSString stringWithFormat:@"fastever://?text=%@\n%@\n", wv.pageTitle, accessURL];
                }
                
                [[UIApplication sharedApplication] openURL:
                 [NSURL URLWithString:(__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                            (__bridge CFStringRef)reqUrl, 
                                                                                                            NULL, 
                                                                                                            NULL, 
                                                                                                            kCFStringEncodingUTF8)]];
            
            }else {
                
                [ShowAlert error:@"FastEverをインストール後使用してください。"];
            }
        
        //PC版UAで開き直す
        }else if ( buttonIndex == 8 ) {
            
            appDelegate.pcUaMode = [NSNumber numberWithInt:1];
            [d setObject:@"FireFox" forKey:@"UserAgent"];
            [self pushComposeButton:nil];
        }
        
    }else if ( actionSheetNo == 2 || actionSheetNo == 3 || actionSheetNo == 4 || actionSheetNo == 5 || actionSheetNo == 6 ) {
        
        if ( buttonIndex == actionSheetNo ) {
            
            appDelegate.openURL = [d objectForKey:@"HomePageURL"];
            
        }else {
            
            [self openPasteBoardUrl:[urlList objectAtIndex:buttonIndex]];
        }
        
        [urlList removeAllObjects];
        
        //ページをロード
        [wv loadRequestWithString:appDelegate.openURL];
        
        appDelegate.isBrowserOpen = [NSNumber numberWithInt:1];
        
    }else if ( actionSheetNo == 7 ) {
        
        appDelegate.postTextType = @"Quote";
        
        if ( buttonIndex == 0 ) {
        
            if ( ![EmptyCheck check:wv.selectString] ) return;
            
            appDelegate.postText = wv.selectString;
            [self pushComposeButton:nil];
        
        }else if ( buttonIndex == 1 ) {
        
            if ( ![EmptyCheck check:wv.selectString] ) return;
            
            appDelegate.postText = [NSString stringWithFormat:@">>%@", wv.selectString];
            [self pushComposeButton:nil];
        
        }else if ( buttonIndex == 2 ) {
        
            if ( ![EmptyCheck check:wv.selectString] ) return;
            
            NSString *postText = BLANK;
            
            if ( [EmptyCheck check:[d objectForKey:@"QuoteFormat"]] ) {
                
                postText = [d objectForKey:@"QuoteFormat"];
                
            }else {
                
                postText = @" \"[title]\" [url] >>[quote]";
                [d setObject:postText forKey:@"QuoteFormat"];
            }
            
            postText = [ReplaceOrDelete replaceWordReturnStr:postText 
                                                 replaceWord:@"[title]" 
                                                replacedWord:wv.pageTitle];
            
            postText = [ReplaceOrDelete replaceWordReturnStr:postText 
                                                 replaceWord:@"[url]" 
                                                replacedWord:[[wv.request URL] absoluteString]];
            
            postText = [ReplaceOrDelete replaceWordReturnStr:postText 
                                                 replaceWord:@"[quote]" 
                                                replacedWord:wv.selectString];
            
            appDelegate.postText = postText;
            
            [self pushComposeButton:nil];
        
        }else {
            
            appDelegate.postTextType = BLANK;
        }
    
    }else if ( actionSheetNo == 8 ) {
        
        if ( [EmptyCheck check:wv.selectString] ) {
            
            NSString *searchEngineName = nil;
            
            if ( buttonIndex == 0 ) {
                searchEngineName = @"Google";
            }else if ( buttonIndex == 1 ) {
                searchEngineName = @"Amazon";
            }else if ( buttonIndex == 2 ) {
                searchEngineName = @"Yahoo!オークション";
            }else if ( buttonIndex == 3 ) {
                searchEngineName = @"Wikipedia";
            }else if ( buttonIndex == 4 ) {
                searchEngineName = @"Twitter";
            }else if ( buttonIndex == 5 ) {
                searchEngineName = @"Wikipedia (Suggestion)";
            }else {
                return;
            }
            
            searchField.text = wv.selectString;
            searchField.placeholder = searchEngineName;
            [d setObject:searchEngineName forKey:@"SearchEngine"];
            
            [self enterSearchField:nil];
        }
    
    }else if ( actionSheetNo == 9 ) {
        
        if ( buttonIndex == 0 ) {
            
            [self requestStart:accessURL];
            
        }else if ( buttonIndex == 1 ) {
            
            [self requestStart:urlField.text];
            
        }else {
            
            [grayView off];
        }
        
    }else if ( actionSheetNo == 10 ) {
        
        if ( buttonIndex == 0 ) {
            
            [self requestStart:accessURL];
            
        }else if ( buttonIndex == 1 ) {
            
            [self requestStart:[NSString stringWithFormat:@"http://%@", urlField.text]];
            
        }else if ( buttonIndex == 2 ) {
            
            [self requestStart:[NSString stringWithFormat:@"https://%@", urlField.text]];
            
        }else {
            
            [grayView off];
        }
    
    }else if ( actionSheetNo == 11 ) {
        
        if ( buttonIndex == 0 ) {
            
            appDelegate.openURL = [d objectForKey:@"HomePageURL"];
            
            [self dismissModalViewControllerAnimated:YES];
        }
        
    }else if ( actionSheetNo == 12 ) {
        
        if ( buttonIndex == 0 ) {
            
            appDelegate.openURL = [[wv.request URL] absoluteString];
            
            [self dismissModalViewControllerAnimated:YES];
        }
    
    }else if ( actionSheetNo == 13 ) {
        
        [ActivityIndicator off];
        
        if ( buttonIndex == 0 ) {
            
            [self requestStart:downloadUrl];
        }
        
    }else if ( actionSheetNo == 14 ) {
        
        @try {
            
            if ( buttonIndex == 0 ) {
                
                appDelegate.postText = pboard.string;
                
                [self pushComposeButton:nil];
                
            }else if ( buttonIndex == 1 ) {
                
                [wv loadRequestWithString:[GoogleSearch createUrl:pboard.string]];
                
            }else if ( buttonIndex == 2 ) {
                
                openUrlMode = YES;
                [self checkPasteBoardUrlOption];
            }
            
        }@catch ( NSException *e ) {}
    }
}

- (void)saveImage {
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:accessURL]];
    UIImage *image = [[UIImage alloc] initWithData:data];
    UIImageWriteToSavedPhotosAlbum(image, 
                                   self, 
                                   @selector(savingImageIsFinished:didFinishSavingWithError:contextInfo:), 
                                   nil);
    image = nil;
}

- (void)savingImageIsFinished:(UIImage *)image
     didFinishSavingWithError:(NSError *)error
                  contextInfo:(void *)contextInfo {
    
    if( error ){
        
        [ShowAlert error:@"保存に失敗しました。"];
        
    }else {
        
        [ShowAlert title:@"保存完了" message:@"カメラロールに保存しました。"];
    }
    
    [grayView off];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ( alertTextNo == 1 ) {
    
        if ( buttonIndex == 1 ) {
     
            //NSLog(@"SetHomePage: %@", alertText.text);
            [d setObject:alertText.text forKey:@"HomePageURL"];
            
            alertTextNo = 0;
            alertText.text = BLANK;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)sender {

    //NSLog(@"textFieldShouldReturn");
    
    if ( alertTextNo == 1 ) {
    
        //NSLog(@"SetHomePage: %@", alertText.text);
        [d setObject:alertText.text forKey:@"HomePageURL"];
        
        alertTextNo = 0;
        alertText.text = BLANK;
        
        //キーボードを閉じる
        [sender resignFirstResponder];
        
        //アラートを閉じる
        [alert dismissWithClickedButtonIndex:1 animated:YES];
    }
            
    return YES;
}

/* WebView */

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType {
    
    accessURL = [[request URL] absoluteString];
    
    //フルサイズ取得が有効
    if ( [d boolForKey:@"FullSizeImage"] ) {
        
        //画像サービスのURLかスキャン
        NSString *fullSizeImageUrl = [FullSizeImage urlString:accessURL];
        
        //スキャン済みURLが変わっていたらアクセスし直し
        if ( ![fullSizeImageUrl isEqualToString:accessURL] ) {
            
            [wv loadRequestWithString:fullSizeImageUrl];
            
            return NO;
        }
    }
    
    //Amazonのアフィリンクの場合無効化して再アクセス
    if ( [RegularExpression boolRegExp:accessURL regExpPattern:@"https?://(www\\.)?amazon\\.co\\.jp/((exec/obidos|o)/ASIN|dp)/[A-Z0-9]{10}(/|\\?tag=)[-_a-zA-Z0-9]+-22/?"] ) {
        
        NSString *affiliateCuttedUrl = [AmazonAffiliateCutter string:accessURL];
        
        if ( ![affiliateCuttedUrl isEqualToString:accessURL] ) {
            
            [wv loadRequestWithString:affiliateCuttedUrl];
            
            return NO;
        }
    }
    
    [self performSelectorInBackground:@selector(showDownloadMenu:) withObject:accessURL];
    
    loading = YES;
    
    if ( ![[[request URL] absoluteString] isEqualToString:@"about:blank"] ) {
        
        //NSLog(@"shouldStartLoadWithRequest: %@", [[request URL] absoluteString]);
        
        urlField.text = [ProtocolCutter url:[[request URL] absoluteString]];
    }
    
    [ActivityIndicator on];
    [self updateWebBrowser];
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    //NSLog(@"webViewDidFinishLoad: %@", [[webView.request URL] absoluteString]);
    
    accessURL = [[webView.request URL] absoluteString];
    urlField.text = [ProtocolCutter url:[[webView.request URL] absoluteString]];
    
    loading = NO;
    [ActivityIndicator off];
    [self updateWebBrowser];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    if ( error.code != -999 && error.code != 102 && error.code != 204) {
        
        //NSLog(@"%@", error.description);
        
        [ShowAlert error:error.localizedDescription];
        
        loading = NO;
        [ActivityIndicator off];
        [self updateWebBrowser];
    }
}

- (void)updateWebBrowser {
    
    //NSLog(@"updateWebBrowser");

    [self backForwordButtonVisible];
    [self reloadStopButton];
}

- (void)reloadStopButton {
    
    loading ? ( reloadButton.image = stopButtonImage ) : ( reloadButton.image = reloadButtonImage );
}

- (void)backForwordButtonVisible {
    
    wv.canGoBack ? ( backButton.enabled = YES ) : ( backButton.enabled = NO );
    wv.canGoForward ? ( forwardButton.enabled = YES ) : ( forwardButton.enabled = NO );
}

/* WebViewここまで */

- (void)selectDownloadUrl {
    
    if ( [accessURL hasSuffix:@"/"] ) {
        
        if ( [[NSString stringWithFormat:@"http://%@/", urlField.text] isEqualToString:accessURL] ||
            [[NSString stringWithFormat:@"https://%@/", urlField.text] isEqualToString:accessURL] ) {
            
            [self requestStart:accessURL];
            
            return;
        }
    }
    
    if ( [[NSString stringWithFormat:@"http://%@", urlField.text] isEqualToString:accessURL] ||
         [[NSString stringWithFormat:@"https://%@", urlField.text] isEqualToString:accessURL] ) {
        
        [self requestStart:accessURL];
        
    }else {
        
        NSString *buttonTitle0 = accessURL;
        NSString *buttonTitle1 = nil;
        NSString *buttonTitle2 = nil;
        
        if ( [urlField.text hasPrefix:@"http"] ) {
            
            buttonTitle1 = urlField.text;
            
            actionSheetNo = 9;
            
            UIActionSheet *sheet = [[UIActionSheet alloc]
                                    initWithTitle:@"保存URL選択"
                                    delegate:self
                                    cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                    otherButtonTitles:buttonTitle0, buttonTitle1, nil];
            
            [sheet showInView:self.view];
            
        }else {
            
            buttonTitle1 = [NSString stringWithFormat:@"http://%@", urlField.text];
            buttonTitle2 = [NSString stringWithFormat:@"https://%@", urlField.text];
            
            actionSheetNo = 10;
            
            UIActionSheet *sheet = [[UIActionSheet alloc]
                                    initWithTitle:@"保存URL選択"
                                    delegate:self
                                    cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                    otherButtonTitles:buttonTitle0, buttonTitle1, buttonTitle2, nil];
            
            [sheet showInView:self.view];
        }
    }
}

/* 非同期通信ダウンロード */

- (void)requestStart:(NSString *)url {
    
    //NSLog(@"requestStart: %@", downloadUrl);

    //キャッシュの削除
    NSURLCache *cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    
    //ダウンロード進捗表示用のラベルとバーを表示
    bytesLabel.hidden = NO;
    progressBar.hidden = NO;
    downloadCancelButton.hidden = NO;

    //初期化
    downloading = YES;
    bytesLabel.text = @"0 / 0 bytes";
    totalbytes = 0.0;
    loadedbytes = 0.0;
    asyncConnection = nil;
    asyncData = nil;
    
    //ファイル名を生成
    saveFileName = [url lastPathComponent]; 
    
    //ダウンロードリクエスト開始
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    asyncConnection = [[NSURLConnection alloc] initWithRequest:request 
                                                      delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    //NSLog(@"didReceiveResponse: %lldbytes", [response expectedContentLength]);
    
    //データを初期化
	asyncData = [[NSMutableData alloc] initWithData:0];
    
    //総ファイルサイズをセット
    totalbytes = [response expectedContentLength];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{

    //NSLog(@"didReceiveData");
    
    //受信したデータを追加
	[asyncData appendData:data];
    
    //受信したデータサイズを追加
    loadedbytes += [data length];
    
    //UIの更新
    [progressBar setProgress:(loadedbytes / totalbytes)];
    bytesLabel.text = [NSString stringWithFormat:@"%.0f / %.0f bytes", loadedbytes, totalbytes];
}

- (IBAction)pushDownloadCancelButton:(id)sender {
    
    [asyncConnection cancel];

    [ShowAlert title:saveFileName message:@"ダウンロードを中断しました。"];
    
    [self endDownload];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

    //NSLog(@"didFailWithError");
    
    [ShowAlert error:@"ダウンロードに失敗しました。"];
    
    [self endDownload];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    //NSLog(@"connectionDidFinishLoading");
    
    //Documentフォルダにデータを保存
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *savePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:saveFileName];
    [manager createFileAtPath:savePath 
                     contents:asyncData 
                   attributes:nil];
    
    [ShowAlert title:@"保存完了" 
             message:@"アプリ内ドキュメントフォルダに保存されました。ファイルへはPCのiTunesからアクセス出来ます。"];
    
    [self endDownload];
}

- (void)endDownload {
    
    [grayView off];
    asyncData = nil;
    asyncConnection = nil;
    downloading = NO;
    bytesLabel.hidden = YES;
    progressBar.hidden = YES;
    downloadCancelButton.hidden = YES;
}

- (void)showDownloadMenu:(NSString *)url {
    
    BOOL result = NO;
    NSString *extension = [[url pathExtension] lowercaseString];
    
    for ( NSString *temp in EXTENSIONS ) {
        
        if ( [temp isEqualToString:extension] ) {
            
            downloadUrl = url;
            actionSheetNo = 13;
            
            UIActionSheet *sheet = [[UIActionSheet alloc]
                                    initWithTitle:@"保存確認"
                                    delegate:self
                                    cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                    otherButtonTitles:@"保存する", nil];
            
            [sheet showInView:self.view];
            
            result = YES;
        }
        
        if ( result ) break;
    }
}

/* 非同期通信ダウンロードここまで */

- (BOOL)reachability {
    
    BOOL result = NO;
    
    if ( [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable ) {
        
        result = YES;
        
    }else {
        
        [ShowAlert error:@"インターネットに接続されていません。"];
    }
    
    return result;
}

- (void)viewDidUnload {
    
    //NSLog(@"WebViewExController viewDidUnload");
    
    appDelegate.isBrowserOpen = [NSNumber numberWithInt:0];
    appDelegate.openURL = [d objectForKey:@"HomePageURL"];
    
    [self setTopBar:nil];
    [self setBottomBar:nil];
    [self setSearchButton:nil];
    [self setCloseButton:nil];
    [self setReloadButton:nil];
    [self setBackButton:nil];
    [self setForwardButton:nil];
    [self setMenuButton:nil];
    [self setFlexibleSpace:nil];
    [self setUrlField:nil];
    [self setSearchField:nil];
    [self setComposeButton:nil];
    [self setWv:nil];
    [self setBytesLabel:nil];
    [self setProgressBar:nil];
    [self setDownloadCancelButton:nil];
    [self setBookmarkButton:nil];
    [super viewDidUnload];
}

- (void)rotateView:(int)mode {
 
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.05];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationRepeatCount:1.0];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];

    //縦
    if ( mode == 0 ) {
        
        if ( fullScreen ) {
            
            topBar.frame = CGRectMake(0, -44, 320, 44);
            wv.frame = CGRectMake(0, 0, 320, 460);
            bottomBar.frame = CGRectMake(0, 460, 320, 44);
            
            if ( editing ) {
                
                urlField.frame = CGRectMake(12, -44, 75, 31);
                searchField.frame = CGRectMake(97, -44, 180, 31);
                
            }else {
                
                urlField.frame = CGRectMake(12, -44, 180, 31);
                searchField.frame = CGRectMake(202, -44, 75, 31);
            }
            
        }else {
            
            topBar.frame = CGRectMake(0, 0, 320, 44);
            wv.frame = CGRectMake(0, 44, 320, 372);
            bottomBar.frame = CGRectMake(0, 416, 320, 44);
            
            if ( editing ) {
                
                urlField.frame = CGRectMake(12, 7, 75, 31);
                searchField.frame = CGRectMake(97, 7, 180, 31);
                
            }else {
                
                urlField.frame = CGRectMake(12, 7, 180, 31);
                searchField.frame = CGRectMake(202, 7, 75, 31);
            }    
        }
     
    //横
    }else {
        
        if ( fullScreen ) {
            
            topBar.frame = CGRectMake(0, -44, 480, 44);
            wv.frame = CGRectMake(0, 0, 480, 300);
            bottomBar.frame = CGRectMake(0, 300, 480, 44);
            
            if ( editing ) {
                
                urlField.frame = CGRectMake(12, -44, 135, 31);
                searchField.frame = CGRectMake(157, -44, 280, 31);
                
            }else {
                
                urlField.frame = CGRectMake(12, -44, 280, 31);
                searchField.frame = CGRectMake(302, -44, 135, 31);
            }
            
        }else {
            
            topBar.frame = CGRectMake(0, 0, 480, 44);
            wv.frame = CGRectMake(0, 44, 480, 212);
            bottomBar.frame = CGRectMake(0, 256, 480, 44);
            
            if ( editing ) {
                
                urlField.frame = CGRectMake(12, 7, 135, 31);
                searchField.frame = CGRectMake(157, 7, 280, 31);
                
            }else {
                
                urlField.frame = CGRectMake(12, 7, 280, 31);
                searchField.frame = CGRectMake(302, 7, 135, 31);
            }
        }
    }
    
    [UIView commitAnimations];
}

- (IBAction)fullScreenGesture:(id)sender {
        
    if ( fullScreen ) {
     
        fullScreen = NO;
        
    }else {
        
        fullScreen = YES;
    }
    
    [self shouldAutorotateToInterfaceOrientation:[[UIDevice currentDevice] orientation]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    if ( interfaceOrientation == UIInterfaceOrientationPortrait ) {
        
        [self rotateView:0];
        
        return YES;
        
    }else if ( interfaceOrientation == UIInterfaceOrientationLandscapeLeft || 
               interfaceOrientation == UIInterfaceOrientationLandscapeRight ) {
        
        [self rotateView:1];
                
        return YES;
        
    }else if ( interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ) {
        
        return NO;
    }
    
    return YES;
}

- (void)dealloc {
    
    appDelegate.isBrowserOpen = [NSNumber numberWithInt:0];
    
    if ( wv.loading ) [wv stopLoading];
    wv.delegate = nil;
    [wv removeFromSuperview];
    
    [ActivityIndicator visible:NO];
}

@end
