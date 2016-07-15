//
//  NDMeInfoController.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/14.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserModel;

@interface NDMeInfoController : UIViewController

@property (nonatomic,strong) UserModel *user;

@property (nonatomic,copy) void (^showUserBlock)(UserModel *model);

@end
