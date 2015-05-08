//
//  ProjectTasksView.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-16.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectTasksView.h"
#import "Tasks.h"
#import "Coding_NetAPIManager.h"

@interface ProjectTasksView ()
@property (nonatomic, strong) Project *myProject;
@property (nonatomic , copy) ProjectTaskBlock block;
@property (strong, nonatomic) NSMutableDictionary *myProTksDict;
@property (strong, nonatomic) NSMutableArray *myMemberList;

@property (strong, nonatomic) XTSegmentControl *mySegmentControl;
@property (strong, nonatomic) iCarousel *myCarousel;

@end

@implementation ProjectTasksView

- (id)initWithFrame:(CGRect)frame project:(Project *)project block:(ProjectTaskBlock)block defaultIndex:(NSInteger)index{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _myProject = project;
        _block = block;
        _myProTksDict = [[NSMutableDictionary alloc] initWithCapacity:1];
        _myMemberList = [[NSMutableArray alloc] initWithObjects:[ProjectMember member_All], nil];
        //添加myCarousel
        frame.origin.y +=  kMySegmentControlIcon_Height;
        frame.size.height -= kMySegmentControlIcon_Height;
        self.myCarousel = ({
            iCarousel *icarousel = [[iCarousel alloc] initWithFrame:frame];
            icarousel.dataSource = self;
            icarousel.delegate = self;
            icarousel.decelerationRate = 1.0;
            icarousel.scrollSpeed = 1.0;
            icarousel.type = iCarouselTypeLinear;
            icarousel.pagingEnabled = YES;
            icarousel.clipsToBounds = YES;
            icarousel.bounceDistance = 0.2;
            [self addSubview:icarousel];
            icarousel;
        });
        
        __weak typeof(self) weakSelf = self;
        [[Coding_NetAPIManager sharedManager] request_ProjectMembersHaveTasks_WithObj:_myProject andBlock:^(NSArray *data, NSError *error) {
            if (data) {
                [weakSelf.myMemberList addObjectsFromArray:data];
                //添加滑块
                CGRect segmentFrame = CGRectMake(0, 0, kScreen_Width, kMySegmentControlIcon_Height);
                __weak typeof(_myCarousel) weakCarousel = weakSelf.myCarousel;
                
                weakSelf.mySegmentControl = [[XTSegmentControl alloc] initWithFrame:segmentFrame Items:weakSelf.myMemberList selectedBlock:^(NSInteger index) {
                    [weakCarousel scrollToItemAtIndex:index animated:NO];
                }];
                [weakSelf addSubview:self.mySegmentControl];
                [weakSelf.myCarousel reloadData];
            }else{
//                添加一个重新加载的按钮
            }
        }];
    }
    return self;
}
- (void)refreshToQueryData{
    UIView *currentItemView = self.myCarousel.currentItemView;
    if ([currentItemView isKindOfClass:[ProjectTaskListView class]]) {
        ProjectTaskListView *listView = (ProjectTaskListView *)currentItemView;
        [listView refreshToQueryData];
    }
}

#pragma mark iCarousel M
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return [_myMemberList count];
}
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    {
        ProjectMember *curMember = [_myMemberList objectAtIndex:index];
        Tasks *curTasks = [_myProTksDict objectForKey:curMember.user_id];
        if (!curTasks) {
            curTasks = [Tasks tasksWithPro:_myProject owner:curMember.user queryType:TaskQueryTypeAll];
            [_myProTksDict setObject:curTasks forKey:curMember.user_id];
        }
        
        ProjectTaskListView *listView = (ProjectTaskListView *)view;
        if (listView) {
            [listView setTasks:curTasks];
        }else{
            listView = [[ProjectTaskListView alloc] initWithFrame:carousel.bounds tasks:curTasks block:_block];
        }
        return listView;
    }
}

- (void)carouselDidScroll:(iCarousel *)carousel{
    if (_mySegmentControl) {
        float offset = carousel.scrollOffset;
        if (offset > 0) {
            [_mySegmentControl moveIndexWithProgress:offset];
        }
    }
}
- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel{
    if (_mySegmentControl) {
        [_mySegmentControl endMoveIndex:carousel.currentItemIndex];
    }
}

@end
