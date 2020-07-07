//
//  PLVECChatCellModel.h
//  PolyvLiveEcommerceDemo
//
//  Created by ftao on 2020/5/27.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVCellModel.h"
#import "PLVChatTextModel.h"
#import "PLVChatImageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PLVECChatCellModel : PLVCellModel

@property (nonatomic, strong, readonly) PLVChatModel *chatModel;

@property (nonatomic, copy, readonly) NSAttributedString *attrCont;

+ (instancetype)cellModelWithChatModel:(PLVChatModel *)chatModel;

@end

NS_ASSUME_NONNULL_END
