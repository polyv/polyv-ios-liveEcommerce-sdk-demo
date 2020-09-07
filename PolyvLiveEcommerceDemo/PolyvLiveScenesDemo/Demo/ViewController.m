//
//  ViewController.m
//  PolyvLiveEcommerceDemo
//
//  Created by Lincal on 2020/4/29.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "ViewController.h"
#import <PolyvFoundationSDK/PLVProgressHUD.h>
#import "PLVECLiveViewController.h"
#import "PLVECPlaybackViewController.h"
#import "PLVSceneLoginManager.h"
#import "PLVLiveSDKConfig.h"

#define PushOrModel 0 // 进入页面方式（1-push、0-model）

static NSString *kPLVUserDefaultLoginInfoKey = @"kPLVUserDefaultLoginInfoKey_demo";

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *appIdTF;
@property (weak, nonatomic) IBOutlet UITextField *userIdTF;
@property (weak, nonatomic) IBOutlet UITextField *appSecretTF;
@property (weak, nonatomic) IBOutlet UITextField *channelIdTF;
@property (weak, nonatomic) IBOutlet UITextField *vodIdTF;

@property (weak, nonatomic) IBOutlet UILabel *displayModeLable;
@property (weak, nonatomic) IBOutlet UISwitch *displayModeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *defaultParamSwitch;

@property (nonatomic, copy) NSString *channelId;
@property (nonatomic, copy) NSString *vid;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

#ifdef RunMode
    [self developerTest];
#endif
    
    [self configUIData];
}

- (void)configUIData {
    PLVLiveAccount *accouunt = PLVLiveSDKConfig.sharedSDK.account;
    if (accouunt) { // 从SDK配置中还原
        self.appIdTF.text = accouunt.appId;
        self.userIdTF.text = accouunt.userId;
        self.appSecretTF.text = accouunt.appSecret;
    } else { // 从UserDefault中还原
        [self recoverParamsFromFile];
    }
}

- (void)recoverParamsFromFile {
    NSArray *loginInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kPLVUserDefaultLoginInfoKey];
    if (loginInfo.count < 5) {
        return;
    }
    self.appIdTF.text = loginInfo[0];
    self.userIdTF.text = loginInfo[1];
    self.appSecretTF.text = loginInfo[2];
    
    self.channelIdTF.text = loginInfo[3];
    self.vodIdTF.text = loginInfo[4];
}

- (void)saveParamsToFile {
    [[NSUserDefaults standardUserDefaults] setObject:@[self.appIdTF.text, self.userIdTF.text, self.appSecretTF.text, self.channelIdTF.text, self.vodIdTF.text] forKey:kPLVUserDefaultLoginInfoKey];
}

#pragma mark - Action

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

- (IBAction)displayModeSwitchAction:(UISwitch *)sender {
    self.displayModeLable.text = sender.isOn ? @"全屏竖屏显示" : @"全屏横屏显示";
}

- (BOOL)initParams:(BOOL)live {
    if (self.appIdTF.text.length &&self.userIdTF.text.length &&self.appSecretTF.text.length &&self.channelIdTF.text.length) {
        if (!live && !self.vodIdTF.text.length) {
            [self showHud:@"回放vid参数不能为空！" detail:nil];
            return NO;
        }
        
        /// 参数配置
        [PLVLiveSDKConfig configAccountWithUserId:self.userIdTF.text appId:self.appIdTF.text appSecret:self.appSecretTF.text];
        self.channelId = self.channelIdTF.text;
        self.vid = self.vodIdTF.text;
        
        return YES;
    } else {
        [self showHud:@"参数不能为空！" detail:nil];
        return NO;
    }
}

- (void)showHud:(NSString *)message detail:(NSString *)detail {
    PLVProgressHUD *hud = [PLVProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = PLVProgressHUDModeText;
    hud.label.text = message;
    hud.detailsLabel.text = detail;
    [hud hideAnimated:YES afterDelay:3.0];
}

#pragma mark - Override

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
