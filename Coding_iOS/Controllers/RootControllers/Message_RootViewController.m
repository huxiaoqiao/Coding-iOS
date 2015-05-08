//
//  Message_RootViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_Conversation @"ConversationCell"
#define kCellIdentifier_ToMessage @"ToMessageCell"

#import "Message_RootViewController.h"
#import "ODRefreshControl.h"
#import "Coding_NetAPIManager.h"
#import "PrivateMessages.h"
#import "ConversationCell.h"
#import "ConversationViewController.h"
#import "ToMessageCell.h"
#import "TipsViewController.h"
#import "UsersViewController.h"
#import "UnReadManager.h"
#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"
#import "SVPullToRefresh.h"

@interface Message_RootViewController ()
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@property (strong, nonatomic) PrivateMessages *myPriMsgs;
@property (strong, nonatomic) NSMutableDictionary *notificationDict;
@end

@implementation Message_RootViewController

#pragma mark TabBar
- (void)tabBarItemClicked{
    if (_myTableView.contentOffset.y > 0) {
        [_myTableView setContentOffset:CGPointZero animated:YES];
    }else{
        [self refresh:YES];
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[UnReadManager shareManager] addObserver:self forKeyPath:kUnReadKey_messages options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [[UnReadManager shareManager] addObserver:self forKeyPath:kUnReadKey_notifications options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"消息";
    _myPriMsgs = [[PrivateMessages alloc] init];
    [self refresh:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refresh:NO];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UnReadManager shareManager] updateUnRead];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc{
    
    [[UnReadManager shareManager] removeObserver:self forKeyPath:kUnReadKey_messages];
    [[UnReadManager shareManager] removeObserver:self forKeyPath:kUnReadKey_notifications];
    
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;

}

- (void)loadView{
    [super loadView];
    CGRect frame = [UIView frameWithOutNavTab];
    self.view = [[UIView alloc] initWithFrame:frame];

    
    UIButton *sendMsgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendMsgBtn setFrame:CGRectMake(0, 0, 19, 19)];
    [sendMsgBtn setImage:[UIImage imageNamed:@"tweetBtn_Nav"] forState:UIControlStateNormal];
    [sendMsgBtn addTarget:self action:@selector(sendMsgBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sendMsgBtn];
    
    
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = kColorTableBG;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[ConversationCell class] forCellReuseIdentifier:kCellIdentifier_Conversation];
        [tableView registerClass:[ToMessageCell class] forCellReuseIdentifier:kCellIdentifier_ToMessage];
        [self.view addSubview:tableView];
        tableView;
    });
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    __weak typeof(self) weakSelf = self;
    [_myTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf refreshMore];
    }];
    [self refreshBadgeTip];
}

- (void)sendMsgBtnClicked:(id)sender{
    UsersViewController *vc = [[UsersViewController alloc] init];
    vc.curUsers = [Users usersWithOwner:[Login curLoginUser] Type:UsersTypeFriends_Message];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)refresh:(BOOL)animated{
    if (_myPriMsgs.isLoading) {
        return;
    }
    _myPriMsgs.willLoadMore = NO;
    __weak typeof(self) weakSelf = self;
    if (animated) {
        [_refreshControl beginRefreshing];
    }
    [self sendRequest_PrivateMessages];
    
    [[Coding_NetAPIManager sharedManager] request_UnReadNotificationsWithBlock:^(id data, NSError *error) {
        if (data) {
            weakSelf.notificationDict = [NSMutableDictionary dictionaryWithDictionary:data];
            [weakSelf.myTableView reloadData];
        }
    }];
}

- (void)refreshMore{
    if (_myPriMsgs.isLoading || !_myPriMsgs.canLoadMore) {
        return;
    }
    _myPriMsgs.willLoadMore = YES;
    [self sendRequest_PrivateMessages];
}

