//
//  PLVECLiveViewController.m
//  PolyvLiveEcommerceDemo
//
//  Created by Lincal on 2020/4/30.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVECLiveViewController.h"
#import <PolyvFoundationSDK/PLVFdUtil.h>
#import "PLVLiveRoomPresenter.h"
#import "PLVSocketManager.h"
#import "PLVECLivePlayerViewController.h"
#import "PLVECChatroomController.h"
#import "PLVECRewardController.h"
#import "PLVECCommodityController.h"
#import "PLVECLiveHomePageView.h"
#import "PLVECLiveDetailPageView.h"
#import "PLVECUtils.h"

@interface PLVECLiveViewController () <PLVSocketObserverProtocol, PLVECLiveHomePageViewDelegate, PLVECRewardControllerProtocol>

// UI视图
@property (nonatomic, strong) PLVECLiveHomePageView *homePageView;
@property (nonatomic, strong) PLVECLiveDetailPageView *detailPageView;
@property (nonatomic, strong) UIButton *closeButton;

// 业务模块
@property (nonatomic, strong) PLVLiveRoomPresenter *presenter; // 当前直播间业务类
@property (nonatomic, strong) PLVSocketManager *socketManager; // 信令管理
@property (nonatomic, strong) PLVECLivePlayerViewController *playerVC; // 播放器控制器
@property (nonatomic, strong) PLVECChatroomController *chatroomCtrl; // 聊天室控制器
@property (nonatomic, strong) PLVECRewardController *rewardCtrl; // 打赏/礼物控制器
@property (nonatomic, strong) PLVECCommodityController *commodityCtrl; // 商品控制器

@property (nonatomic, strong) NSTimer *likeTimer;

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
    
    // 设置socket参数、登录
    self.socketManager = [[PLVSocketManager alloc] init];
    self.socketManager.roomData = self.presenter.roomData;
    [self.socketManager loginSocketServer];
    
    // 初始化直播播放器模块、添加视图
    self.playerVC = [[PLVECLivePlayerViewController alloc] init];
    self.playerVC.roomData = self.presenter.roomData;
    self.playerVC.landscapeMode = self.landscapeMode;
    
    self.playerVC.view.frame = self.view.bounds;
    [self.view insertSubview:self.playerVC.view atIndex:0];
    
    // 初始化聊天室模块、绑定视图
    self.chatroomCtrl = [[PLVECChatroomController alloc] init];
    self.chatroomCtrl.presenter.roomData = self.presenter.roomData;
    self.chatroomCtrl.presenter.socketManager = self.socketManager;
    self.chatroomCtrl.chatroomView = self.homePageView.chatroomView;
    
    // 初始化打赏/礼物控制器、设置代理
    self.rewardCtrl = [[PLVECRewardController alloc] init];
    self.rewardCtrl.delegate = self;
    self.rewardCtrl.socketManager = self.socketManager;
    
    // 初始化商品控制器，绑定视图
    self.commodityCtrl = [[PLVECCommodityController alloc] init];
    self.commodityCtrl.channel = self.presenter.roomData.channel;
    self.commodityCtrl.view = self.homePageView.commodityView;
    
    // 设置监听socket消息业务类
    [self.socketManager addObserver:self];
    [self.socketManager addObserver:self.chatroomCtrl];
    [self.socketManager addObserver:self.rewardCtrl];
    
    // 监听房间数据
    [self observeRoomData];
    
    // 本类业务功能
    [self initTimer];
    
    [self.presenter loadAndUpdateCurrentLiveRoomInfo];
    [self.presenter increaseCurrentLiveRoomExposure];
}

