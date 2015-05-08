//
//  Project_RootViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "Project_RootViewController.h"
#import "Coding_NetAPIManager.h"
#import "LoginViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ProjectListView.h"
#import "ProjectViewController.h"
#import "HtmlMedia.h"
#import "UnReadManager.h"
#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"

@interface Project_RootViewController ()
@property (strong, nonatomic) XTSegmentControl *mySegmentControl;
@property (strong, nonatomic) iCarousel *myCarousel;
@property (strong, nonatomic) NSMutableDictionary *myProjectsDict;
@property (assign, nonatomic) NSInteger oldSelectedIndex;

@end

@implementation Project_RootViewController

#pragma mark TabBar
- (void)tabBarItemClicked{
    if (_myCarousel.currentItemView && [_myCarousel.currentItemView isKindOfClass:[ProjectListView class]]) {
        ProjectListView *listView = (ProjectListView *)_myCarousel.currentItemView;
        [listView tabBarItemClicked];
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[UnReadManager shareManager] addObserver:self forKeyPath:kUnReadKey_project_update_count options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
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
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_myCarousel) {
        ProjectListView *listView = (ProjectListView *)_myCarousel.currentItemView;
        if (listView) {
            [listView refreshToQueryData];
        }
    }
    
    {//调整Label高度测试代码
//    UITTTAttributedLabel *label = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 100, 260, 20)];
//    label.linkAttributes = kLinkAttributes;
//    label.activeLinkAttributes = kLinkAttributesActive;
//    [label addLongPressForCopy];
//    
////    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 260, 20)];
//
//    label.font = [UIFont systemFontOfSize:16];
//    label.textColor = [UIColor colorWithHexString:@"0x222222"];
//    label.backgroundColor = [UIColor redColor];
////    label.lineBreakMode = NSLineBreakByWordWrapping;
//    [self.view addSubview:label];
//
//    
//    NSString *curString = @"😂😂😂😂😂😂😂有了emoji之后，高度就变了.有了emoji之后，高度就变了。有了emoji之后，高度就变了。有了emoji之后，高度就变了。有了emoji之后，高度就变了。有了emoji之后，高度就变了";
//    [label setLongString:curString withFitWidth:260];
//        [label setHeight:CGRectGetHeight(label.frame)+10];
//        
//        {UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 250, 260, 20)];
//        
//        label.font = [UIFont systemFontOfSize:16];
//        label.textColor = [UIColor colorWithHexString:@"0x222222"];
//        label.backgroundColor = [UIColor redColor];
//        //    label.lineBreakMode = NSLineBreakByWordWrapping;
//        [self.view addSubview:label];
//        NSString *curString = @"😂😂😂😂😂😂😂有了emoji之后，高度就变了.有了emoji之后，高度就变了。有了emoji之后，高度就变了。有了emoji之后，高度就变了。有了emoji之后，高度就变了。有了emoji之后，高度就变了";
//        [label setLongString:curString withFitWidth:260];
////        [label setHeight:CGRectGetHeight(label.frame)+10];
//        }

    }


}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UnReadManager shareManager] updateUnRead];
}

- (void)loadView{
    [super loadView];
    
    self.title = @"项目";
    //计算除去NavBar和TabBar的高度
    CGRect frame = [UIView frameWithOutNavTab];
    self.view = [[UIView alloc] initWithFrame:frame];
    
    _myProjectsDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    //添加myCarousel
    frame.origin.y +=  kMySegmentControl_Height;
    frame.size.height -= kMySegmentControl_Height;
    _myCarousel = ({
        iCarousel *icarousel = [[iCarousel alloc] initWithFrame:frame];
        icarousel.dataSource = self;
        icarousel.delegate = self;
        icarousel.decelerationRate = 1.0;
        icarousel.scrollSpeed = 1.0;
        icarousel.type = iCarouselTypeLinear;
        icarousel.pagingEnabled = YES;
        icarousel.clipsToBounds = YES;
        icarousel.bounceDistance = 0.2;
        [self.view addSubview:icarousel];
        icarousel;
    });
    
    //添加滑块
    frame.origin.y = 0;
    frame.size.height = kMySegmentControl_Height;
    //弱引用
    __weak typeof(_myCarousel) weakCarousel = _myCarousel;
    _mySegmentControl = [[XTSegmentControl alloc] initWithFrame:frame Items:@[@"全部项目", @"我参与的", @"我创建的"] selectedBlock:^(NSInteger index) {
        if (index == _oldSelectedIndex) {
            return;
        }
        _oldSelectedIndex = index;
        [weakCarousel scrollToItemAtIndex:index animated:NO];
    }];
    _oldSelectedIndex = 0;
    [self.view addSubview:_mySegmentControl];
    
    [self refreshBadgeTip];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[UnReadManager shareManager] removeObserver:self forKeyPath:kUnReadKey_project_update_count];
}

#pragma mark iCarousel M
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return 3;
}
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    Projects *curPros = [_myProjectsDict objectForKey:[NSNumber numberWithUnsignedInteger:index]];
    if (!curPros) {
        curPros = [Projects projectsWithType:index];
        [_myProjectsDict setObject:curPros forKey:[NSNumber numberWithUnsignedInteger:index]];
    }
    ProjectListView *listView = (ProjectListView *)view;
    if (listView) {
        [listView setProjects:curPros];
    }else{
        __weak Project_RootViewController *weakSelf = self;
        //通过一个block实现一个回调
        listView = [[ProjectListView alloc] initWithFrame:carousel.bounds projects:curPros block:^(Project *project) {
            ProjectViewController *vc = [[ProjectViewController alloc] init];
            vc.myProject = project;
            [weakSelf.navigationController pushViewController:vc animated:YES];
            
            [[Coding_NetAPIManager sharedManager] request_Project_UpdateVisit_WithObj:project andBlock:^(id data, NSError *error) {
                if (data) {
                    project.un_read_activities_count = [NSNumber numberWithInteger:0];
                    [listView refreshUI];
                }
            }];
            NSLog(@"\n=====%@", project.name);
        }];
    }
    return listView;
}

- (void)carouselDidScroll:(iCarousel *)carousel{
    if (_mySegmentControl) {
        float offset = carousel.scrollOffset;
        if (offset > 0) {
            [_mySegmentControl moveIndexWithProgress:offset];
        }
    }
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
    if (_mySegmentControl) {
        [_mySegmentControl endMoveIndex:carousel.currentItemIndex];
    }
    if (_oldSelectedIndex != carousel.currentItemIndex) {
        _oldSelectedIndex = carousel.currentItemIndex;
        ProjectListView *curView = (ProjectListView *)carousel.currentItemView;
        [curView refreshToQueryData];
    }    
}

#pragma mark KVO_UnRead
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:kUnReadKey_project_update_count]){
        [self refreshBadgeTip];
    }
}

- (void)refreshBadgeTip{
    NSString *badgeTip = @"";
    NSNumber *project_update_count = [UnReadManager shareManager].project_update_count;
    if (project_update_count.integerValue > 0) {
        badgeTip = kBadgeTipStr;
//        if (project_update_count.integerValue > 99) {
//            badgeTip = @"99+";
//        }else{
//            badgeTip = project_update_count.stringValue;
//        }
    }
    [self.rdv_tabBarItem setBadgeValue:badgeTip];
}

@end
