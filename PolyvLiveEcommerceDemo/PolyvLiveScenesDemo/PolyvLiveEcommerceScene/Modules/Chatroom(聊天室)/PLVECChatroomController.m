//
//  PLVECChatroomController.m
//  PolyvLiveEcommerceDemo
//
//  Created by ftao on 2020/5/26.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVECChatroomController.h"
#import <PolyvFoundationSDK/PLVFdUtil.h>
#import <PolyvCloudClassSDK/PLVLiveVideoAPI.h>
#import <PolyvCloudClassSDK/PLVLiveVideoConfig.h>
#import "PLVECChatCellModel.h"
#import "PLVECChatCell.h"

@interface PLVECChatroomController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) PLVChatroomPresenter *presenter;

@property (nonatomic, strong) NSArray<PLVCellModel *> *dataSource;

@end

@implementation PLVECChatroomController

#pragma mark - Setter

- (void)setChatroomView:(id<PLVECChatroomViewProtocol>)chatroomView {
    _chatroomView = chatroomView;
    if ([chatroomView respondsToSelector:@selector(tableView)]) {
        chatroomView.tableView.delegate = self;
        chatroomView.tableView.dataSource = self;
    }
    if ([chatroomView respondsToSelector:@selector(chatroomCtrl)]) {
        chatroomView.chatroomCtrl = self;
    }
}

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.presenter = [[PLVChatroomPresenter alloc] init];
        self.presenter.dataProcessor = self;
        self.dataSource = [NSArray array];
    }
    return self;
}

#pragma mark - Public

- (void)likeAction {
    [self.presenter likeAction];
}

- (void)speakMessage:(NSString *)message {
    PLVLiveWatchUser *watchUser = self.presenter.roomData.watchUser;
    PLVChatTextModel *textModel = [PLVChatTextModel textModelWithNickName:watchUser.nickName content:message];
    PLVECChatCellModel *cellModel = [PLVECChatCellModel cellModelWithChatModel:textModel];
    if (!cellModel) {
        return;
    }
    
    [self.presenter.viewModel addModel:cellModel enqueue:NO];
    [self.presenter reloadData];
    
    [self.chatroomView.tableView reloadData];
    [self.chatroomView scrollsToBottom:YES];
    
    [self.presenter emitSpeakMessage:message];
}

- (void)destroy {
    [self.presenter destroy];
}

#pragma mark - <PLVSocketObserverProtocol>

