## 一、概述

该Demo演示直播带货的一个场景应用，包含播放器、聊天室、打赏（自定义消息）、商品（商品库后台 http://live.polyv.net/goods-shelves.html）功能。



## 二、Demo 介绍

### （2.1）Demo 体验步骤

（1）打开终端，cd 至Demo路径下，pod install 安装依赖库。或 pod update

（2）可直接运行，在界面上填写相关参数信息，或在 AppDelegate.m 中配置保利威账户信息



### （2.2）Demo 文件构成

```shell
├── Podfile
├── Podfile.lock
├── PolyvLiveScenesDemo            demo 层
│   ├── AppDelegate.h
│   ├── Demo
│   │   ├── ViewController.h
│   ├── PolyvLiveCommonModul       CommonModel 层
│   │   ├── Business
│   │   │   ├── Chatroom
│   │   │   └── LiveRoom
│   │   ├── Common
│   │   ├── Config
│   │   │   ├── PLVLiveSDKConfig.h     /// 直播SDK配置信息
│   │   ├── DataService
│   │   │   ├── PLVLiveChannel.h				/// 直播频道信息（初始化配置）
│   │   │   ├── PLVLiveRoomData.h       /// 直播间数据（房间信息、状态）
│   │   └── Interactor
│   │       ├── PLVSceneLoginManager.h
│   │       ├── PLVSocketManager.h
│   ├── PolyvLiveEcommerceScene     直播带货场景层
│   │   ├── Modules
│   │   │   ├── Chatroom(聊天室)
│   │   │   ├── Commodity(商品) 
│   │   │   ├── Player(播放器)
│   │   │   └── Reward(打赏)
│   │   ├── Resource			资源
│   │   ├── Scene
│   │   │   ├── Live	        /// 直播带货场景直播页
│   │   │   ├── Playback      /// 直播带货场景回放页
│   │   │   └── Views
│   │   │       ├── BulletinView   公告视图
│   │   │       ├── ChatroomView    聊天室视图
│   │   │       ├── CommodityView   商品视图
│   │   │       ├── CommonBaseView   公共基础视图
│   │   │       ├── LiveIntroductionView  直播介绍卡片
│   │   │       ├── LiveRoomInfoView       直播间信息视图
│   │   │       ├── MoreView               更多视图
│   │   │       ├── PlayerContolView       播放控制视图 
│   │   │       ├── RewardView					打赏视图
│   │   │       ├── SwitchView					切换视图
│   │   │       ├── PLVECLiveDetailPageView.h  直播详情视图页面
│   │   │       ├── PLVECLiveHomePageView.h		 直播首页视图页面
│   │   │       └── PLVECPalybackHomePageView.h 回放首页视图页面
```



## 三、集成至自家项目

###（3.1）集成步骤

（1）集成 云课堂SDK（PolyvCloudClassSDK），可参考 [Github 文档](https://github.com/polyv/polyv-ios-cloudClass-sdk-demo/wiki/2-%E5%BF%AB%E9%80%9F%E9%9B%86%E6%88%90) 中的 [ 2 开始集成 ] 小节。

```
target 'PolyvLiveScenesDemo' do
  use_frameworks!
  pod 'PolyvCloudClassSDK','~> 0.14.0'

end
```

注意：需要 use_frameworks!（建议）如不添加改配置，请参考 [wiki]([https://github.com/polyv/polyv-ios-cloudClass-sdk-demo/wiki/2-%E5%BF%AB%E9%80%9F%E9%9B%86%E6%88%90](https://github.com/polyv/polyv-ios-cloudClass-sdk-demo/wiki/2-快速集成))

（2）将 PolyvLiveEcommerceScene、PolyvLiveCommonModul 文件夹添加至自己项目中即可

  (3)  初始化参看demo：ViewController.m



### （3.2）PolyvLiveScenesDemo 简介

####（3.2.1）PLVECLiveViewController.m 直播观看页

```
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
```



####（3.2.2）PLVECPlaybackViewController.m 直播回放观看页



```objective-c
// UI视图
@property (nonatomic, strong) PLVECPalybackHomePageView *homePageView;
@property (nonatomic, strong) UIButton *closeButton;

// 业务模块
@property (nonatomic, strong) PLVLiveRoomPresenter *presenter; // 当前直播间业务类
@property (nonatomic, strong) PLVECPlaybackPlayerViewController *playerVC; // 播放器控制器

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
    self.playerVC.roomData = self.presenter.roomData;
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



### （3.3）自定义功能

可添加自定义模块，绑定视图即可

该项目场景层基本将功能模块视图和控制器进行了解绑，仔细阅读核心三部分源码 ViewController、PLVECLiveViewController.m、PLVECPlaybackViewController.m，可知晓大致开发逻辑。



#### （3.3.1）商品功能

视图类：CommodityView/PLVECCommodityView

控制器：Commodity(商品) /PLVECCommodityController

在 PLVECLiveViewController 控制器中绑定关系



demo 中接入和演示的是保利威后台商品管理系统的前端显示，如果外接商品系统，替换相关功能模块代码即可，UI 可参考 demo 或自行实现。



#### （3.3.2）打赏功能

视图类：Scene/Views/RewardView/PLVECRewardView

控制器：Modules/Reward(打赏) /PLVECCommodityController

在 PLVECLiveViewController 控制器中绑定关系



打赏控制器中演示了如何接受自定义消息，及发送自定义消息的打赏信息，可参考该部分代码实现自定义打赏功能，相关交互替换demo打赏模块代码即可。

