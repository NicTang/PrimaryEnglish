//
//  TextView.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/11.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "TextView.h"

@implementation TextView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, KScreenWidth, 40)];
        label.text = @"推荐课程";
        label.contentMode = UIViewContentModeLeft;
        label.font = [UIFont systemFontOfSize:15];
        [self addSubview:label];
    }
    return self;
}

@end
