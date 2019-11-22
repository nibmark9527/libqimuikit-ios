//
//  STIMWorkCommentCell.m
//  STIMUIKit
//
//  Created by lilu on 2019/1/9.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMWorkCommentCell.h"
#import "STIMWorkMomentLabel.h"
#import "STIMMessageParser.h"
#import "STIMMarginLabel.h"
#import "STIMWorkCommentModel.h"
#import "YYModel.h"
#import "STIMEmotionManager.h"
#import "STIMWorkMomentParser.h"
#import "STIMWorkChildCommentListView.h"

@interface STIMWorkCommentCell () <UIGestureRecognizerDelegate, STIMAttributedLabelDelegate>

@end

@implementation STIMWorkCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundView = nil;
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.selectedBackgroundView = nil;
        [self setupUI];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteChildComment:) name:@"deleteChildCommentModel" object:nil];
    }
    return self;
}

- (void)deleteChildComment:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        STIMWorkCommentModel *childComment = (STIMWorkCommentModel *)notify.object;
        if ([childComment.parentCommentUUID isEqualToString:self.commentModel.commentUUID] || [childComment.superParentUUID isEqualToString:self.commentModel.commentUUID]) {
            NSArray *childComments = [self getChildComments];
            STIMVerboseLog(@"childComments : %@", childComments);
            self.commentModel.childComments = childComments;
//            [self.childCommentListView setChildCommentList:childComments];
            [self updateChildCommentListView];
        }
    });
}

- (NSArray *)getChildComments {
    NSMutableArray *childCommentArray = [[NSMutableArray alloc] init];
    NSArray *childComments = [[STIMKit sharedInstance] getWorkChildCommentsWithParentCommentUUID:self.commentModel.commentUUID];
    for (NSDictionary *commentDic in childComments) {
        STIMWorkCommentModel *commentModel = [self getCommentModelWithDic:commentDic];
        [childCommentArray addObject:commentModel];
    }
    return childCommentArray;
}

- (STIMWorkCommentModel *)getCommentModelWithDic:(NSDictionary *)commentDic {
    
    STIMWorkCommentModel *model = [STIMWorkCommentModel yy_modelWithDictionary:commentDic];
    return model;
}

