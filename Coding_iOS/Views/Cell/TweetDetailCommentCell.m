//
//  TweetDetailCommentCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-24.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTweetDetailCommentCell_FontContent [UIFont systemFontOfSize:15]

#import "TweetDetailCommentCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Login.h"

@interface TweetDetailCommentCell ()

@property (strong, nonatomic) UILabel *timeLabel;
//@property (strong, nonatomic) UIButton *commentBtn;

@end

@implementation TweetDetailCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        CGFloat curBottomY = 10;
        if (!_ownerIconView) {
            _ownerIconView = [[UITapImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, curBottomY, 33, 33)];
            [_ownerIconView doCircleFrame];
            [self.contentView addSubview:_ownerIconView];
        }
        CGFloat curWidth = kScreen_Width - 40 - 2*kPaddingLeftWidth;
        if (!_contentLabel) {
            _contentLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth + 40, curBottomY, curWidth, 30)];
            _contentLabel.numberOfLines = 0;
            _contentLabel.textColor = [UIColor colorWithHexString:@"0x555555"];
            _contentLabel.font = kTweetDetailCommentCell_FontContent;
            _contentLabel.linkAttributes = kLinkAttributes;
            _contentLabel.activeLinkAttributes = kLinkAttributesActive;
            [self.contentView addSubview:_contentLabel];
        }
        CGFloat commentBtnWidth = 40;
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth +40, 0, curWidth- commentBtnWidth, 20)];
            _timeLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            _timeLabel.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_timeLabel];
        }
//        if (!_commentBtn) {
//            _commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//            _commentBtn.frame = CGRectMake(kScreen_Width - kPaddingLeftWidth - commentBtnWidth, 0, commentBtnWidth, 20);
//            [_commentBtn setTitle:@"回复" forState:UIControlStateNormal];
//            [_commentBtn setImage:[UIImage imageNamed:@"topic_comment_icon"] forState:UIControlStateNormal];
//            [_commentBtn setTitleColor:[UIColor colorWithHexString:@"0x999999"] forState:UIControlStateNormal];
//            _commentBtn.titleLabel.font = [UIFont systemFontOfSize:12];
//            _commentBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
//            _commentBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
// 
//            [self.contentView addSubview:_commentBtn];
//        }
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_toComment) {
        return;
    }
    CGFloat curBottomY = 10;
    CGFloat curWidth = kScreen_Width - 40 - 2*kPaddingLeftWidth;
    [_ownerIconView sd_setImageWithURL:[_toComment.owner.avatar urlImageWithCodePathResizeToView:_ownerIconView] placeholderImage:kPlaceholderMonkeyRoundView(_ownerIconView)];
    
    [_contentLabel setWidth:curWidth];
    _contentLabel.text = _toComment.content;
    [_contentLabel sizeToFit];

    for (HtmlMediaItem *item in _toComment.htmlMedia.mediaItems) {
        if (item.displayStr.length > 0 && !(item.type == HtmlMediaItemType_Code ||item.type == HtmlMediaItemType_EmotionEmoji)) {
            [_contentLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
        }
    }
    
    curBottomY += [_toComment.content getHeightWithFont:kTweetDetailCommentCell_FontContent constrainedToSize:CGSizeMake(curWidth, CGFLOAT_MAX)] + 5;
    [_timeLabel setY:curBottomY];
    _timeLabel.text = [NSString stringWithFormat:@"%@ 发布于 %@", _toComment.owner.name, [_toComment.created_at stringTimesAgo]];
//    [_commentBtn setY:curBottomY];
//    [_commentBtn addTarget:self action:@selector(commentBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    if (_toComment.owner_id.intValue == [Login curLoginUser].id.intValue) {
//        [_commentBtn setTitle:@"删除" forState:UIControlStateNormal];
//    }else{
//        [_commentBtn setTitle:@"回复" forState:UIControlStateNormal];
//    }
}

- (void)commentBtnClicked:(id)sender{
    __weak typeof(self) weakSelf = self;
    if (_commentToCommentBlock) {
        _commentToCommentBlock(_toComment, weakSelf);
    }
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[Comment class]]) {
        Comment *toComment = (Comment *)obj;
        CGFloat curWidth = kScreen_Width - 40 - 2*kPaddingLeftWidth;
        cellHeight += 10 +[toComment.content getHeightWithFont:kTweetDetailCommentCell_FontContent constrainedToSize:CGSizeMake(curWidth, CGFLOAT_MAX)] + 5 +20 +10;
    }
    return cellHeight;
}


@end