- (void)socketDidReceiveMessage:(NSString *)string jsonDict:(NSDictionary *)jsonDict {
    NSString *userIdForWatchUser = self.presenter.roomData.userIdForWatchUser;
    NSString *subEvent = PLV_SafeStringForDictKey(jsonDict, @"EVENT");
    NSDictionary *user = PLV_SafeDictionaryForDictKey(jsonDict, @"user");
    
    if ([subEvent isEqualToString:@"SPEAK"]) {  // someone speaks
        NSString *status = PLV_SafeStringForDictKey(jsonDict, @"status");
        if (status) {  // 单播消息
            if ([status isEqualToString:@"censor"]) { // 聊天审核
            } else if ([status isEqualToString:@"error"]) { // 严禁词
                NSLog(@"%@", PLV_SafeStringForDictKey(jsonDict, @"message")); // 严禁词提示
            }
        } else if ([user isKindOfClass:NSDictionary.class]) { // 用户发言
            if ([userIdForWatchUser isEqualToString:PLV_SafeStringForDictKey(user, @"userId")]) {
                // 过滤掉自己的消息（开启聊天室审核后，服务器会广播所有审核后的消息，包含自己发送的消息）
                return;
            }
            
            NSArray *values = PLV_SafeArraryForDictKey(jsonDict, @"values");
            PLVChatTextModel *textModel = [PLVChatTextModel textModelWithUser:user content:values.firstObject];
            PLVECChatCellModel *cellModel = [PLVECChatCellModel cellModelWithChatModel:textModel];
            [self.presenter.viewModel addModel:cellModel];
        }
    } else if ([subEvent isEqualToString:@"CHAT_IMG"]) { // someone send a picture message
        NSArray *values = PLV_SafeArraryForDictKey(jsonDict, @"values");
        if (!user || !values) {
            return;
        }
    
        if (![userIdForWatchUser isEqualToString:PLV_SafeStringForDictKey(user, @"userId")]) {
            NSDictionary *content = PLV_SafeDictionaryForValue(values.firstObject);
            PLVChatImageModel *imageModel = [PLVChatImageModel imageModelWithUser:user imageUrl:PLV_SafeStringForDictKey(content, @"uploadImgUrl") imageId:PLV_SafeStringForDictKey(content, @"id") size:PLV_SafeDictionaryForDictKey(content, @"size")];
            PLVECChatCellModel *cellModel = [PLVECChatCellModel cellModelWithChatModel:imageModel];
            [self.presenter.viewModel addModel:cellModel];
        }
    } else if ([subEvent isEqualToString:@"CLOSEROOM"]) { // admin closes or opens the chatroom
        NSDictionary *value = PLV_SafeDictionaryForDictKey(jsonDict, @"value");
        BOOL closed = PLV_SafeBoolForDictKey(value, @"closed");
        NSLog(@"%@",closed ? @"聊天室房间关闭" : @"聊天室房间打开");
        self.presenter.viewModel.closed = closed;
    } else if ([subEvent isEqualToString:@"REMOVE_HISTORY"]) { // admin emptied the chatroom
        [self.presenter.viewModel removeAllModels];
    } else if ([subEvent isEqualToString:@"LOGIN"]) {   // someone logged in chatroom
        NSDictionary *user = PLV_SafeDictionaryForDictKey(jsonDict, @"user");
        NSString *userId = PLV_SafeStringForDictKey(user, @"userId");;
        BOOL me = [userId isEqualToString:userIdForWatchUser];
        [self.presenter enqueueLoginUser:user me:me];
    } else if ([subEvent isEqualToString:@"LOGOUT"]) {
    }
    // admin deleted a message REMOVE_CONTENT
    // admin silenced someone ADD_SHIELD
    // admin lifts the ban on someone REMOVE_SHIELD
}

- (void)socketLocalError:(NSError *)error {
    NSLog(@"%@ %@",NSStringFromSelector(_cmd),error.localizedDescription);
}

#pragma mark - <PLVChatroomDataProcessorProtocol>

- (void)presenter:(PLVChatroomPresenter *)presenter dequeueLoginUser:(nonnull NSString *)nickNames {
    NSString *welcomeMessage = [NSString stringWithFormat:@"欢迎 %@ 进入直播间",nickNames];
    [self.chatroomView showWelcomeView:welcomeMessage duration:4.0];
}

- (void)presenter:(PLVChatroomPresenter *)presenter dataSourceUpdate:(NSArray<PLVCellModel *> *)dataSource {
    self.dataSource = [dataSource copy];

    [self.chatroomView.tableView reloadData];
    [self.chatroomView scrollsToBottom:YES];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *(^defaultCell)(void) = ^(void) {
        NSString *reuseIdentifier = @"reuseIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        }
        return cell;
    };
    
    if (indexPath.row >= self.dataSource.count) {
        return defaultCell();
    }
    
    PLVCellModel *model = self.dataSource[indexPath.row];
    if ([model isKindOfClass:PLVECChatCellModel.class]) {
        PLVECChatCell *cell = [tableView dequeueReusableCellWithIdentifier:PLVECChatCell.identifier];
        if (!cell) {
            cell = [[PLVECChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PLVECChatCell.identifier];
        }
        [cell setModel:model];
        return cell;
    } else {
        return defaultCell();
    }
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.dataSource.count) {
        return 0.0;
    }
    
    PLVCellModel *model = self.dataSource[indexPath.row];
    if (model.cellHeight <= 0) {
        if ([model isKindOfClass:PLVECChatCellModel.class]) {
            model.cellWidth = CGRectGetWidth(tableView.bounds);
            model.cellHeight = [PLVECChatCell cellHeightWithModel:model];
        }
    }
    
    return model.cellHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:PLVECChatCell.class]) {
        [(PLVECChatCell *)cell layoutCell];
    }
}

@end
