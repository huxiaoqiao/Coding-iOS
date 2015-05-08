//
//  SettingTextViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-10-13.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_SettingText @"SettingTextCell"

#import "SettingTextViewController.h"
#import "SettingTextCell.h"

@interface SettingTextViewController ()
@property (strong, nonatomic) UITableView *myTableView;
@end

@implementation SettingTextViewController
+ (instancetype)settingTextVCWithTitle:(NSString *)title textValue:(NSString *)textValue doneBlock:(void(^)(NSString *textValue))block{
    SettingTextViewController *vc = [[SettingTextViewController alloc] init];
    vc.title = title;
    vc.textValue = textValue;
    vc.doneBlock = block;
    vc.settingType = SettingTypeOnlyText;
    return vc;
}
+(void)showSettingFolderNameVCFromVC:(UIViewController *)preVc withTitle:(NSString *)title textValue:(NSString *)textValue type:(SettingType)type doneBlock:(void(^)(NSString *textValue))block{
    SettingTextViewController *vc = [self settingTextVCWithTitle:title textValue:textValue doneBlock:block];
    vc.settingType = type;
    if (preVc) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [preVc presentViewController:nav animated:YES completion:nil];
    }else{
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [[BaseViewController presentingVC] presentViewController:nav animated:YES completion:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView{
    [super loadView];
    CGRect frame = [UIView frameWithOutNav];
    self.view = [[UIView alloc] initWithFrame:frame];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneBtnClicked:)];
    
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[SettingTextCell class] forCellReuseIdentifier:kCellIdentifier_SettingText];
        [self.view addSubview:tableView];
        tableView;
    });
    if (self.settingType != SettingTypeOnlyText) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismissSelf)];
    }
}
#pragma mark doneBtn
- (void)doneBtnClicked:(id)sender{
    if (!_textValue || _textValue.length <= 0) {
        [self showHudTipStr:@"怎么能什么都不写呢！"];
        return;
    }
    if (self.doneBlock) {
        self.doneBlock(_textValue);
    }
    if (self.settingType == SettingTypeOnlyText) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.view endEditing:YES];
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }
}
- (void)dismissSelf{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}
#pragma mark Table M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    SettingTextCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_SettingText forIndexPath:indexPath];
    [cell setTextValue:_textValue andTextChangeBlock:^(NSString *textValue) {
        weakSelf.textValue = textValue;
    }];
    if (self.settingType == SettingTypeNewFolderName) {
        cell.textField.placeholder = @"文件夹名称";
    }else{
        cell.textField.placeholder = @"未填写";
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 1)];
    headerView.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
    [headerView setHeight:30.0];
    return headerView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}

@end
