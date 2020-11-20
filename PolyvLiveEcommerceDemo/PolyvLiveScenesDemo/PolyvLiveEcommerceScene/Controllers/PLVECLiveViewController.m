//
//  PLVECLiveViewController.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/4/30.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVECLiveViewController.h"
#import <PolyvFoundationSDK/PLVFdUtil.h>
#import "PLVLiveRoomPresenter.h"
#import "PLVECLivePlayerViewController.h"
#import "PLVECChatroomPresenter.h"
#import "PLVECLiveHomePageView.h"
#import "PLVECLiveDetailPageView.h"
#import "PLVECUtils.h"

@interface PLVECLiveViewController () <PLVSocketObserverProtocol, PLVECLiveHomePageViewDelegate, PLVECLivePlayerProtocol>

// UI视图
@property (nonatomic, strong) PLVECLiveHomePageView *homePageView;
@property (nonatomic, strong) PLVECLiveDetailPageView *detailPageView;
@property (nonatomic, strong) UIButton *closeButton;

// 业务模块
@property (nonatomic, strong) PLVLiveRoomPresenter *presenter; // 当前直播间业务类
@property (nonatomic, strong) PLVECLivePlayerViewController *playerVC; // 播放器控制器
@property (nonatomic, strong) PLVECChatroomPresenter *chatroomPresenter; // 聊天室控制器

@end

@implementation PLVECLiveViewController

#pragma mark - Life Cycle

- (void)dealloc {
    NSLog(@"%s",__FUNCTION__);
}

- (instancetype)initWithLiveRoomData:(PLVLiveRoomData *)roomData {
    self = [super init];
    if (self) {
        self.presenter = [[PLVLiveRoomPresenter alloc] init];
        self.presenter.roomData = roomData;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化页面UI
    [self setupUI];
    
    if (!self.presenter) {
        NSLog(@"%@ 初始化失败！请调用 -initWithChannel:roomData: API 初始化",NSStringFromClass(self.class));
        return;
    }
    
    // 初始化直播播放器模块、添加视图
    self.playerVC = [[PLVECLivePlayerViewController alloc] init];
    self.playerVC.presenter.roomData = self.presenter.roomData;
    
    self.playerVC.view.frame = self.view.bounds;
    self.playerVC.delegate = self;
    [self.view insertSubview:self.playerVC.view atIndex:0];
    
    // 初始化聊天室模块、绑定视图
    self.chatroomPresenter = [[PLVECChatroomPresenter alloc] init];
    self.chatroomPresenter.roomData = self.presenter.roomData;
    self.chatroomPresenter.view = self.homePageView.chatroomView;
    
    [self.chatroomPresenter loginSocketServer];  // 登录聊天室
    [self.chatroomPresenter addObserver:self];   // 监听聊天室socket消息
    
    // 监听房间数据
    [self observeRoomData];
    
    [self.presenter loadAndUpdateCurrentLiveRoomInfo];
    [self.presenter increaseCurrentLiveRoomExposure];
}

- (void)setupUI {
    CGRect scrollViewFrame = CGRectMake(0, P_SafeAreaTopEdgeInsets(), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - P_SafeAreaTopEdgeInsets());
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(scrollViewFrame) * 3, CGRectGetHeight(scrollViewFrame));
    scrollView.contentOffset = CGPointMake(CGRectGetWidth(scrollViewFrame), 0);
    scrollView.pagingEnabled = YES;
    scrollView.backgroundColor = UIColor.clearColor;
    scrollView.bounces = NO;
    scrollView.alwaysBounceVertical = NO;
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    self.homePageView = [[PLVECLiveHomePageView alloc] init];
    self.homePageView.frame = CGRectMake(CGRectGetWidth(scrollViewFrame), 0, CGRectGetWidth(scrollViewFrame), CGRectGetHeight(scrollViewFrame));
    self.homePageView.delegate = self;
    [scrollView addSubview:self.homePageView];
    
    self.detailPageView = [[PLVECLiveDetailPageView alloc] init];
    self.detailPageView.frame = CGRectMake(0, 0, CGRectGetWidth(scrollViewFrame), CGRectGetHeight(scrollViewFrame));
    [scrollView addSubview:self.detailPageView];
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeButton setImage:[PLVECUtils imageForWatchResource:@"plv_close_btn"] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeButton];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    CGFloat closeBtn_y = 32.f;
    if (@available(iOS 11.0, *)) {
        closeBtn_y = self.view.safeAreaLayoutGuide.layoutFrame.origin.y + 12;
    }
    self.closeButton.frame = CGRectMake(CGRectGetWidth(self.view.bounds)-47, closeBtn_y, 32, 32);
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - View control

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma makr - Action

- (void)closeButtonAction:(UIButton *)button {
    [self exitCurrentController];
}

#pragma mark - Private

- (void)exitCurrentController {
    [self removeObserveRoomData];
    [self.homePageView destroy];
    [self.playerVC destroy];
    [self.chatroomPresenter destroy];
    
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)exitCurrentControllerWithAlert:(NSString *)title message:(NSString *)message {
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf exitCurrentController];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - KVO

