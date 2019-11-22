//
//  STIMNewMoivePlayerVC.m
//  STIMUIKit
//
//  Created by lilu on 2019/8/7.
//

#import "STIMNewMoivePlayerVC.h"
#import "SuperPlayer.h"
#import "UIView+MMLayout.h"
#import "Masonry.h"
#import "LCActionSheet.h"
#import "STIMNewVideoCacheManager.h"
#import "YYModel.h"
#import "STIMContactSelectionViewController.h"
#import "DACircularProgressView.h"

@interface STIMNewMoivePlayerVC () <SuperPlayerDelegate>
@property UIView *playerContainer;
@property SuperPlayerView *playerView;
@property BOOL isAutoPaused;
@property (nonatomic, strong) DACircularProgressView *loadingIndicator;

@end

@implementation STIMNewMoivePlayerVC

- (DACircularProgressView *)loadingIndicator {
    if (!_loadingIndicator) {
        // Loading indicator
        _loadingIndicator = [[DACircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 40.0f, 40.0f)];
        _loadingIndicator.userInteractionEnabled = NO;
        _loadingIndicator.thicknessRatio = 0.1;
        _loadingIndicator.roundedCorners = NO;
        [self.view addSubview:_loadingIndicator];
        _loadingIndicator.center = self.view.center;
    }
    return _loadingIndicator;
}

- (void)hideLoadingIndicator {
    self.loadingIndicator.hidden = YES;
}

- (void)showLoadingIndicator {
    self.loadingIndicator.progress = 0;
    self.loadingIndicator.hidden = NO;
}


- (NSString *)playUrl {
    if (self.videoModel.LocalVideoOutPath > 0) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.videoModel.LocalVideoOutPath]) {
            return self.videoModel.LocalVideoOutPath;
        } else {
            if (![self.videoModel.FileUrl stimDB_hasPrefixHttpHeader]) {
                self.videoModel.FileUrl = [[STIMKit sharedInstance].qimNav_InnerFileHttpHost stringByAppendingFormat:@"/%@", self.videoModel.FileUrl];
            }
            return self.videoModel.FileUrl;
        }
    } else {
        if (![self.videoModel.FileUrl stimDB_hasPrefixHttpHeader]) {
            self.videoModel.FileUrl = [[STIMKit sharedInstance].qimNav_InnerFileHttpHost stringByAppendingFormat:@"/%@", self.videoModel.FileUrl];
        }
        return self.videoModel.FileUrl;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor blackColor];
    
    self.playerContainer = [[UIView alloc] init];
    self.playerContainer.backgroundColor = [UIColor blackColor];
    self.playerContainer.mm_top([[STIMDeviceManager sharedInstance] getSTATUS_BAR_HEIGHT]);
    self.playerContainer.mm_width(self.view.mm_w).mm_height(self.view.mm_h - [[STIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT] - [[STIMDeviceManager sharedInstance] getSTATUS_BAR_HEIGHT]);
    
    _playerView = [[SuperPlayerView alloc] init];
    [_playerView.controlView setValue:nil forKey:@"danmakuBtn"];
    [_playerView.controlView setValue:nil forKey:@"captureBtn"];
    [_playerView.controlView setValue:nil forKey:@"moreBtn"];
    if (self.videoModel.LocalThubmImage) {
        
        [_playerView.coverImageView setImage:self.videoModel.LocalThubmImage];
        
    } else {
        [_playerView.coverImageView stimDB_setImageWithURL:[NSURL URLWithString:self.videoModel.ThumbUrl]];
    }
    // 设置父View
    _playerView.disableGesture = YES;
    
    [self.view addSubview:self.playerContainer];
    
    UILongPressGestureRecognizer * longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesHandle:)];
    [self.view addGestureRecognizer:longGes];
    if (self.videoModel.newVideo == YES) {
        SuperPlayerModel *playerModel = [[SuperPlayerModel alloc] init];
        playerModel.videoURL = self.playUrl;
        self.playerView.delegate = self;
        self.playerView.fatherView = self.playerContainer;
    
        // 开始播放
        [_playerView playWithModel:playerModel];
    } else {
        NSString *imageCachePath = [UserCachesPath stringByAppendingPathComponent:@"imageCache"];
        NSString *fileMd5 = [[STIMKit sharedInstance] md5fromUrl:self.playUrl];
        NSString *fileExt = [[STIMKit sharedInstance] getFileExtFromUrl:self.playUrl];
        NSString *cacheName = [NSString stringWithFormat:@"%@.%@", fileMd5, fileExt];
        NSString *videoCachePath = [imageCachePath stringByAppendingPathComponent:cacheName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:videoCachePath] && videoCachePath.length > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                SuperPlayerModel *playerModel = [[SuperPlayerModel alloc] init];
                playerModel.videoURL = videoCachePath;
                self.playerView.delegate = self;
                self.playerView.fatherView = self.playerContainer;
                
                // 开始播放
                [_playerView playWithModel:playerModel];
            });
        } else {
            [self showLoadingIndicator];
            [[STIMKit sharedInstance] sendTPGetRequestWithUrl:self.playUrl withProgressCallBack:^(float progressValue) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.loadingIndicator.progress = progressValue;
                });
                NSLog(@"progressValue : %f", progressValue);
            } withSuccessCallBack:^(NSData *responseData) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideLoadingIndicator];
                });
                [responseData writeToFile:videoCachePath atomically:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    SuperPlayerModel *playerModel = [[SuperPlayerModel alloc] init];
                    playerModel.videoURL = videoCachePath;
                    self.playerView.delegate = self;
                    self.playerView.fatherView = self.playerContainer;
                    
                    // 开始播放
                    [_playerView playWithModel:playerModel];
                });
            } withFailedCallBack:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideLoadingIndicator];
                });
            }];
        }
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)superPlayerBackAction:(SuperPlayerView *)player {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didMoveToParentViewController:(nullable UIViewController *)parent {
    if (parent == nil) {
        [self.playerView resetPlayer];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.isAutoPaused) {
        [self.playerView resume];
        self.isAutoPaused = NO;
    }
}

- (void)longGesHandle:(UILongPressGestureRecognizer *)longGes{
    switch (longGes.state) {
        case UIGestureRecognizerStateBegan: {
            [self actionButtonPressed];
            
        }
            break;
        default:
            break;
    }
}

- (void)actionButtonPressed {
    if (![self.videoModel.FileUrl stimDB_hasPrefixHttpHeader]) {
        self.videoModel.FileUrl = [[STIMKit sharedInstance].qimNav_InnerFileHttpHost stringByAppendingFormat:@"/%@", self.videoModel.FileUrl];
    }
    NSString *cachePath = [[STIMNewVideoCacheManager sharedInstance] getVideoCachePathWithUrl:self.videoModel.FileUrl];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.videoModel.LocalVideoOutPath]) {
        cachePath = self.videoModel.LocalVideoOutPath;
    } else {
        
    }
    
    BOOL canSave = NO;
    NSArray *buttonTitles = @[];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        canSave = YES;
    }
    NSLog(@"cachePath : %@", cachePath);
    if (self.videoModel.FileUrl.length > 0) {
        if (canSave == YES) {
            buttonTitles = @[[NSBundle stimDB_localizedStringForKey:@"Send to Friends"], @"分享到驼圈", @"保存视频"];
        } else {
            buttonTitles = @[[NSBundle stimDB_localizedStringForKey:@"Send to Friends"], @"分享到驼圈"];
        }
    } else {
        buttonTitles = @[@"分享到驼圈", @"保存视频"];
    }
    
    __weak __typeof(self) weakSelf = self;
    LCActionSheet *actionSheet = [LCActionSheet sheetWithTitle:nil
                                             cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"Cancel"]
                                                       clicked:^(LCActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
                                                           __typeof(self) strongSelf = weakSelf;
                                                           if (!strongSelf) {
                                                               return;
                                                           }
                                                           if (buttonIndex == 1) {
                                                               STIMVerboseLog(@"发送给朋友");
                                                               [strongSelf shareVideoToFriends];
                                                           }
                                                           if (buttonIndex == 2) {
                                                               STIMVerboseLog(@"分享视频到驼圈");
                                                               [strongSelf shareVideoToWorkMoment];
                                                           }
                                                           if (buttonIndex == 3) {
                                                               STIMVerboseLog(@"保存视频");
                                                               [strongSelf saveVideoToAlbum:cachePath];
                                                           }
                                                       }
                                         otherButtonTitleArray:buttonTitles];
    [actionSheet show];
}

