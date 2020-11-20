//
//  PLVChatroomView.m
//  PolyvLiveEcommerceDemo
//
//  Created by ftao on 2020/5/21.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVECChatroomView.h"
#import "PLVECWelcomView.h"
#import "PLVECUtils.h"
#import <MJRefresh/MJRefresh.h>

#define TEXT_MAX_COUNT 200

#define KEYPATH_CONTENTSIZE @"contentSize"

@interface PLVECChatroomView () <UITextViewDelegate>

/// 聊天室列表顶部加载更多控件
@property (nonatomic, strong) MJRefreshNormalHeader *refresher;
@property (nonatomic, strong) PLVECWelcomView *welcomView;
@property (nonatomic, assign) CGRect originWelcomViewFrame;

@property (nonatomic, strong) UIView *tableViewBackgroundView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, assign) BOOL observingTableView;

@property (nonatomic, strong) UIView *textAreaView;

@property (nonatomic, strong) UIView *tapView;
@property (nonatomic, strong) UITextView *textView;

@end

@implementation PLVECChatroomView
@synthesize presenter;
@synthesize tableView;

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserveTableView];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        
        self.welcomView = [[PLVECWelcomView alloc] init];
        self.welcomView.hidden = YES;
        [self addSubview:self.welcomView];
        
        // 渐变蒙层
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.startPoint = CGPointMake(0, 0);
        self.gradientLayer.endPoint = CGPointMake(0, 0.1);
        self.gradientLayer.colors = @[(__bridge id)[UIColor.clearColor colorWithAlphaComponent:0].CGColor, (__bridge id)[UIColor.clearColor colorWithAlphaComponent:1.0].CGColor];
        self.gradientLayer.locations = @[@(0), @(1.0)];
        self.gradientLayer.rasterizationScale = UIScreen.mainScreen.scale;
        
        self.tableViewBackgroundView = [[UIView alloc] init];
        self.tableViewBackgroundView.backgroundColor = UIColor.clearColor;
        [self addSubview:self.tableViewBackgroundView];
        self.tableViewBackgroundView.layer.mask = self.gradientLayer;
        
        self.tableView = [[UITableView alloc] init];
        self.tableView.backgroundColor = UIColor.clearColor;
        self.tableView.scrollEnabled = NO;
        self.tableView.allowsSelection =  NO;
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.showsHorizontalScrollIndicator = NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.estimatedRowHeight = 0.0;
        self.tableView.estimatedSectionHeaderHeight = 0.0;
        self.tableView.estimatedSectionFooterHeight = 0.0;
        self.tableView.mj_header = self.refresher;
        [self.tableViewBackgroundView addSubview:self.tableView];
        
        self.textAreaView = [[UIView alloc] init];
        self.textAreaView.layer.cornerRadius = 20.0;
        self.textAreaView.layer.masksToBounds = YES;
        self.textAreaView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        [self addSubview:self.textAreaView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textAreaViewTapAction)];
        [self.textAreaView addGestureRecognizer:tapGesture];
        
        UIImageView *leftImgView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 16, 16)];
        leftImgView.image = [PLVECUtils imageForWatchResource:@"plv_chat_img"];
        [self.textAreaView addSubview:leftImgView];
        
        UILabel *placeholderLB = [[UILabel alloc] initWithFrame:CGRectMake(30, 9, 130, 14)];
        placeholderLB.text = @"跟大家聊点什么吧～";
        placeholderLB.font = [UIFont systemFontOfSize:14];
        placeholderLB.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
        [self.textAreaView addSubview:placeholderLB];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        self.observingTableView = NO;
        [self observeTableView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat tableViewHeight = 156;
    self.textAreaView.frame = CGRectMake(15, CGRectGetHeight(self.bounds)-15-32, 165, 32);
    self.tableViewBackgroundView.frame = CGRectMake(15, CGRectGetMinY(self.textAreaView.frame)-tableViewHeight-15, 234, tableViewHeight);
    self.gradientLayer.frame = self.tableViewBackgroundView.bounds;
    self.welcomView.frame = CGRectMake(-258, CGRectGetMinY(self.tableViewBackgroundView.frame)-22-15, 258, 22);
    self.originWelcomViewFrame = self.welcomView.frame;
}

#pragma mark - Getter

- (UIView *)tapView {
    if (!_tapView) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        
        _tapView = [[UIView alloc] initWithFrame:window.bounds];
        _tapView.backgroundColor = [UIColor clearColor];
        [window addSubview:_tapView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapViewAction)];
        [_tapView addGestureRecognizer:tapGesture];
    }
    return _tapView;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.frame = CGRectMake(0, CGRectGetHeight(self.tapView.bounds)-46, CGRectGetWidth(self.tapView.bounds), 46);
        _textView.delegate = self;
        _textView.textColor = [UIColor colorWithWhite:51/255.0 alpha:1];
        _textView.textContainerInset = UIEdgeInsetsMake(10, 8, 10, 8);
        _textView.font = [UIFont systemFontOfSize:14.0];
        _textView.backgroundColor = UIColor.whiteColor;
        _textView.showsVerticalScrollIndicator = NO;
        _textView.showsHorizontalScrollIndicator = NO;
        _textView.returnKeyType = UIReturnKeySend;
        [self.tapView addSubview:_textView];
    }
    return _textView;
}

