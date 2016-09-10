//
//  UnitTabBar.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/22.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "UnitTabBar.h"

@interface UnitTabBar ()
- (IBAction)menuBtnClick:(UIButton *)sender;
- (IBAction)shareBtnClick:(UIButton *)sender;

@end

@implementation UnitTabBar

+ (instancetype)unitTabbar
{
    return [[[NSBundle mainBundle]loadNibNamed:@"UnitTabBar" owner:nil options:nil]lastObject];
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    _currentPage = currentPage;
    [self.currentPageLabel setFont:[UIFont systemFontOfSize:20*ScaleValueX]];
    self.currentPageLabel.text = [NSString stringWithFormat:@"%ld / %ld",currentPage,self.totalPage];
}

- (IBAction)menuBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(tabBarItemClickToShowMenu:)]) {
        [self.delegate tabBarItemClickToShowMenu:self];
    }
}

- (IBAction)shareBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(tabBarItemClickToShareInfo:)]) {
        [self.delegate tabBarItemClickToShareInfo:self];
    }
}
@end
