//
//  PLVECCommodityModel.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/29.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVECCommodityModel.h"
#import <PolyvFoundationSDK/PLVFdUtil.h>

@interface PLVECCommodityModel ()

@property (nonatomic, assign) NSInteger productId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) float price;
@property (nonatomic, assign) float realPrice;
@property (nonatomic, copy) NSString *cover;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, assign) NSInteger status;

@end

@implementation PLVECCommodityModel

+ (instancetype)modelWithDict:(NSDictionary *)dict {
    if (![dict isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    PLVECCommodityModel *model = [[PLVECCommodityModel alloc] init];
    if (model) {
        model.productId = PLV_SafeIntegerForDictKey(dict, @"productId");
        model.name = PLV_SafeStringForDictKey(dict, @"name");
        model.price = PLV_SafeFloatForDictKey(dict, @"price");
        model.realPrice = PLV_SafeFloatForDictKey(dict, @"realPrice");
        model.cover = PLV_SafeStringForDictKey(dict, @"cover");
        model.link = PLV_SafeStringForDictKey(dict, @"link");
        model.status = PLV_SafeIntegerForDictKey(dict, @"status");
    }
    return model;
}

@end