- (MJRefreshNormalHeader *)refresher {
    if (!_refresher) {
        _refresher = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshAction:)];
        _refresher.lastUpdatedTimeLabel.hidden = YES;
        _refresher.stateLabel.hidden = YES;
        [_refresher setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _refresher;
}

#pragma mark - Action

- (void)textAreaViewTapAction {
    if (!self.textView.isFirstResponder) {
        self.textView.hidden = NO;
        [self.textView becomeFirstResponder];
    }
}

- (void)tapViewAction {
    [self.tapView setHidden:YES];
    [self.textView setHidden:YES];
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }
}

- (void)refreshAction:(MJRefreshNormalHeader *)refreshHeader {
    [self.presenter loadHistoryDataWithCount:10];
}

#pragma mark - KVO

- (void)observeTableView {
    if (!self.observingTableView) {
        self.observingTableView = YES;
        [self.tableView addObserver:self forKeyPath:KEYPATH_CONTENTSIZE options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)removeObserveTableView {
    if (self.observingTableView) {
        self.observingTableView = NO;
        [self.tableView removeObserver:self forKeyPath:KEYPATH_CONTENTSIZE];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([object isKindOfClass:UITableView.class] && [keyPath isEqualToString:KEYPATH_CONTENTSIZE]) {
        CGFloat contentHeight = self.tableView.contentSize.height;
        if (contentHeight < CGRectGetHeight(self.tableViewBackgroundView.bounds)) {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect newFrame = CGRectMake(0, CGRectGetHeight (self.tableViewBackgroundView.bounds)-contentHeight, CGRectGetWidth(self.tableViewBackgroundView.bounds), contentHeight);
                self.tableView.frame = newFrame;
            }];
        } else if (CGRectGetHeight(self.tableViewBackgroundView.bounds) > 0) {
            self.tableView.scrollEnabled = YES;
            self.tableView.frame = self.tableViewBackgroundView.bounds;
            [self removeObserveTableView];
        }
    }
}

#pragma mark - Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    if (!self.textView.isFirstResponder) {
        return;
    }
    
    [self followKeyboardAnimated:notification.userInfo show:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (!self.textView.isFirstResponder) {
        return;
    }
    
    [self followKeyboardAnimated:notification.userInfo show:NO];
}

#pragma mark - <PLVECChatroomViewProtocol>

- (void)scrollsToBottom:(BOOL)animated {
    CGFloat offsetY = self.tableView.contentSize.height - self.tableView.bounds.size.height;
    if (offsetY < 0.0) {
        offsetY = 0.0;
    }
    [self.tableView setContentOffset:CGPointMake(0.0, offsetY) animated:animated];
}

- (void)showWelcomeView:(NSString *)message duration:(NSTimeInterval)duration {
    if (self.welcomView.hidden) {
        self.welcomView.hidden = NO;
        self.welcomView.messageLB.text = message;
        [UIView animateWithDuration:1.0 animations:^{
            CGRect newFrame = self.welcomView.frame;
            newFrame.origin.x = 0;
            self.welcomView.frame = newFrame;
        }];
         
        SEL shutdownWelcomView = @selector(shutdownWelcomView);
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:shutdownWelcomView object:nil];
        [self performSelector:shutdownWelcomView withObject:nil afterDelay:duration];
    } else {
        [self shutdownWelcomView];
        [self showWelcomeView:message duration:duration];
    }
}

- (void)loadHistoryDataSuccessAtFirstTime:(BOOL)first hasNoMoreMessage:(BOOL)noMore {
    [self.refresher endRefreshing];
    [self.tableView reloadData];
    if (first) {
        [self scrollsToBottom:NO];
    }
    if (noMore) {
        [self.refresher removeFromSuperview];
    }
}

- (void)loadHistoryDataFailure {
    [self.refresher endRefreshing];
}

#pragma mark - Private

- (void)shutdownWelcomView {
    self.welcomView.hidden = YES;
    self.welcomView.frame = self.originWelcomViewFrame;
}

- (void)sendMessage {
    if (self.textView.text.length > 0) {
        [self tapViewAction];
        [self.presenter speakMessage:self.textView.text];
        self.textView.text = @"";
    }
}

- (void)followKeyboardAnimated:(NSDictionary *)userInfo show:(BOOL)show {
    [self.tapView setHidden:!show];

    CGRect keyBoardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    duration = MAX(0.3, duration);
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect newFrame = self.textView.frame;
        newFrame.origin.y = CGRectGetMinY(keyBoardFrame) - CGRectGetHeight(newFrame);
        self.textView.frame = newFrame;
    } completion:^(BOOL finished) {
        if (!show) {
            self.textView.hidden = YES;
        }
    }];
}

#pragma mark - <UITextViewDelegate>

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // Prevent crashing undo bug
    if(range.location + range.length > textView.text.length) {
        return NO;
    }
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self sendMessage];
        return NO;
    }
    
    // 当前文本框字符长度（中英文、表情键盘上表情为一个字符，系统emoji为两个字符）
    NSUInteger newLength = textView.attributedText.length + text.length - range.length;
    if (newLength > TEXT_MAX_COUNT) {
        NSLog(@"输入字数超限！");
        return NO;
    }
    
    return YES;
}

@end
