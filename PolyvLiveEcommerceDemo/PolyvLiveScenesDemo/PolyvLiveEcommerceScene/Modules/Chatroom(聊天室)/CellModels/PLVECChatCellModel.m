//
//  PLVECChatCellModel.m
//  PolyvLiveEcommerceDemo
//
//  Created by ftao on 2020/5/27.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVECChatCellModel.h"
#import "PLVECUtils.h"
#import "PLVEmoticonManager.h"

@interface PLVECChatCellModel ()

@property (nonatomic, copy) NSAttributedString *attrCont;

@end

@implementation PLVECChatCellModel

- (void)reloadModelWithChatModel:(PLVChatModel *)chatModel {
    [super reloadModelWithChatModel:chatModel];
    [self createRichTextMessage];
}

#pragma mark - Private

- (void)createRichTextMessage {
    if (!self.chatModel) {
        return;
    }
    
    PLVLiveChatUser *user = self.chatModel.user;
    
    NSString *nickStr = [NSString stringWithFormat:@"%@：",user.nickName];
    UIColor *nickColor = [UIColor colorWithRed:1 green:209/255.0 blue:107/255.0 alpha:1];

    UIColor *textColor = UIColor.whiteColor;
    UIFont *textFont = [UIFont systemFontOfSize:12.0];

    CGFloat actorSize = 10.0;
    UIColor *guestActorBgColor = [UIColor colorWithRed:235/255.0 green:97/255.0 blue:101/255.0 alpha:1];
    UIColor *teacherActorBgColor = [UIColor colorWithRed:240/255.0 green:147/255.0 blue:67/255.0 alpha:1];
    UIColor *assistantActorBgColor = [UIColor colorWithRed:89/255.0 green:143/255.0 blue:229/255.0 alpha:1];
    UIColor *managerActorBgColor = [UIColor colorWithRed:51/255.0 green:187/255.0 blue:197/255.0 alpha:1];

    NSMutableAttributedString *mAttributedStr = [[NSMutableAttributedString alloc] initWithString:nickStr attributes:@{NSFontAttributeName:textFont, NSForegroundColorAttributeName:nickColor}];
    if ([self.chatModel isKindOfClass:PLVChatTextModel.class]) {
        NSString *content = [(PLVChatTextModel *)self.chatModel content];
        NSMutableAttributedString *emotionAttrStr = [PLVEmoticonManager.sharedManager converEmoticonTextToEmotionFormatText:content attributes:@{NSFontAttributeName:textFont,NSForegroundColorAttributeName:textColor}];
        [mAttributedStr appendAttributedString:emotionAttrStr];
    } else if ([self.chatModel isKindOfClass:PLVChatImageModel.class]) {
        UIImage *placeholderImage = [PLVECUtils imageForWatchResource:@"plv_chatroom_thumbnail_imag"];
        NSTextAttachment *placeholderAttach = [[NSTextAttachment alloc] init];
        placeholderAttach.bounds = CGRectMake(0, -1.5, 36.0, 36.0);
        placeholderAttach.image = placeholderImage;
        [mAttributedStr appendAttributedString:[NSAttributedString attributedStringWithAttachment:placeholderAttach]];
    }

    if (user.specialIdentity && user.actor) {
        CGRect boundingRect = [user.actor boundingRectWithSize:CGSizeMake(MAXFLOAT, 12.0) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:actorSize]} context:nil];
        CGSize labelSize = CGSizeMake(CGRectGetWidth(boundingRect) + 12.0, 12.0);
        CGFloat scale = [UIScreen mainScreen].scale;

        /// actorLB 3 rate
        UILabel *actorLB = [[UILabel alloc] init];
        actorLB.font = [UIFont systemFontOfSize:actorSize*scale];
        actorLB.text = user.actor;
        actorLB.textColor = UIColor.whiteColor;
        actorLB.textAlignment = NSTextAlignmentCenter;
        actorLB.frame = CGRectMake(0, 0, labelSize.width*scale, labelSize.height*scale);
        actorLB.layer.cornerRadius = 6.0*scale;
        actorLB.layer.masksToBounds = YES;
        switch (user.userType) {
            case PLVLiveUserTypeGuest:
                actorLB.backgroundColor = guestActorBgColor; break;
            case PLVLiveUserTypeTeacher:
                actorLB.backgroundColor = teacherActorBgColor; break;
            case PLVLiveUserTypeAssistant:
                actorLB.backgroundColor = assistantActorBgColor; break;
            case PLVLiveUserTypeManager:
                actorLB.backgroundColor = managerActorBgColor; break;
            default: break;
        }

        UIImage *actorLableImage = [self imageFromUIView:actorLB];
        NSTextAttachment *labelAttach = [[NSTextAttachment alloc] init];
        labelAttach.bounds = CGRectMake(0, -1.5, labelSize.width, labelSize.height);
        labelAttach.image = actorLableImage;
        [mAttributedStr insertAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName:textFont}] atIndex:0];
        [mAttributedStr insertAttributedString:[NSAttributedString attributedStringWithAttachment:labelAttach] atIndex:0];
    }

    self.attrCont = mAttributedStr;
}

- (UIImage *)imageFromUIView:(UIView *)view {
    UIGraphicsBeginImageContext(view.bounds.size);
    CGContextRef ctxRef = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctxRef];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
