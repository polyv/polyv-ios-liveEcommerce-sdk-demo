//
//  PLVECCommodityController.m
//  PolyvLiveScenesDemo
//
//  Created by ftao on 2020/6/29.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVECCommodityController.h"
#import <PolyvFoundationSDK/PLVFdUtil.h>
#import <PolyvFoundationSDK/PLVDataUtil.h>
#import "PLVECCommodityViewModel.h"
#import "PLVECCommodityCell.h"

@interface PLVECCommodityController () <UITableViewDelegate, UITableViewDataSource, PLVECCommodityCellDelegate>

@property (nonatomic, strong) PLVECCommodityViewModel *viewModel;

@end

@implementation PLVECCommodityController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [[PLVECCommodityViewModel alloc] init];
    }
    return self;
}

#pragma mark - Setter

- (void)setView:(id<PLVECCommodityViewProtocol>)view {
    _view = view;
    if ([view respondsToSelector:@selector(tableView)]) {
        view.tableView.delegate = self;
        view.tableView.dataSource = self;
    }
    if ([view respondsToSelector:@selector(delegate)]) {
        view.delegate = self;
    }
}

#pragma mark - <PLVECCommodityControllerProtocol>

- (void)loadCommodityInfo {
    [self clearCommodityInfo];
    [self.view.indicatorView startAnimating];
    
    __weak typeof(self)weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithRequest:[self urlRequestForCommodity] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view.indicatorView stopAnimating];
        });
        
        if (error) {
            [weakSelf loadFailur:error message:nil];
        } else {
            NSError *parseErr = nil;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseErr];
            if (parseErr) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                NSLog(@"httpResponse statusCode %ld",(long)httpResponse.statusCode);
                [weakSelf loadFailur:parseErr message:nil];
            } else if ([jsonDict isKindOfClass:NSDictionary.class]) {
                if ([PLV_SafeStringForDictKey(jsonDict, @"status") isEqualToString:@"success"]) {
                    NSDictionary *data = PLV_SafeDictionaryForDictKey(jsonDict, @"data");
                    NSArray *contents = PLV_SafeArraryForDictKey(data, @"contents");;
                    if (contents.count) {
                        NSMutableArray *mArr = [NSMutableArray array];
                        for (NSDictionary *dict in contents) {
                            PLVECCommodityModel *model = [PLVECCommodityModel modelWithDict:dict];
                            if (model) {
                                [mArr addObject:model];
                            }
                        }
                        weakSelf.viewModel.models = [mArr copy];
                    }
                    weakSelf.viewModel.totalItems = PLV_SafeIntegerForDictKey(data, @"totalItems");
                    [weakSelf reloadViewData];
                } else {
                    [weakSelf loadFailur:nil message:PLV_SafeStringForDictKey(jsonDict, @"message")];
                }
            } else {
                [weakSelf loadFailur:nil message:@"parseErr: not dict"];
            }
        }
    }] resume];
}

- (void)clearCommodityInfo {
    self.viewModel.models = nil;
    self.viewModel.totalItems = -1;
    [self reloadViewData];
}

#pragma mark - Priveta

- (void)reloadViewData {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.viewModel.totalItems == 0) {
            [self.view setupUIOfNoGoods:YES];
        } else {
            [self.view setupUIOfNoGoods:NO];
        }
        self.view.titleLabel.attributedText = self.viewModel.titleAttrStr;
        [self.view.tableView reloadData];
    });
}

- (void)loadFailur:(NSError *)error message:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            NSLog(@"loadCommodityInfo error description: %@",error.localizedDescription);
        } else {
            NSLog(@"loadCommodityInfo error message: %@",message);
        }
    });
}

#pragma mark netwrork

- (NSURLRequest *)urlRequestForCommodity {
    NSUInteger page = 1;
    NSUInteger limit = 200;
    
    NSString *appId = self.channel.account.appId;
    NSString *appSecret = self.channel.account.appSecret;
    
    NSTimeInterval timeStamp = [NSDate.date timeIntervalSince1970] * 1000;
    NSString *timeStampStr = [NSString stringWithFormat:@"%lld", (long long)timeStamp];
    NSString *signRow = [NSString stringWithFormat:@"%@appId%@channelId%@limit%ldpage%ldtimestamp%@%@",appSecret,appId,self.channel.channelId,(long)limit,(long)page,timeStampStr,appSecret];
    NSString *sign = [[PLVDataUtil md5HexDigest:signRow] uppercaseString];
    
    NSMutableString *urlStr = [NSMutableString stringWithString:@"https://api.polyv.net/live/v3/channel/product/getList"];
    [urlStr appendFormat:@"?channelId=%@",self.channel.channelId];
    [urlStr appendFormat:@"&page=%ld",(long)page];
    [urlStr appendFormat:@"&limit=%ld",(long)limit];
    [urlStr appendFormat:@"&sign=%@",sign];
    [urlStr appendFormat:@"&appId=%@",appId];
    [urlStr appendFormat:@"&timestamp=%@",timeStampStr];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0];
    
    return request;
}

#pragma mark - <PLVECCommodityCellDelegate>

- (void)commodityCell:(PLVECCommodityCell *)commodityCell didSelectButtonBeClicked:(PLVECCommodityModel *)model {
    NSURL *url = [NSURL URLWithString:model.link];
    if (!url.scheme) {
        url = [NSURL URLWithString:[@"http://" stringByAppendingString:model.link]];
    }
    NSLog(@"商品跳转：%@",url);
    
    if (![UIApplication.sharedApplication openURL:url]) {
        NSLog(@"url: %@",url);
    }
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.models.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = @"reuseIdentifier";
    PLVECCommodityCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[PLVECCommodityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    cell.model = self.viewModel.models[indexPath.section];
    cell.delegate = self;
    
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

@end