- (void)setupUI {
    CGRect scrollViewFrame = CGRectMake(0, P_TopOfEdgeInsets(), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - P_TopOfEdgeInsets());
    
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

    CGFloat closeBtn_y = 32.0;
    if (@available(iOS 11.0, *)) {
        closeBtn_y = self.view.safeAreaLayoutGuide.layoutFrame.origin.y+12.0;
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
    [self destroy];
    [self.playerVC destroy];
    [self.chatroomCtrl destroy];
    [self.socketManager destroy];
    
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

- (void)destroy {
    [self invalidateTimer];
    [self removeObserveRoomData];
}

#pragma mark - Timer

- (void)initTimer {
    if (!self.likeTimer) {
        self.likeTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(likeTimerTick) userInfo:nil repeats:YES];
    }
}

- (void)invalidateTimer {
    if (self.likeTimer) {
        [self.likeTimer invalidate];
        self.likeTimer = nil;
    }
}

- (void)likeTimerTick {
    /// 每10s随机显示一些点赞动画
    for (int i=0; i<rand()%4+1; i++) {
        [self.homePageView showLikeAnimation];
    }
}

#pragma mark - KVO

- (void)observeRoomData {
    PLVLiveRoomData *roomData = self.presenter.roomData;
    [roomData addObserver:self forKeyPath:KEYPATH_LIVEROOM_CHANNEL options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    [roomData addObserver:self forKeyPath:KEYPATH_LIVEROOM_VIEWCOUNT options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    [roomData addObserver:self forKeyPath:KEYPATH_LIVEROOM_LIKECOUNT options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    [roomData addObserver:self forKeyPath:KEYPATH_LIVEROOM_LIVESTATE options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    [roomData addObserver:self forKeyPath:KEYPATH_LIVEROOM_LINES options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserveRoomData {
    PLVLiveRoomData *roomData = self.presenter.roomData;
    [roomData removeObserver:self forKeyPath:KEYPATH_LIVEROOM_CHANNEL];
    [roomData removeObserver:self forKeyPath:KEYPATH_LIVEROOM_VIEWCOUNT];
    [roomData removeObserver:self forKeyPath:KEYPATH_LIVEROOM_LIKECOUNT];
    [roomData removeObserver:self forKeyPath:KEYPATH_LIVEROOM_LIVESTATE];
    [roomData removeObserver:self forKeyPath:KEYPATH_LIVEROOM_LINES];
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
                break;
            }
        }
    } else if ([keyPath isEqualToString:KEYPATH_LIVEROOM_VIEWCOUNT]) { // 观看热度
        [self.homePageView updateWatchViewCount:roomData.watchViewCount];
    } else if ([keyPath isEqualToString:KEYPATH_LIVEROOM_LIKECOUNT]) { // 点赞数
        [self.homePageView updateLikeCount:roomData.likeCount];
    } else if ([keyPath isEqualToString:KEYPATH_LIVEROOM_LIVESTATE]) { // 直播状态
        [self.homePageView updatePlayerState:roomData.liveState == PLVLiveStreamStateLive];
    } else if ([keyPath isEqualToString:KEYPATH_LIVEROOM_LINES]) {     // 多线路
        [self.homePageView updateLineCount:roomData.lines];
    }
}

#pragma mark - <PLVSocketObserverProtocol>

- (void)socketDidReceiveMessage:(NSString *)string jsonDict:(NSDictionary *)jsonDict {
    NSString *userIdForWatchUser = self.presenter.roomData.userIdForWatchUser;
    
    NSString *subEvent = PLV_SafeStringForDictKey(jsonDict, @"EVENT");
    if ([subEvent isEqualToString:@"BULLETIN"]) {               // 公告消息
        NSString *content = PLV_SafeStringForDictKey(jsonDict, @"content");
        [self.homePageView showBulletinView:content];
        [self.detailPageView addBulletinCardView:content];
    } else if ([subEvent isEqualToString:@"REMOVE_BULLETIN"]) { // 删除公告消息
        [self.detailPageView removeBulletinCardView];
    }else if ([subEvent isEqualToString:@"LOGIN_REFUSE"]) {
        [self exitCurrentControllerWithAlert:nil message:@"您未被授权观看本直播"];
    } else if ([subEvent isEqualToString:@"RELOGIN"]) {
        [self exitCurrentControllerWithAlert:nil message:@"当前账号已在其他地方登录，您将被退出观看"];
    } else if ([subEvent isEqualToString:@"LOGIN"]) {   // someone logged in chatroom
        NSDictionary *user = PLV_SafeDictionaryForDictKey(jsonDict, @"user");
        NSString *userId = PLV_SafeStringForDictKey(user, @"userId");;
        if (![userId isEqualToString:userIdForWatchUser]) {
            self.presenter.roomData.watchViewCount ++;
        }
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
    }
}

#pragma mark - <PLVECLiveHomePageViewDelegate>

- (void)homePageView:(PLVECLiveHomePageView *)homePageView switchPlayLine:(NSUInteger)line {
    [self.playerVC switchPlayLine:line];
}

- (void)homePageView:(PLVECLiveHomePageView *)homePageView switchAudioMode:(BOOL)audioMode {
    [self.playerVC switchAudioMode:audioMode];
}

- (void)likeActionInHomePageView:(PLVECLiveHomePageView *)homePageView {
    [self.chatroomCtrl likeAction];
}

- (void)homePageView:(PLVECLiveHomePageView *)homePageView rewardGift:(nonnull NSString *)giftName giftType:(nonnull NSString *)giftType {
    PLVLiveWatchUser *watchUser = self.presenter.roomData.watchUser;
    NSString *nickName = watchUser.nickName;
    [homePageView showGiftAnimation:nickName giftName:giftName giftType:giftType duration:2.0];
    
    [self.rewardCtrl emitGiftMessage:giftName giftType:giftType];
}

- (BOOL)playerIsPlaying {
    return self.presenter.roomData.liveState == PLVLiveStreamStateLive;
}

#pragma mark - <PLVECRewardControllerProtocol>

- (void)rewardController:(PLVECRewardController *)rewardController didReceiveGiftMessage:(NSDictionary *)jsonDict {
    NSDictionary *user = PLV_SafeDictionaryForDictKey(jsonDict, @"user");
    NSDictionary *data = PLV_SafeDictionaryForDictKey(jsonDict, @"data");
    NSString *userIdForWatchUser = self.presenter.roomData.userIdForWatchUser;
    if ([userIdForWatchUser isEqualToString:PLV_SafeStringForDictKey(user, @"userId")]) {
        return;
    }
    
    NSString *nickName = PLV_SafeStringForDictKey(user, @"nick");
    NSString *giftName = PLV_SafeStringForDictKey(data, @"giftName");
    NSString *giftType = PLV_SafeStringForDictKey(data, @"giftType");
    [self.homePageView showGiftAnimation:nickName giftName:giftName giftType:giftType duration:2.0];
}

@end
