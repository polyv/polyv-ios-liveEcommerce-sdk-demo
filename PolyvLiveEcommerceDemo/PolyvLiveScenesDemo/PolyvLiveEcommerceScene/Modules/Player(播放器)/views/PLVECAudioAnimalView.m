//
//  PLVECAudioAnimalView.m
//  PolyvLiveEcommerceDemo
//
//  Created by ftao on 2020/6/2.
//  Copyright © 2020 polyv. All rights reserved.
//

#import "PLVECAudioAnimalView.h"
#import "PLVECUtils.h"

@interface PLVECAudioAnimalView ()

@property (nonatomic, strong) UIImageView *animalImgView;

@end

@implementation PLVECAudioAnimalView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.backgroundColor = UIColor.blackColor;
        
        UIImage *image1 = [PLVECUtils imageForWatchResource:@"plv_audio_animal_img1"];
        UIImage *image2 = [PLVECUtils imageForWatchResource:@"plv_audio_animal_img2"];
        UIImage *image3 = [PLVECUtils imageForWatchResource:@"plv_audio_animal_img3"];
        
        self.animalImgView = [[UIImageView alloc] init];
        if (image1 && image2 && image3) {
            self.animalImgView.animationDuration = 1.0;
            self.animalImgView.animationImages = @[image1,image2,image3];
            [self.animalImgView startAnimating];
        }
        [self addSubview:self.animalImgView];
        
        self.contentLable = [[UILabel alloc] init];
        self.contentLable.textColor = UIColor.whiteColor;
        self.contentLable.font = [UIFont systemFontOfSize:14];
        self.contentLable.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.contentLable];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.animalImgView.frame = CGRectMake(0, 0, 48, 120);
    self.animalImgView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.contentLable.frame = CGRectMake(0, CGRectGetMaxY(self.animalImgView.frame)+15, CGRectGetWidth(self.bounds), 14);
}

@end
