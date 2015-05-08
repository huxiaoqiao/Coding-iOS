//
//  ProjectFolder.m
//  Coding_iOS
//
//  Created by Ease on 14/11/13.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectFolder.h"

@implementation ProjectFolder
+ (ProjectFolder *)defaultFolder{
    ProjectFolder *folder = [[ProjectFolder alloc] init];
    folder.file_id = [NSNumber numberWithInteger:0];
    folder.name = @"默认文件夹";
    return folder;
}
+ (ProjectFolder *)folderWithId:(NSNumber *)file_id{
    ProjectFolder *folder = [[ProjectFolder alloc] init];
    folder.sub_folders = [NSMutableArray array];
    folder.file_id = file_id;
    return folder;
}
- (ProjectFolder *)hasFolderWithId:(NSNumber *)file_id{
    if (!file_id || !_file_id) {
        return nil;
    }
    if (_file_id.integerValue == file_id.integerValue) {
        return self;
    }else{
        for (ProjectFolder *sub_folder in self.sub_folders) {
            return [sub_folder hasFolderWithId:file_id];
        }
    }
    return nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"ProjectFolder", @"sub_folders", nil];
    }
    return self;
}
- (void)setCountWithArray:(NSArray *)countArray{
    __block NSInteger count = _sub_folders.count;
    [countArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSNumber *folder_id = [obj objectForKey:@"folder"];
        if (folder_id && folder_id.integerValue == _file_id.integerValue) {
            count += [(NSNumber *)[obj objectForKey:@"count"] integerValue];
            *stop = YES;
        }
    }];
    self.count = [NSNumber numberWithInteger:count];
}
- (BOOL)isDefaultFolder{
    return !(_file_id && _file_id.integerValue != 0);
}
- (BOOL)canCreatSubfolder{
    return !((_parent_id && _parent_id.integerValue != 0) || [self isDefaultFolder]);
}
- (NSString *)toFilesPath{
    return [NSString stringWithFormat:@"api/project/%@/files/%@", _project_id.stringValue, _file_id.stringValue];
}
- (NSDictionary *)toFilesParams{
    return @{@"height": @"90",
             @"width": @"90",
             @"page" : @"1",
             @"pageSize": @"9999"};
}
- (NSString *)toRenamePath{
    return [NSString stringWithFormat:@"api/project/%@/dir/%@/name/%@", _project_id.stringValue, _file_id.stringValue, _next_name];
}
- (NSString *)toDeletePath{
    return [NSString stringWithFormat:@"api/project/%@/rmdir/%@", _project_id.stringValue, _file_id.stringValue];
}
- (NSString *)toMoveToPath{
    return [NSString stringWithFormat:@"api/project/%@/files/moveto/%@", _project_id.stringValue, _file_id.stringValue];
}
@end
