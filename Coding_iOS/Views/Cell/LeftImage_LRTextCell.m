//
//  LeftImage_LRTextCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-19.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "LeftImage_LRTextCell.h"
#import "Task.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface LeftImage_LRTextCell ()
@property (strong, nonatomic) id aObj;
@property (assign, nonatomic) LeftImage_LRTextCellType type;

@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *leftLabel, *rightLabel;
@end

@implementation LeftImage_LRTextCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (!_iconView) {
            _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 5, 33, 33)];
            [self.contentView addSubview:_iconView];
        }
        if (!_leftLabel) {
            _leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 7, 100, 30)];
            _leftLabel.font = [UIFont systemFontOfSize:18];
            _leftLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
            _leftLabel.textAlignment = NSTextAlignmentLeft;
            [self.contentView addSubview:_leftLabel];
        }
        if (!_rightLabel) {
            _rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width-170, 7, 135, 30)];
            _rightLabel.font = [UIFont systemFontOfSize:18];
            _rightLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            _rightLabel.textAlignment = NSTextAlignmentRight;
            [self.contentView addSubview:_rightLabel];
        }
    }
    return self;
}

- (void)setObj:(id)aObj type:(LeftImage_LRTextCellType)type{
    _aObj = aObj;
    _type = type;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if ([_aObj isKindOfClass:[Task class]]) {
        Task *task = (Task *)_aObj;
        switch (_type) {
            case LeftImage_LRTextCellTypeTaskOwner:
            {
                [_iconView doCircleFrame];
                [_iconView sd_setImageWithURL:[task.owner.avatar urlImageWithCodePathResizeToView:_iconView] placeholderImage:kPlaceholderMonkeyRoundView(_iconView)];
                _leftLabel.text = @"执行者";
                _rightLabel.text = task.owner.name;
                self.userInteractionEnabled = YES;
            }
                break;
            case LeftImage_LRTextCellTypeTaskPriority:
            {
                [_iconView doNotCircleFrame];
                [_iconView setImage:[UIImage imageNamed:@"taskPriority"]];
                _leftLabel.text = @"优先级";
                if (task.priority && task.priority.intValue < kTaskPrioritiesDisplay.count) {
                    _rightLabel.text = kTaskPrioritiesDisplay[task.priority.intValue];
                }
                self.userInteractionEnabled = YES;
            }
                break;
            case LeftImage_LRTextCellTypeTaskStatus:
            {
                [_iconView doNotCircleFrame];
                [_iconView setImage:[UIImage imageNamed:@"taskProgress"]];
                _leftLabel.text = @"阶段";
                _rightLabel.text = task.status.intValue == 1? @"未完成":@"已完成";
                self.userInteractionEnabled = (task.handleType == TaskHandleTypeEdit);
            }
                break;
            default:
                break;
        }
    }
}


+ (CGFloat)cellHeight{
    return 44;
}
@end
