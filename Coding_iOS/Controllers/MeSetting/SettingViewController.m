//
//  SettingViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-26.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_TitleDisclosure @"TitleDisclosureCell"
#import "SettingViewController.h"
#import "TitleDisclosureCell.h"
#import "Login.h"
#import "AppDelegate.h"
#import "SettingAccountViewController.h"
#import "SettingPasswordViewController.h"
#import "AboutViewController.h"
#import "FeedbackViewController.h"

@interface SettingViewController ()
@property (strong, nonatomic) UITableView *myTableView;
@end

@implementation SettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView{
    CGRect frame = [UIView frameWithOutNav];
    self.view = [[UIView alloc] initWithFrame:frame];
    self.title = @"设置";
    
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TitleDisclosureCell class] forCellReuseIdentifier:kCellIdentifier_TitleDisclosure];
        [self.view addSubview:tableView];
        tableView;
    });
    _myTableView.tableFooterView = [self tableFooterView];
}

#pragma mark TableM
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    switch (section) {
        case 0:
            row = 2;
            break;
        case 1:
            row = 2;
            break;
        default:
            row = 1;
            break;
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TitleDisclosureCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleDisclosure forIndexPath:indexPath];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    [cell setTitleStr:@"账号信息"];
                    break;
                default:
                    [cell setTitleStr:@"密码设置"];
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    [cell setTitleStr:@"意见反馈"];
                    break;
                case 1:
                    [cell setTitleStr:@"去评分"];
                    break;
                default:
                    [cell setTitleStr:@"分享给好友"];
                    break;
            }
            break;
        default:
            [cell setTitleStr:@"关于Coding"];
            break;
    }
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:20];
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
    headerView.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0://账号信息
                {
                    SettingAccountViewController *vc = [[SettingAccountViewController alloc] init];
                    vc.myUser = self.myUser;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 1://密码设置
                {
                    SettingPasswordViewController *vc = [[SettingPasswordViewController alloc] init];
                    vc.myUser = self.myUser;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:{//意见反馈
                    FeedbackViewController *vc = [[FeedbackViewController alloc] init];
                    vc.myUser = self.myUser;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 1:{//评分
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppUrl]];
                }
                    break;
                default:
                    break;
            }
            break;
        default:{//关于
            AboutViewController *vc = [[AboutViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
    }
}

- (UIView*)tableFooterView{
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 90)];
    UIButton *loginBtn = [UIButton buttonWithStyle:StrapWarningStyle andTitle:@"退出" andFrame:CGRectMake(10, 0, kScreen_Width-10*2, 45) target:self action:@selector(loginOutBtnClicked:)];
    [loginBtn setCenter:footerV.center];
    [footerV addSubview:loginBtn];
    return footerV;
}

- (void)loginOutBtnClicked:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"确定要退出当前账号" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定退出" otherButtonTitles: nil];
    [actionSheet showInView:kKeyWindow];
}

#pragma mark UIActionSheetDelegate M
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self loginOutToLoginVC];
    }
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}
@end
