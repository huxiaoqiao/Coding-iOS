//
//  ProjectListCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-11.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kProjectListCell_IconHeight 55.0

#import "ProjectListCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ProjectListCell ()
@property (nonatomic, strong) UIImageView *projectIconView;
@property (nonatomic, strong) UILabel *projectTitleLabel;
@property (nonatomic, strong) UILabel *ownerTitleLabel;
@property (nonatomic, strong) UIImageView *arrowImgView;
@end

@implementation ProjectListCell
/*
 学到的优化策略：
 通过加非空判断，保证子View只加载一次
 */
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.backgroundColor = [UIColor clearColor];
        if (!_projectIconView) {
            _projectIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 10, kProjectListCell_IconHeight, kProjectListCell_IconHeight)];
            _projectIconView.layer.masksToBounds = YES;
            _projectIconView.layer.cornerRadius = 2.0;
            [self.contentView addSubview:_projectIconView];
        }
        if (!_projectTitleLabel) {
            _projectTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+kProjectListCell_IconHeight+24, 10, 180, 25)];
            _projectTitleLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
            _projectTitleLabel.font = [UIFont systemFontOfSize:17];
            [self.contentView addSubview:_projectTitleLabel];
        }
        if (!_ownerTitleLabel) {
            _ownerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+kProjectListCell_IconHeight+24, 40, 180, 25)];
            _ownerTitleLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            _ownerTitleLabel.font = [UIFont systemFontOfSize:15];
            [self.contentView addSubview:_ownerTitleLabel];
        }
    }
    return self;
}
//在此方法中加载图片和badge
- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_project) {
        return;
    }
    //Icon
    [_projectIconView sd_setImageWithURL:[_project.icon urlImageWithCodePathResizeToView:_projectIconView] placeholderImage:kPlaceholderCodingSquareView(_projectIconView)];
    //Title & UserName
    _projectTitleLabel.text = _project.name;
    _ownerTitleLabel.text = _project.owner_user_name;
    
    NSString *badgeTip = @"";
    if (_project.un_read_activities_count && _project.un_read_activities_count.integerValue > 0) {
        if (_project.un_read_activities_count.integerValue > 99) {
            badgeTip = @"99+";
        }else{
            badgeTip = _project.un_read_activities_count.stringValue;
        }
    }
    [self.contentView addBadgeTip:badgeTip withCenterPosition:CGPointMake(10+kProjectListCell_IconHeight, 15)];
}

//固定高度为75
+ (CGFloat)cellHeightWithObj:(id)obj;{
    return 75.0;
}
@end