- (void)setupUI {
    // 头像视图
    _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 36, 36)];
    _headImageView.contentMode = UIViewContentModeScaleAspectFill;
    _headImageView.userInteractionEnabled = YES;
    _headImageView.layer.masksToBounds = YES;
    _headImageView.layer.cornerRadius = _headImageView.width / 2.0f;
    _headImageView.backgroundColor = [UIColor stimDB_colorWithHex:0xFFFFFF];
    _headImageView.layer.borderColor = [UIColor stimDB_colorWithHex:0xDFDFDF].CGColor;
    _headImageView.layer.borderWidth = 0.5f;
    [self.contentView addSubview:_headImageView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickHead:)];
    tapGesture.delegate = self;
    [_headImageView addGestureRecognizer:tapGesture];
    
    // 名字视图
    _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(_headImageView.right+10, _headImageView.top, 50, 20)];
    _nameLab.font = [UIFont boldSystemFontOfSize:15.0];
    _nameLab.textColor = [UIColor stimDB_colorWithHex:0x00CABE];
    _nameLab.backgroundColor = [UIColor clearColor];
    _nameLab.userInteractionEnabled = YES;
    [self.contentView addSubview:_nameLab];
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickHead:)];
    [_nameLab addGestureRecognizer:tapGesture2];
    
    //组织架构视图
    _organLab = [[STIMMarginLabel alloc] init];
    _organLab.backgroundColor = [UIColor stimDB_colorWithHex:0xF3F3F3];
    _organLab.font = [UIFont systemFontOfSize:11];
    _organLab.textColor = [UIColor stimDB_colorWithHex:0x999999];
    _organLab.textAlignment = NSTextAlignmentCenter;
    _organLab.layer.cornerRadius = 2.0f;
    _organLab.layer.masksToBounds = YES;
    _organLab.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_organLab];
    
    //点赞按钮
    _likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_likeBtn setImage:[UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:@"\U0000e0e7" size:24 color:[UIColor stimDB_colorWithHex:0x999999]]] forState:UIControlStateNormal];
    [_likeBtn setImage:[UIImage qimIconWithInfo:[STIMIconInfo iconInfoWithText:@"\U0000e0cd" size:24 color:[UIColor stimDB_colorWithHex:0x00CABE]]] forState:UIControlStateSelected];
    [_likeBtn setTitle:[NSBundle stimDB_localizedStringForKey:@"moment_like"] forState:UIControlStateNormal];
    [_likeBtn setTitleColor:[UIColor stimDB_colorWithHex:0x999999] forState:UIControlStateNormal];
    [_likeBtn setTitleColor:[UIColor stimDB_colorWithHex:0x999999] forState:UIControlStateSelected];
    _likeBtn.layer.cornerRadius = 13.5f;
    _likeBtn.layer.masksToBounds = YES;
    [_likeBtn.titleLabel setFont:[UIFont systemFontOfSize:11]];
    [_likeBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, -10, 0.0, 0.0)];
    [_likeBtn addTarget:self action:@selector(didLikeComment:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_likeBtn];
    
    // 正文视图
    _contentLabel = [[STIMWorkMomentLabel alloc] init];
    if (self.isChildComment == YES) {
        _contentLabel.font = [UIFont systemFontOfSize:14];
    } else {
        _contentLabel.font = [UIFont systemFontOfSize:15];
    }
    _contentLabel.delegate = self;
    _contentLabel.linesSpacing = 1.0f;
    _contentLabel.textColor = [UIColor stimDB_colorWithHex:0x333333];
    _contentLabel.lineBreakMode = UILineBreakModeCharacterWrap;
    [self.contentView addSubview:_contentLabel];
    
    _childCommentListView = [[STIMWorkChildCommentListView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.contentView addSubview:_childCommentListView];
}

- (void)setCommentModel:(STIMWorkCommentModel *)commentModel {
    if (commentModel.commentUUID.length <= 0) {
        return;
    }
    _commentModel = commentModel;
    // 头像视图
    if (self.isChildComment == YES) {
        _headImageView.frame = CGRectMake(61, 10, 23, 23);
        _headImageView.layer.masksToBounds = YES;
        _headImageView.layer.cornerRadius = _headImageView.width / 2.0f;
        _nameLab.frame = CGRectMake(_headImageView.right+10, _headImageView.top, 50, 20);
        _nameLab.font = [UIFont boldSystemFontOfSize:14.0];
    }
    BOOL isAnonymousComment = commentModel.isAnonymous;
    if (isAnonymousComment == NO) {
        
        //实名评论
        NSString *commentFromUserId = [NSString stringWithFormat:@"%@@%@", commentModel.fromUser, commentModel.fromHost];
//        STIMVerboseLog(@"commentFromUserId : %@ --- %@", commentFromUserId, commentModel.commentUUID);
        [_headImageView stimDB_setImageWithJid:commentFromUserId];
        _nameLab.text = [[STIMKit sharedInstance] getUserMarkupNameWithUserId:commentFromUserId];
        [_nameLab sizeToFit];
        
        _organLab.frame = CGRectMake(self.nameLab.right + 5, self.nameLab.top, 66, 20);
        NSDictionary *userInfo = [[STIMKit sharedInstance] getUserInfoByUserId:commentFromUserId];
        NSString *department = [userInfo objectForKey:@"DescInfo"]?[userInfo objectForKey:@"DescInfo"]:[NSBundle stimDB_localizedStringForKey:@"moment_Unknown"];
        NSString *lastDp = [[department componentsSeparatedByString:@"/"] objectAtIndex:2];
        if(lastDp.length > 0) {
            _organLab.text = [NSString stringWithFormat:@"%@", lastDp];
        } else {
            _organLab.hidden = YES;
        }
        [_organLab sizeToFit];
        [_organLab sizeThatFits:CGSizeMake(_organLab.width, _organLab.height)];
        _organLab.height = 20;
    } else {
        //匿名评论
        NSString *anonymousName = commentModel.anonymousName;
        NSString *anonymousPhoto = commentModel.anonymousPhoto;
        if (![anonymousPhoto stimDB_hasPrefixHttpHeader]) {
            anonymousPhoto = [NSString stringWithFormat:@"%@/%@", [[STIMKit sharedInstance] qimNav_InnerFileHttpHost], anonymousPhoto];
        }
        [self.headImageView stimDB_setImageWithURL:[NSURL URLWithString:anonymousPhoto]];
        self.nameLab.text = anonymousName;
        [self.nameLab sizeToFit];
        self.nameLab.textColor = [UIColor stimDB_colorWithHex:0x999999];
        self.organLab.hidden = YES;
    }
    CGFloat rowHeight = 0;

    _nameLab.centerY = self.headImageView.centerY;
    _organLab.centerY = self.headImageView.centerY;
    
    _likeBtn.frame = CGRectMake([[UIScreen mainScreen] stimDB_rightWidth] - 70, 5, 60, 27);
    NSInteger likeNum = commentModel.likeNum;
    BOOL isLike = commentModel.isLike;
    if (isLike) {
        _likeBtn.selected = YES;
        [_likeBtn setTitle:[NSString stringWithFormat:@"%ld", likeNum] forState:UIControlStateSelected];
    } else {
        _likeBtn.selected = NO;
        if (likeNum > 0) {
            [_likeBtn setTitle:[NSString stringWithFormat:@"%ld", likeNum] forState:UIControlStateNormal];
        } else {
            [_likeBtn setTitle:[NSBundle stimDB_localizedStringForKey:@"moment_like"] forState:UIControlStateNormal];
        }
    }
    _likeBtn.centerY = self.headImageView.centerY;

    BOOL isChildComment = (commentModel.parentCommentUUID.length > 0) ? YES : NO;
    BOOL toisAnonymous = commentModel.toisAnonymous;
    NSString *replayNameStr = @"";
    NSString *replayStr = @"";
    if (isChildComment) {
        if (toisAnonymous) {
            NSString *toAnonymousName = commentModel.toAnonymousName;
            replayNameStr = [NSString stringWithFormat:@"回复%@：", toAnonymousName];
            replayStr = [NSString stringWithFormat:@"[obj type=\"reply\" value=\"%@\"]",replayNameStr];
        } else {
            NSString *toUser = commentModel.toUser;
            NSString *toUserHost = commentModel.toHost;
            if (toUser.length > 0) {
                
            }
            NSString *toUserId = [NSString stringWithFormat:@"%@@%@", toUser, toUserHost];
            NSString *toUserName = [[STIMKit sharedInstance] getUserMarkupNameWithUserId:toUserId];
            replayNameStr = [NSString stringWithFormat:@"回复%@：", toUserName];
            replayStr = [NSString stringWithFormat:@"[obj type=\"reply\" value=\"%@\"]",replayNameStr];
        }
    } else {
        replayNameStr = [NSString stringWithFormat:@""];
    }

    NSString *likeString  = [NSString stringWithFormat:@"%@%@", replayStr, commentModel.content];
    if (commentModel.isDelete == YES) {
        likeString = [NSString stringWithFormat:@"[obj type=\"deleteComment\" value=\"%@\"]",[NSBundle stimDB_localizedStringForKey:@"moment_comment_has_deleted"]];
    } else {
        
    }
    
    STIMMessageModel *msg = [[STIMMessageModel alloc] init];
    msg.message = [[STIMEmotionManager sharedInstance] decodeHtmlUrlForText:likeString];
    msg.messageId = commentModel.commentUUID;
    
    STIMTextContainer *textContainer = nil;
    if (self.isChildComment) {
        textContainer = [STIMWorkMomentParser textContainerForMessage:msg fromCache:NO withCellWidth:self.likeBtn.left - self.nameLab.left withFontSize:15 withFontColor:[UIColor stimDB_colorWithHex:0x333333] withNumberOfLines:0];
    } else {
        textContainer = [STIMWorkMomentParser textContainerForMessage:msg fromCache:NO withCellWidth:self.likeBtn.left - self.nameLab.left withFontSize:14 withFontColor:[UIColor stimDB_colorWithHex:0x333333] withNumberOfLines:0];
    }
    
    CGFloat textH = textContainer.textHeight;
    self.contentLabel.originContent = commentModel.content;
    self.contentLabel.textContainer = textContainer;
    if (self.isChildComment) {
        [self.contentLabel setFrameWithOrign:CGPointMake(self.nameLab.left, self.nameLab.bottom + 5) Width:(self.likeBtn.left - self.nameLab.left)];
    } else {
        [self.contentLabel setFrameWithOrign:CGPointMake(self.nameLab.left, self.nameLab.bottom + 16) Width:(self.likeBtn.left - self.nameLab.left)];
    }
    [self updateChildCommentListView];
}

- (void)updateChildCommentListView {
    if (self.commentModel.childComments.count > 0) {
        _childCommentListView.hidden = NO;
        _childCommentListView.parentCommentIndexPath = self.commentIndexPath;
        _childCommentListView.childCommentList = self.commentModel.childComments;
        _childCommentListView.leftMargin = self.nameLab.left;
        _childCommentListView.origin = CGPointMake(0, self.contentLabel.bottom + 5);
        _childCommentListView.width = [[UIScreen mainScreen] stimDB_rightWidth];
        _childCommentListView.height = 500;
        _childCommentListView.height = [_childCommentListView getWorkChildCommentListViewHeight];
        _commentModel.rowHeight = _childCommentListView.bottom;
    } else {
        _childCommentListView.height = 0;
        _childCommentListView.parentCommentIndexPath = self.commentIndexPath;
        _childCommentListView.hidden = YES;
        _commentModel.rowHeight = _contentLabel.bottom + 10;
    }
}

- (void)didLikeComment:(UIButton *)sender {
    BOOL likeFlag = !sender.selected;
    [[STIMKit sharedInstance] likeRemoteCommentWithCommentId:self.commentModel.commentUUID withSuperParentUUID:self.commentModel.superParentUUID withMomentId:self.commentModel.postUUID withLikeFlag:likeFlag withCallBack:^(NSDictionary *responseDic) {
        if (responseDic.count > 0) {
            NSLog(@"点赞成功");
            BOOL islike = [[responseDic objectForKey:@"isLike"] boolValue];
            NSInteger likeNum = [[responseDic objectForKey:@"likeNum"] integerValue];
            if (islike) {
                sender.selected = YES;
                [sender setTitle:[NSString stringWithFormat:@"%ld", likeNum] forState:UIControlStateSelected];
            } else {
                sender.selected = NO;
                if (likeNum > 0) {
                    [sender setTitle:[NSString stringWithFormat:@"%ld", likeNum] forState:UIControlStateNormal];
                } else {
                    [sender setTitle:[NSBundle stimDB_localizedStringForKey:@"moment_like"] forState:UIControlStateNormal];
                }
            }
        } else {
            NSLog(@"点赞失败");
        }
    }];
}

// 点击头像
- (void)clickHead:(UITapGestureRecognizer *)gesture {
    if (self.commentModel.isAnonymous == NO) {
        NSString *userId = [NSString stringWithFormat:@"%@@%@", self.commentModel.fromUser, self.commentModel.fromHost];
        [STIMFastEntrance openUserCardVCByUserId:userId];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// 点击代理
- (void)attributedLabel:(STIMAttributedLabel *)attributedLabel textStorageClicked:(id<STIMTextStorageProtocol>)textStorage atPoint:(CGPoint)point {
    if ([textStorage isMemberOfClass:[STIMLinkTextStorage class]]) {
        STIMLinkTextStorage *storage = (STIMLinkTextStorage *) textStorage;
        if (![storage.linkData length]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"Wrong_Interface"] message:[NSBundle stimDB_localizedStringForKey:@"Wrong_URL"] delegate:nil cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"common_ok"] otherButtonTitles:nil];
            [alertView show];
        } else {
            [STIMFastEntrance openWebViewForUrl:storage.linkData showNavBar:YES];
        }
    } else {
        
    }
}

// 长按代理 有多个状态 begin, changes, end 都会调用,所以需要判断状态
- (void)attributedLabel:(STIMAttributedLabel *)attributedLabel textStorageLongPressed:(id<STIMTextStorageProtocol>)textStorage onState:(UIGestureRecognizerState)state atPoint:(CGPoint)point {
    
}

@end
