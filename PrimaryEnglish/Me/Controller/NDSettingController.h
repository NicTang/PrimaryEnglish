//
//  NDSettingController.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/14.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NDSettingController;

@protocol SettingControllerDelegate <NSObject>

- (void)settingController:(NDSettingController *)vc logout:(int)status;
@end

@interface NDSettingController : UIViewController

@property (nonatomic,weak) id<SettingControllerDelegate> delegate;

@end
