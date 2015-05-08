//
//  ProjectTopicListView.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-20.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectTopics.h"
@class ProjectTopicListView;

typedef void(^ProjectTopicBlock)(ProjectTopicListView *projectTopicListView, ProjectTopic *projectTopic);

@interface ProjectTopicListView : UIView<UITableViewDataSource, UITableViewDelegate>

- (id)initWithFrame:(CGRect)frame projectTopics:(ProjectTopics *)projectTopics block:(ProjectTopicBlock)block;
- (void)setProTopics:(ProjectTopics *)proTopics;
- (void)reloadQueryData;
@end
