//
//  PLVECChatCellModel.h
//  PolyvLiveEcommerceDemo
//
//  Created by ftao on 2020/5/27.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVChatCellModel.h"
#import "PLVChatTextModel.h"
#import "PLVChatImageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PLVECChatCellModel : PLVChatCellModel

@property (nonatomic, copy, readonly) NSAttributedString *attrCont;

@end

NS_ASSUME_NONNULL_END
