//
//  PLVECLivePlayerViewController.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/23.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVECLivePlayerViewController.h"
#import <PolyvFoundationSDK/PLVProgressHUD.h>
#import "PLVECAudioAnimalView.h"
#import "PLVECUtils.h"

@interface PLVECLivePlayerViewController () <PLVLivePlayerPresenterDelegate>

@property (nonatomic, strong) PLVLivePlayerPresenter *presenter;

@property (nonatomic, strong) UIView *backgroundView; // 显示播放背景图
@property (nonatomic, strong) UIImageView *noLiveImgView;
@property (nonatomic, strong) UILabel *noLiveLabel;

@property (nonatomic, strong) UIView *displayView; // 显示视频区域

@property (nonatomic, strong) PLVECAudioAnimalView *audioAnimalView; // 显示音频模式

@end

@implementation PLVECLivePlayerViewController

#pragma mark - Life cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.presenter = [[PLVLivePlayerPresenter alloc] init];
        self.presenter.view = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [self.presenter setupPlayerWithDisplayView:self.displayView];
}

- (void)setupUI {
    UIImageView *backgroundImg = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundImg.image = [PLVECUtils imageForWatchResource:@"plv_background_img"];
    [self.view addSubview:backgroundImg];
    
    self.displayView = [[UIView alloc] init];
    self.displayView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.displayView];
    
    self.backgroundView = [[UIView alloc] init];
    self.backgroundView.backgroundColor = [UIColor blackColor];
    self.backgroundView.hidden = YES;
    [self.view addSubview:self.backgroundView];
    
    UIImage *noLiveImage = [PLVECUtils imageForWatchResource:@"plv_skin_player_background"];
    self.noLiveImgView = [[UIImageView alloc] initWithImage:noLiveImage];
    [self.backgroundView addSubview:self.noLiveImgView];
    
    self.noLiveLabel = [[UILabel alloc] init];
    self.noLiveLabel.text = @"暂无直播";
    self.noLiveLabel.textColor = UIColor.whiteColor;
    self.noLiveLabel.textAlignment = NSTextAlignmentCenter;
    self.noLiveLabel.font = [UIFont systemFontOfSize:14.0];
    [self.backgroundView addSubview:self.noLiveLabel];
    
    [self layoutViewsFrame];
}

- (void)layoutViewsFrame {
    CGFloat scale = 16.0 / 9.0;
    self.backgroundView.frame = CGRectMake(0, 130, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds) / scale);
    self.noLiveImgView.frame = CGRectMake(CGRectGetWidth(self.backgroundView.bounds)/2-77, CGRectGetHeight(self.backgroundView.bounds)/2-60, 154, 120);
    self.noLiveLabel.frame = CGRectMake(CGRectGetWidth(self.backgroundView.bounds)/2-100, CGRectGetMaxY(self.noLiveImgView.frame)+12, 200, 14);
    
    if (self.landscapeMode) {
        // 16:9 显示模式
        self.displayView.frame = self.backgroundView.frame;
    } else {
        // 9:16 显示模式(刘海全屏裁剪)
        self.displayView.frame = CGRectMake(-(CGRectGetHeight(self.view.bounds) / scale - CGRectGetWidth(self.view.bounds)) / 2, 0, CGRectGetHeight(self.view.bounds) / scale, CGRectGetHeight(self.view.bounds));
        
        // 9:16 显示模式(刘海非全屏不裁剪)
        //self.playerSuperView.frame = self.view.bounds;
    }
}

#pragma mark - Public

- (void)playLive {
    [self.presenter reloadLive:nil];
}

- (void)pauseLive {
    [self.presenter pauseLive];
}

- (void)reloadLive {
    [self.presenter reloadLive:nil];
}

- (void)switchPlayLine:(NSUInteger)Line showHud:(BOOL)showHud {
    PLVProgressHUD *hud = nil;
    if (showHud) {
        hud = [PLVProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
        [hud.label setText:@"加载直播..."];
    }
    [self.presenter switchPlayLine:Line completion:^(NSError * _Nonnull error) {
        if (error && hud) {
            hud.label.text = [NSString stringWithFormat:@"加载直播失败:%@", error.localizedDescription];
        }
        [hud hideAnimated:YES];
    }];
}

- (void)switchPlayCodeRate:(NSString *)codeRate showHud:(BOOL)showHud {
    PLVProgressHUD *hud = nil;
    if (showHud) {
        hud = [PLVProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
        [hud.label setText:@"加载直播..."];
    }
    [self.presenter switchPlayCodeRate:codeRate completion:^(NSError * _Nonnull error) {
        if (error && hud) {
            hud.label.text = [NSString stringWithFormat:@"加载直播失败:%@", error.localizedDescription];
        }
        [hud hideAnimated:YES];
    }];
}

- (void)switchAudioMode:(BOOL)audioMode {
    [self showAudioAnimalView:audioMode];
    [self.presenter switchAudioMode:audioMode];
}

- (void)destroy {
    [self.presenter destroy];
}

#pragma mark - Priveta

- (void)showAudioAnimalView:(BOOL)show {
    if (!self.audioAnimalView) {
        self.audioAnimalView = [[PLVECAudioAnimalView alloc] init];
        self.audioAnimalView.frame = self.displayView.bounds;
        self.audioAnimalView.contentLable.text = @"音频直播中";
        [self.displayView addSubview:self.audioAnimalView];
    }
    [self.audioAnimalView setHidden:!show];
}

#pragma mark - <PLVLivePlayerPresenterDelegate>

- (void)presenter:(PLVLivePlayerPresenter *)presenter livePlayerStateDidChange:(LivePlayerState)livePlayerState {
    self.backgroundView.hidden = YES;
    switch (livePlayerState) {
        case LivePlayerStateEnd:
            self.backgroundView.hidden = NO;
            break;
        default:
            break;
    }
}

- (void)presenter:(PLVLivePlayerPresenter *)presenter loadMainPlayerFailure:(NSString *)message {
    PLVProgressHUD *hud = [PLVProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    hud.mode = PLVProgressHUDModeText;
    [hud.label setText:@"播放器加载失败"];
    hud.detailsLabel.text = message;
    [hud hideAnimated:YES afterDelay:2];
}

@end
