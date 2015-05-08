//
//  AddUserViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-10-15.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_UserCell @"UserCell"

#import "AddUserViewController.h"
#import "UserCell.h"
#import "UserInfoViewController.h"
#import "Coding_NetAPIManager.h"

@interface AddUserViewController ()
@property (strong, nonatomic) UISearchBar *mySearchBar;
@property (strong, nonatomic) UITableView *myTableView;
@end

@implementation AddUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.popSelfBlock) {
        self.popSelfBlock();
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (_mySearchBar) {
        [self searchUserWithStr:_mySearchBar.text];
    }
}

- (void)loadView{
    [super loadView];
    self.view = [[UIView alloc] initWithFrame:[UIView frameWithOutNav]];
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[UserCell class] forCellReuseIdentifier:kCellIdentifier_UserCell];
        [self.view addSubview:tableView];
        tableView;
    });
    _mySearchBar = ({
        UISearchBar *searchBar = [[UISearchBar alloc] init];
        searchBar.delegate = self;
        [searchBar sizeToFit];
        [searchBar setPlaceholder:@"姓名/个性后缀"];
        searchBar.backgroundColor = [UIColor colorWithHexString:@"0x28303b"];
        searchBar;
    });
    _myTableView.tableHeaderView = _mySearchBar;
    
    if (self.type == AddUserTypeProject) {
        self.title = @"添加成员";
        _queryingArray = [NSMutableArray array];
        _searchedArray = [NSMutableArray array];
    }else if (self.type == AddUserTypeFollow){
        self.title = @"添加好友";
    }
    
}

- (void)configAddedArrayWithMembers:(NSArray *)memberArray{
    _addedArray = [NSMutableArray array];
    for (ProjectMember *member in memberArray) {
        [_addedArray addObject:member.user];
    }
}
- (BOOL)userIsInProject:(User *)curUser{
    for (User *item in _addedArray) {
        if ([item.global_key isEqualToString:curUser.global_key]) {
            return YES;
        }
    }
    return NO;
}
- (BOOL)userIsQuering:(User *)curUser{
    for (User *item in _queryingArray) {
        if ([item.global_key isEqualToString:curUser.global_key]) {
            return YES;
        }
    }
    return NO;
}
#pragma mark Table M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _searchedArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;

    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_UserCell forIndexPath:indexPath];
    User *curUser = [_searchedArray objectAtIndex:indexPath.row];
    cell.curUser = curUser;
    if (self.type == AddUserTypeProject) {
        cell.usersType = UsersTypeAddToProject;
        cell.isInProject = [self userIsInProject:curUser];
        cell.isQuerying = [self userIsQuering:curUser];
        cell.leftBtnClickedBlock = ^(User *clickedUser){
            NSLog(@"add %@ to pro:%@", clickedUser.name, weakSelf.curProject.name);
            if (![weakSelf userIsQuering:clickedUser]) {
                //            添加改用户到项目
                [weakSelf.queryingArray addObject:clickedUser];
                [weakSelf.myTableView reloadData];
                
                [[Coding_NetAPIManager sharedManager] request_AddUser:clickedUser ToProject:weakSelf.curProject andBlock:^(id data, NSError *error) {
                    if (data) {
                        [weakSelf.addedArray addObject:clickedUser];
                    }
                    [weakSelf.queryingArray removeObject:clickedUser];
                    [weakSelf.myTableView reloadData];
                }];
            }
        };
    }else{
        cell.usersType = UsersTypeAddFriend;
        cell.leftBtnClickedBlock = nil;
    }

    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:60];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [UserCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self goToUserInfo:[_searchedArray objectAtIndex:indexPath.row]];
}

- (void)goToUserInfo:(User *)user{
    UserInfoViewController *vc = [[UserInfoViewController alloc] init];
    vc.curUser = user;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark ScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == _myTableView) {
        [self.mySearchBar resignFirstResponder];
    }
}

#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"textDidChange: %@", searchText);
    [self searchUserWithStr:searchText];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"searchBarSearchButtonClicked: %@", searchBar.text);
    [searchBar resignFirstResponder];
    [self searchUserWithStr:searchBar.text];
}

- (void)searchUserWithStr:(NSString *)string{
     NSString *strippedStr = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (strippedStr.length > 0) {
        __weak typeof(self) weakSelf = self;
        [[Coding_NetAPIManager sharedManager] request_Users_WithSearchString:string andBlock:^(id data, NSError *error) {
            if (data) {
                weakSelf.searchedArray = data;
                [weakSelf.myTableView reloadData];
            }
        }];
    }else{
        [_searchedArray removeAllObjects];
        [_myTableView reloadData];
    }

}


- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}


@end
