//
//  UnitTabBar.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/22.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UnitTabBar;

@protocol UnitTabBarDelegate <NSObject>
@optional
- (void)tabBarItemClickToShowMenu:(UnitTabBar *)tabBar;
- (void)tabBarItemClickToShareInfo:(UnitTabBar *)tabBar;
@end

@interface UnitTabBar : UIView

@property (weak, nonatomic) IBOutlet UILabel *currentPageLabel;
@property (weak, nonatomic) IBOutlet UIButton *menuBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;

@property (nonatomic,assign) NSInteger currentPage;
@property (nonatomic,assign) NSInteger totalPage;

+ (instancetype)unitTabbar;

@property (nonatomic,weak) id<UnitTabBarDelegate> delegate;

@end