- (void)observeRoomData {
    PLVLiveRoomData *roomData = self.presenter.roomData;
    [roomData addObserver:self forKeyPath:KEYPATH_LIVEROOM_CHANNEL options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    [roomData addObserver:self forKeyPath:KEYPATH_LIVEROOM_ONLINECOUNT options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    [roomData addObserver:self forKeyPath:KEYPATH_LIVEROOM_LIKECOUNT options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    [roomData addObserver:self forKeyPath:KEYPATH_LIVEROOM_LIVESTATE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserveRoomData {
    PLVLiveRoomData *roomData = self.presenter.roomData;
    [roomData removeObserver:self forKeyPath:KEYPATH_LIVEROOM_CHANNEL];
    [roomData removeObserver:self forKeyPath:KEYPATH_LIVEROOM_ONLINECOUNT];
    [roomData removeObserver:self forKeyPath:KEYPATH_LIVEROOM_LIKECOUNT];
    [roomData removeObserver:self forKeyPath:KEYPATH_LIVEROOM_LIVESTATE];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (![object isKindOfClass:PLVLiveRoomData.class]) {
        return;
    }
    
    PLVLiveRoomData *roomData = object;
    if ([keyPath isEqualToString:KEYPATH_LIVEROOM_CHANNEL]) { // 频道信息
        if (!roomData.channelInfo)
            return;
        [self.homePageView updateChannelInfo:roomData.channelInfo.publisher coverImage:roomData.channelInfo.coverImage];
        for (PLVLiveVideoChannelMenu *menu in roomData.channelInfo.channelMenus) {
            if ([menu.menuType isEqualToString:@"desc"]) {
                [self.detailPageView addLiveInfoCardView:menu.content];
            } else if ([menu.menuType isEqualToString:@"buy"]) {
                self.homePageView.shoppingCardButton.hidden = NO;
            }
        }
    } else if ([keyPath isEqualToString:KEYPATH_LIVEROOM_ONLINECOUNT]) { // 在线人数
        [self.homePageView updateOnlineCount:roomData.onlineCount];
    } else if ([keyPath isEqualToString:KEYPATH_LIVEROOM_LIKECOUNT]) { // 点赞数
        [self.homePageView updateLikeCount:roomData.likeCount];
    } else if ([keyPath isEqualToString:KEYPATH_LIVEROOM_LIVESTATE]) { // 直播状态
        [self.homePageView updatePlayerState:roomData.liveState == PLVLiveStreamStateLive];
    }
}

#pragma mark - <PLVSocketObserverProtocol>

- (void)socketDidReceiveMessage:(NSString *)string jsonDict:(NSDictionary *)jsonDict {
    NSString *userIdForWatchUser = self.presenter.roomData.userIdForWatchUser;
    
    NSString *subEvent = PLV_SafeStringForDictKey(jsonDict, @"EVENT");
    if ([subEvent isEqualToString:@"LOGIN"]) {
        [self.chatroomPresenter loadHistoryAtFirstTime];
    } else if ([subEvent isEqualToString:@"BULLETIN"]) {               // 公告消息
        NSString *content = PLV_SafeStringForDictKey(jsonDict, @"content");
        [self.homePageView showBulletinView:content];
        [self.detailPageView addBulletinCardView:content];
    } else if ([subEvent isEqualToString:@"REMOVE_BULLETIN"]) { // 删除公告消息
        [self.detailPageView removeBulletinCardView];
    }else if ([subEvent isEqualToString:@"LOGIN_REFUSE"]) {
        [self exitCurrentControllerWithAlert:nil message:@"您未被授权观看本直播"];
    } else if ([subEvent isEqualToString:@"RELOGIN"]) {
        [self exitCurrentControllerWithAlert:nil message:@"当前账号已在其他地方登录，您将被退出观看"];
    } else if ([subEvent isEqualToString:@"LIKES"]) {  // 点赞消息
        if ([userIdForWatchUser isEqualToString:PLV_SafeStringForDictKey(jsonDict, @"userId")]) {
            return;
        }
        NSUInteger count = PLV_SafeIntegerForDictKey(jsonDict, @"count");
        self.presenter.roomData.likeCount += count;
        count = MIN(5, count);
        for (int i=0; i<count; i++) {
            [self.homePageView showLikeAnimation];
        }
    } else if ([subEvent isEqualToString:@"PRODUCT_MESSAGE"]) {
        [self.homePageView receiveProductMessage:jsonDict];
    }
}

- (void)socketDidReceiveEvent:(NSString *)event jsonDict:(NSDictionary *)jsonDict {
    if (![event isEqualToString:@"customMessage"]) {
        return;
    }
    
    [self.homePageView receiveCustomMessage:jsonDict];
}

#pragma mark - PLVECLivePlayer Protocol

- (void)playerController:(PLVECLivePlayerViewController *)playerController
           codeRateItems:(NSArray <NSString *>*)codeRateItems
                codeRate:(NSString *)codeRate
                   lines:(NSUInteger)lines
                    line:(NSInteger)line {
    [self.homePageView updateCodeRateItems:codeRateItems defaultCodeRate:codeRate];
    [self.homePageView updateLineCount:lines defaultLine:line];
}

#pragma mark - <PLVECLiveHomePageViewDelegate>

- (PLVLiveRoomData *)currentLiveRoomData {
    return self.presenter.roomData;
}

- (void)homePageView:(PLVECLiveHomePageView *)homePageView switchPlayLine:(NSUInteger)line {
    [self.playerVC switchPlayLine:line showHud:NO];
}

- (void)homePageView:(PLVECLiveHomePageView *)homePageView switchCodeRate:(NSString *)codeRate {
    [self.playerVC switchPlayCodeRate:codeRate showHud:NO];
}

- (void)homePageView:(PLVECLiveHomePageView *)homePageView switchAudioMode:(BOOL)audioMode {
    [self.playerVC switchAudioMode:audioMode];
}

- (void)likeActionInHomePageView:(PLVECLiveHomePageView *)homePageView {
    [self.chatroomPresenter likeAction];
}

- (void)emitCustomEvent:(NSString *)event emitMode:(int)emitMode data:(NSDictionary *)data tip:(NSString *)tip {
    [self.chatroomPresenter emitCustomEvent:event emitMode:emitMode data:data tip:tip];
}

- (BOOL)playerIsPlaying {
    return self.presenter.roomData.liveState == PLVLiveStreamStateLive;
}

@end