- (void)sendRequest_PrivateMessages{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_PrivateMessages:_myPriMsgs andBlock:^(id data, NSError *error) {
        [weakSelf.refreshControl endRefreshing];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            [weakSelf.myPriMsgs configWithObj:data];
            [weakSelf.myTableView reloadData];
            weakSelf.myTableView.showsInfiniteScrolling = weakSelf.myPriMsgs.canLoadMore;
        }
    }];
}

#pragma mark Table M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 3;
    if (_myPriMsgs.list) {
        row += [_myPriMsgs.list count];
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < 3) {
        ToMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ToMessage forIndexPath:indexPath];
        switch (indexPath.row) {
            case 0:
                cell.type = ToMessageTypeAT;
                cell.unreadCount = [_notificationDict objectForKey:kUnReadKey_notification_AT];
                break;
            case 1:
                cell.type = ToMessageTypeComment;
                cell.unreadCount = [_notificationDict objectForKey:kUnReadKey_notification_Comment];
                break;
            default:
                cell.type = ToMessageTypeSystemNotification;
                cell.unreadCount = [_notificationDict objectForKey:kUnReadKey_notification_System];
                break;
        }
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:75];
        return cell;
    }else{
        ConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Conversation forIndexPath:indexPath];
        PrivateMessage *msg = [_myPriMsgs.list objectAtIndex:indexPath.row-3];
        cell.curPriMsg = msg;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:75];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight;
    if (indexPath.row < 3) {
        cellHeight = [ToMessageCell cellHeight];
    }else{
        cellHeight = [ConversationCell cellHeight];
    }
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < 3) {
        TipsViewController *vc = [[TipsViewController alloc] init];
        vc.myCodingTips = [CodingTips codingTipsWithType:indexPath.row];
        vc.notificationDict = _notificationDict;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        PrivateMessage *curMsg = [_myPriMsgs.list objectAtIndex:indexPath.row-3];
        ConversationViewController *vc = [[ConversationViewController alloc] init];
        User *curFriend = curMsg.friend;
        
        vc.myPriMsgs = [PrivateMessages priMsgsWithUser:curFriend];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//-----------------------------------Editing
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除会话";
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return (indexPath.row >= 3);
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView setEditing:NO animated:YES];
    PrivateMessage *msg = [_myPriMsgs.list objectAtIndex:indexPath.row-3];
    
    __weak typeof(self) weakSelf = self;
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:[NSString stringWithFormat:@"这将删除你和 %@ 的所有私信", msg.friend.name]];
    [actionSheet bk_setDestructiveButtonWithTitle:@"确认删除" handler:nil];
    [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
    [actionSheet bk_setDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        switch (index) {
            case 0:
                [weakSelf removeConversation:msg inTableView:tableView];
                break;
            default:
                break;
        }
    }];
    [actionSheet showInView:kKeyWindow];
}

- (void)removeConversation:(PrivateMessage *)curMsg inTableView:(UITableView *)tableView{
    NSLog(@"removeConversationWithFriend : %@", curMsg.friend.name);
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_DeletePrivateMessagesWithObj:curMsg andBlock:^(id data, NSError *error) {
        if (data) {
            [weakSelf.myPriMsgs.list removeObject:data];
            [weakSelf.myTableView reloadData];
        }
    }];
}


#pragma mark KVO_UnRead
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:kUnReadKey_messages] || [keyPath isEqualToString:kUnReadKey_notifications]){
        [self refreshBadgeTip];
    }
}

- (void)refreshBadgeTip{
    NSString *badgeTip = @"";
    NSNumber *unreadCount = [NSNumber numberWithInteger:([UnReadManager shareManager].messages.integerValue +[UnReadManager shareManager].notifications.integerValue)];
    if (unreadCount.integerValue > 0) {
        if (unreadCount.integerValue > 99) {
            badgeTip = @"99+";
        }else{
            badgeTip = unreadCount.stringValue;
        }
    }
    [self.rdv_tabBarItem setBadgeValue:badgeTip];
}


@end
