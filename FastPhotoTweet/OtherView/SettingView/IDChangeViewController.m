//
//  SettingViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "IDChangeViewController.h"
#import "TableViewCellController.h"

@implementation IDChangeViewController
@synthesize topBar;
@synthesize closeButton;
@synthesize tv;
@synthesize sv;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self ) {
        
        //NSLog(@"IDChangeView init");
        
        //初期化処理
        ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        if ( appDelegate.twitpicLinkMode ) {
            
            twitpicLinkMode = YES;
            
            [ShowAlert title:@"アカウントリンク" message:@"iOSに登録されているTwitterアカウントと、認証を行ったアカウントのリンクを行います。先程認証を行ったアカウントを選択してください。"];
        }
        
        if ( twitterAccounts != 0 ) {
            
            //可変長配列の初期化
            accountList = [NSMutableArray array];
            
            //アカウントが存在する場合screen_nameを保存
            for ( int i = 0; i < twitterAccounts.count; i++ ) {
                
                ACAccount *twAccount = [[twitterAccounts objectAtIndex:i] retain];
                [accountList addObject:twAccount.username];
                [twAccount release];
            }
            
            [accountList retain];
            //NSLog(@"accountList: %@", accountList);
        }
        
        //NSLog(@"AccountCount: %d", accountList.count);
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if ( appDelegate.twitpicLinkMode ) {
        
        [topBar setRightBarButtonItem:nil animated:NO];
    }
    
    [tv flashScrollIndicators];
    
    //NSLog(@"IDChangeView viewDidLoad");
}

- (IBAction)pushCloseButton:(id)sender {
    
    //NSLog(@"IDChangeView close");
    
    twitpicLinkMode = NO;
    appDelegate.twitpicLinkMode = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

/* TableView必須メソッド */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //TableViewの要素数(Twitterアカウント数)を返す
	return [accountList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	//NSLog(@"CreateCell");
    
    //TableViewCellを生成
	static NSString *identifier = @"TableViewCell";
	TableViewCell *cell = (TableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	cell.numberLabel.textColor = [UIColor blackColor];
	cell.textLabel.textColor = [UIColor blackColor];
    
	if (cell == nil) {
        
		TableViewCellController *controller = [[TableViewCellController alloc] initWithNibName:identifier bundle:nil];
		cell = (TableViewCell *)controller.view;
		[controller autorelease];
	}
    
    //テキストをセット
    //使用中のアカウントにチェックマークを付ける
    if ( indexPath.row == [USER_DEFAULTS integerForKey:@"UseAccount"] ) {
        cell.numberLabel.text = [NSString stringWithFormat:@"✓ %d", indexPath.row + 1];
    } else {
        cell.numberLabel.text = [NSString stringWithFormat:@"　 %d", indexPath.row + 1];
    }
    
    cell.textLabel.text = [accountList objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ( twitpicLinkMode ) {
        
        twitpicLinkMode = NO;
        
        //NSLog(@"SelectAccount: %@", [accountList objectAtIndex:indexPath.row]);
        
        //仮登録された情報の名前を生成
        NSString *searchAccountName = [NSString stringWithFormat:@"OAuthAccount_%d", [USER_DEFAULTS integerForKey:@"AccountCount"]];
        
        //NSLog(@"searchAccountName: %@", searchAccountName);
        
        //設定からアカウントリストを読み込む
        NSMutableDictionary *dic = [[USER_DEFAULTS dictionaryForKey:@"OAuthAccount"] mutableCopy];
        
        //key, secretを取得
        NSString *key = [[dic objectForKey:searchAccountName] objectAtIndex:0];
        NSString *secret = [[dic objectForKey:searchAccountName] objectAtIndex:1];
        
        //配列を生成
        NSArray *accountData = [NSArray arrayWithObjects:key, secret, nil];
        
        //仮情報を削除
        [dic removeObjectForKey:searchAccountName];
        
        //アカウント情報を登録
        [dic setObject:accountData forKey:[accountList objectAtIndex:indexPath.row]];
        
        //設定に反映
        NSDictionary *saveDic = [[NSDictionary alloc] initWithDictionary:dic];
        [USER_DEFAULTS setObject:saveDic forKey:@"OAuthAccount"];
        [saveDic release];
        [dic release];
        
        [USER_DEFAULTS setObject:@"Twitpic" forKey:@"PhotoService"];
        appDelegate.needChangeAccount = YES;
        appDelegate.twitpicLinkMode = NO;
        
        //NSLog(@"OAuthAccount: %@", [USER_DEFAULTS dictionaryForKey:@"OAuthAccount"]);
    }
    
    //使用アカウント情報を保存
    [USER_DEFAULTS setInteger:indexPath.row forKey:@"UseAccount"];
    
    //セルの選択状態を解除
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //アカウントが切り替わったことを通知
    NSNotification *notification =[NSNotification notificationWithName:@"ChangeAccount"
                                                                object:self
                                                              userInfo:nil];
    
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

/* TableView必須メソッドここまで */

- (void)viewDidUnload {
    
    [self setSv:nil];
    [self setTopBar:nil];
    [self setCloseButton:nil];
    [self setTv:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotate {
    
    if ( [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait ) return YES;
    
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc {
    
    //NSLog(@"IDChangeView dealloc");
    
    [accountList release];
    
    [sv release];
    [topBar release];
    [closeButton release];
    [tv release];
    [super dealloc];
}

@end
