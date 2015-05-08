//
//  ProjectTopic.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-20.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Projects.h"
#import "ProjectTopics.h"

@class Project;
@class ProjectTopics;

@interface ProjectTopic : NSObject

@property (readwrite, nonatomic, strong) NSNumber *id, *child_count, *current_user_role_id, *owner_id, *project_id, *parent_id;
@property (readwrite, nonatomic, strong) NSDate *created_at, *updated_at;
@property (readwrite, nonatomic, strong) NSString *title, *content, *path;
@property (readwrite, nonatomic, strong) User *owner;
@property (readwrite, nonatomic, strong) Project *project;
@property (readwrite, nonatomic, strong) ProjectTopic *parent;
@property (readwrite, nonatomic, strong) ProjectTopics *comments;
@property (readwrite, nonatomic, strong) NSString *nextCommentStr;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;
@property (assign, nonatomic) CGFloat contentHeight;

@property (readwrite, nonatomic, strong) NSNumber *page, *pageSize, *totalPage, *totalRow;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading, isTopicLoading;

+ (ProjectTopic *)topicWithPro:(Project *)pro;
+ (ProjectTopic *)topicWithId:(NSNumber *)topicId;
- (NSString *)toTopicPath;
- (NSDictionary *)toTopicParams;

- (NSString *)toAddTopicPath;
- (NSDictionary *)toAddTopicParams;

- (NSString *)toCommentsPath;
- (NSDictionary *)toCommentsParams;
- (void)configWithComments:(ProjectTopics *)comments;
- (void)configWithRefreshedTopic:(ProjectTopic *)topic;

- (NSString *)toDoCommentPath;
- (NSDictionary *)toDoCommentParams;
- (void)configWithComment:(ProjectTopic *)comment;

- (NSString *)toDeletePath;
@end