#pragma mark - 分享给朋友
- (void)shareVideoToFriends {
    NSDictionary *videoModelDic = [self.videoModel yy_modelToJSONObject];
    NSString *message = [[STIMJSONSerializer sharedInstance] serializeObject:videoModelDic];
    
    STIMMessageModel *msg = [[STIMMessageModel alloc] init];
    msg.message = message;
    msg.extendInformation = message;
    msg.messageType = STIMMessageType_SmallVideo;
    
    NSLog(@"videoModelDic : %@", videoModelDic);

    STIMContactSelectionViewController *controller = [[STIMContactSelectionViewController alloc] init];
    controller.ExternalForward = YES;
    STIMNavController *nav = [[STIMNavController alloc] initWithRootViewController:controller];
    [controller setMessage:msg];
    [[self navigationController] presentViewController:nav animated:YES completion:^{
        
    }];
}

#pragma mark - 分享驼圈
- (void)shareVideoToWorkMoment {

    NSDictionary *videoModelDic = [self.videoModel yy_modelToJSONObject];
    
    NSDictionary *videoDic = @{@"MediaType":@(1), @"VideoDic": videoModelDic, @"videoReady": self.videoModel.FileUrl.length ? @(YES) : @(NO)};
    
    STIMVerboseLog(@"保存视频 : %@", videoModelDic);
    [STIMFastEntrance presentWorkMomentPushVCWithVideoDic:videoDic withNavVc:self.navigationController];
}

#pragma mark - 保存视频->相册
- (void)saveVideoToAlbum:(NSString *)videoPath {
    // 保存视频
    UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
}

// 视频保存回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    
    if (!error) {
        UIAlertView * alertView  = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"Saved_Success"] message:[NSBundle stimDB_localizedStringForKey:@"Video_saved"] delegate:nil cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"common_ok"] otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        UIAlertView * alertView  = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"save_faild"] message:[NSBundle stimDB_localizedStringForKey:@"Privacy_Photo"] delegate:nil cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"common_ok"] otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)dealloc {
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

@end
