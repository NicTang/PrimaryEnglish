//
//  TextView.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/11.
//  Copyright © 2016年 Nic. All rights reserved.
//
#define learningViewH 200
#define learningLabelH 40
#define unitLabelH 40
#import "TextView.h"
#import "NDDetailModel.h"
#import "UIImageView+AFNetworking.h"

@interface TextView()

@property (nonatomic,strong) UIView *learningView;

@end

@implementation TextView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.recommendLabel = [self labelWithTitle:@"推荐课程" imageString:nil textColor:[UIColor blackColor]];
//        if (self.model!=nil) {
////            label.frame.origin.y = learningViewH;
//        }
        [self addSubview:self.recommendLabel];
    }
    return self;
}
- (UILabel *)labelWithTitle:(NSString *)title imageString:(NSString *)imgString textColor:(UIColor *)textColor
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, KScreenWidth, learningLabelH)];
    label.text = title;
    label.contentMode = UIViewContentModeLeft;
    label.textColor = textColor;
    label.font = [UIFont systemFontOfSize:17];
    return label;
}

- (void)setModel:(NDDetailModel *)model
{
    _model = model;
    if (_learningView) {
        [_learningView removeFromSuperview];
        _learningView = nil;
    }
    _learningView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, learningViewH)];
    UILabel *label = [self labelWithTitle:@"正在学" imageString:nil textColor:[UIColor blackColor]];
    [_learningView addSubview:label];
    
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 40, KScreenWidth, learningViewH-learningLabelH)];
//    NSString *imgStr = [NSString stringWithFormat:PrefixForUrl,model.cover];
    [imgView setImageWithURL:[NSURL URLWithString:model.cover]];
    [_learningView addSubview:imgView];
    
    CGFloat viewY = CGRectGetMaxY(imgView.frame) - learningLabelH;
    UIView *bgVIew = [[UIView alloc]initWithFrame:CGRectMake(0, viewY, KScreenWidth, learningLabelH)];
    bgVIew.backgroundColor = [UIColor blackColor];
    bgVIew.alpha = 0.3;
    UILabel *unitLabel = [self labelWithTitle:model.title imageString:nil textColor:[UIColor whiteColor]];
    [bgVIew addSubview:unitLabel];
    [_learningView addSubview:bgVIew];
    
    [self addSubview:_learningView];
}
@end
