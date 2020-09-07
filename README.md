# polyv-ios-liveEcommerce-sdk-demo


## 一、概述

本项目演示直播带货一个应用场景，主要包括直播、回放、播放器、聊天室、打赏、商品展示/推送、直播介绍、公告功能。


## 二、Demo 介绍

### 2.1 Demo 体验步骤

（1）打开终端，cd 至 Demo 路径下（Podfile 同级目录），执行 `pod install` 或 `pod update` 下载依赖库

（2）直接运行 *.xcworkspace 工程文件，通过在 AppDelegate.m 中配置保利威账户信息 或 在界面上填写相关参数信息进入直播、回放页

（3）下载 demo 体验，[点击安装](https://www.pgyer.com/SjY3)，或扫描下方二维码使用 Safari 安装（密码 polyv）

![](https://www.pgyer.com/app/qrcode/SjY3)


### 2.2 Demo 文件结构

```
├── Podfile
├── Podfile.lock
├── PolyvLiveScenesDemo            
│   ├── AppDelegate.h
│   ├── Demo
│   │   ├── ViewController.h  //演示登录
│   ├── PolyvLiveEcommerceScene       /// 直播带货场景层
│   │   ├── Views
│   │   │       ├── BulletinView                //公告视图
│   │   │       ├── CommonBaseView              //公共基础视图
│   │   │       ├── LiveIntroductionView        //直播介绍卡片
│   │   │       ├── LiveRoomInfoView            //直播间信息视图
│   │   │       ├── MoreView                    //更多视图
│   │   │       ├── PlayerContolView            //播放控制视图 
│   │   │       ├── RewardView                  //打赏视图
│   │   │       ├── SwitchView                  //切换视图
│   │   ├── Controllers
│   │   │   ├── PLVECLiveViewController  //直播带货场景直播页
│   │   │   ├── PLVECPlaybackViewController //直播带货场景回放页
│   │   │   └── PageViews
│   │   │       ├── PLVECLiveDetailPageView //直播详情视图页面
│   │   │       ├── PLVECLiveHomePageView //直播首页视图页面
│   │   │       └── PLVECPalybackHomePageView //回放首页视图页面
│   │   ├── Modules
│   │   │   ├── Chatroom(聊天室)
│   │   │   ├── Commodity(商品) 
│   │   │   ├── Player(播放器)
│   │   │   └── Reward(打赏)
│   │   ├── Resource			资源
│   ├── PolyvLiveCommonModul            /// CommonModul 层
│   │   ├── Modules
│   │   │   ├── Chatroom  // 聊天室
│   │   │   ├── Player    // 播放器
│   │   │   └── LiveRoom  // 直播间
│   │   └── DataInteractor
│   │       ├── PLVSceneLoginManager.h  // 登录管理
│   │       ├── PLVSocketManager.h      // socket 管理
│   │   ├── DataService
│   │   │   ├── PLVLiveChannel.h      //直播频道信息（初始化配置）
│   │   │   ├── PLVLiveRoomData.h     //直播间数据（房间信息、状态）
│   │   ├── Config
│   │   │   ├── PLVLiveSDKConfig.h    //直播SDK配置信息
│   │   ├── Common
│   ├── Supporting Files
```


## 三、项目集成

### 3.1 环境要求

- iOS 8.0 及以上

- Xcode 10.0 及以上

### 3.2 集成步骤

（1）添加云课堂 SDK（PolyvCloudClassSDK）依赖，可参考 [Github 文档](https://github.com/polyv/polyv-ios-cloudClass-sdk-demo/wiki/2-%E5%BF%AB%E9%80%9F%E9%9B%86%E6%88%90) 中的 [ 2 开始集成 ] 小节。

```ruby
target 'PolyvLiveScenesDemo' do
  use_frameworks!
  pod 'PolyvCloudClassSDK','~> 0.14.0'
end
```

注意：需要 use_frameworks!（建议）如不添加该配置，请参考 [wiki]([https://github.com/polyv/polyv-ios-cloudClass-sdk-demo/wiki/2-%E5%BF%AB%E9%80%9F%E9%9B%86%E6%88%90](https://github.com/polyv/polyv-ios-cloudClass-sdk-demo/wiki/2-快速集成))

（2）将 PolyvLiveEcommerceScene、PolyvLiveCommonModul 文件夹添加至集成项目中

（3）参数配置，需要配置 userId、appId、appSecret 等关键参数，保利威直播后台可获取。

```objective-c
// 账户信息配置
[PLVLiveSDKConfig configAccountWithUserId:@"" appId:@"" appSecret:@""];
```

（4）进入观看页，可参看 demo ViewController.m 实例代码

- 进入直播页

```objective-c
- (IBAction)watchLiveBtnClick:(id)sender {
    [self.view endEditing:YES];
    
    if (![self initParams:YES]) {
        return;
    }
    
    PLVProgressHUD *hud = [PLVProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    [hud.label setText:@"登录中..."];
    
    __weak typeof(self)weakSelf = self;
    // 登录直播带货场景直播页
    [PLVSceneLoginManager loginLiveRoom:self.channelId completion:^(NSString * _Nonnull liveType, PLVLiveStreamState liveState, NSDictionary * _Nonnull data) {
        [hud hideAnimated:YES];
        [weakSelf saveParamsToFile];
        
        if ([liveType isEqualToString:@"ppt"]) {
            [weakSelf showHud:@"该场景暂不支持三分屏频道类型！" detail:nil];
            return;
        }
        
        // 配置观看用户信息、频道及帐号信息
        PLVLiveWatchUser *watchUser = [PLVLiveWatchUser watchUserWithUserId:nil nickName:@"iOS user" avatarUrl:nil];
        PLVLiveChannel *channel = [PLVLiveChannel channelWithChannelId:self.channelId watchUser:watchUser account:PLVLiveSDKConfig.sharedSDK.account];
        
        // 配置房间初始状态
        PLVLiveRoomData *roomData = [[PLVLiveRoomData alloc] initWithLiveChannel:channel];
        [roomData setPrivateDomainWithData:data];
        roomData.liveState = liveState;
        
        // 设置直播观看页相关配置、进入观看页
        PLVECLiveViewController * watchLiveVC = [[PLVECLiveViewController alloc] initWithLiveRoomData:roomData];
        watchLiveVC.landscapeMode = !weakSelf.displayModeSwitch.isOn;
        
        if (PushOrModel) {
            [weakSelf.navigationController pushViewController:watchLiveVC animated:YES];
        }else{
            watchLiveVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [weakSelf presentViewController:watchLiveVC animated:YES completion:nil];
        }
    } failure:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [weakSelf showHud:@"进入直播间失败！" detail:error.localizedDescription];
    }];
}
```

- 进入回放页

```objective-c
- (IBAction)watchPlaybackBtnClick:(id)sender {
    [self.view endEditing:YES];
    
    if (![self initParams:NO]) {
        return;
    }
    
    PLVProgressHUD *hud = [PLVProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    [hud.label setText:@"登录中..."];
    
    __weak typeof(self)weakSelf = self;
    // 登录直播带货场景回放页
    [PLVSceneLoginManager loginPlaybackLiveRoom:self.channelId vid:self.vid completion:^(BOOL vodType, NSDictionary * _Nonnull data) {
        [hud hideAnimated:YES];
        [weakSelf saveParamsToFile];
        
        if (vodType) {
            [weakSelf showHud:@"该场景暂不支持三分屏频道类型！" detail:nil];
            return;
        }
        
        // 配置频道及帐号信息
        PLVLiveChannel *channel = [PLVLiveChannel channelWithChannelId:self.channelId vid:self.vid account:PLVLiveSDKConfig.sharedSDK.account];
        
        // 配置房间初始状态
        PLVLiveRoomData *roomData = [[PLVLiveRoomData alloc] initWithLiveChannel:channel];
        [roomData setPrivateDomainWithData:data];
        
        // 进入回放观看页
        PLVECPlaybackViewController * watchPlaybackVC = [[PLVECPlaybackViewController alloc] initWithLiveRoomData:roomData];
        watchPlaybackVC.landscapeMode = !weakSelf.displayModeSwitch.isOn;
        
        if (PushOrModel) {
            [weakSelf.navigationController pushViewController:watchPlaybackVC animated:YES];
        }else{
            watchPlaybackVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [weakSelf presentViewController:watchPlaybackVC animated:YES completion:nil];
        }
    } failure:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [weakSelf showHud:@"进入直播回放失败！" detail:error.localizedDescription];
    }];
}
```

## 四、项目简介 

PolyvLiveScenesDemo 下主要有三部分：Demo、xxxScene、PolyvLiveCommonModule

### 4.1 Demo 

使用示例，集成本项目时直接参考 demo 使用即可。

### 4.2 PolyvLiveCommonModule 公共模块

场景层或 app 使用，部分业务类也在此层。

### 4.3 PolyvLiveEcommerceScene 直播带货

#### 4.3.1 观看页

- PLVECLiveViewController.m 直播观看页


```objective-c
@interface PLVECLiveViewController () <PLVSocketObserverProtocol, PLVECLiveHomePageViewDelegate>

// UI视图
@property (nonatomic, strong) PLVECLiveHomePageView *homePageView;
@property (nonatomic, strong) PLVECLiveDetailPageView *detailPageView;
@property (nonatomic, strong) UIButton *closeButton;

// 业务模块
@property (nonatomic, strong) PLVLiveRoomPresenter *presenter; // 当前直播间业务类
@property (nonatomic, strong) PLVECLivePlayerViewController *playerVC; // 播放器控制器
@property (nonatomic, strong) PLVECChatroomPresenter *chatroomPresenter; // 聊天室控制器

@end

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
    self.playerVC.landscapeMode = self.landscapeMode;
    
    self.playerVC.view.frame = self.view.bounds;
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
```

- PLVECPlaybackViewController.m 直播回放观看页


```objective-c
@interface PLVECPlaybackViewController () <PLVPalybackHomePageViewDelegate, PLVECPlaybackPlayerViewControlDelegate>

// UI视图
@property (nonatomic, strong) PLVECPalybackHomePageView *homePageView;
@property (nonatomic, strong) UIButton *closeButton;

// 业务模块
@property (nonatomic, strong) PLVLiveRoomPresenter *presenter; // 当前直播间业务类
@property (nonatomic, strong) PLVECPlaybackPlayerViewController *playerVC; // 播放器控制器

@end

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化页面UI
    [self setupUI];
    
    if (!self.presenter) {
        NSLog(@"%@ 初始化失败！请调用 -initWithChannel:roomData: API 初始化",NSStringFromClass(self.class));
        return;
    }
    
    // 初始化播放器控制器、绑定视图、设置代理
    self.playerVC = [[PLVECPlaybackPlayerViewController alloc] init];
    self.playerVC.presenter.roomData = self.presenter.roomData;
    self.playerVC.landscapeMode = self.landscapeMode;
    self.playerVC.delegate = self;
    
    self.playerVC.view.frame = self.view.bounds;
    [self.view insertSubview:self.playerVC.view atIndex:0];
    
    // 本类业务功能
    [self.presenter loadAndUpdateCurrentLiveRoomInfo];
    [self.presenter increaseCurrentLiveRoomExposure];
    
    [self observeRoomData];
}
```

#### 4.3.2 自定义功能

场景层代码已开源，可自定义 UI 或部分业务功能，本项目模块耦合度较低，可参考 PLVECLiveViewController、PLVECPlaybackViewController 中的使用。

- 商品模块

```
Commodity(商品) 
├── Cell
│   ├── PLVECCommodityCell.h
├── CellModel
│   ├── PLVECCommodityCellModel.h
├── Model
│   ├── PLVECCommodityModel.h
├── Presenter
│   ├── PLVECCommodityPresenter.h
├── View
│   ├── PLVECCommodityPushView.h
│   ├── PLVECCommodityView.h
└── ViewModel
    ├── PLVECCommodityViewModel.h
```

在 PLVECLiveHomePageView 视图中初始化和绑定，默认对接保利威直播后台商品管理（直播后台->云直播->观看页管理->商品库），如果外接商品系统，需自行替换相关功能模块及实现。

- 打赏模块

```
Reward(打赏)
├── Controller
│   ├── PLVECRewardController.h
└── View
    ├── PLVECGiftView.h
    ├── PLVECRewardView.h
```

在 PLVECLiveHomePageView 视图中初始化和绑定，打赏控制器中演示了处理自定义打赏消息及发送自定义打赏信息，可参考该部分功能实现自定义打赏功能。
