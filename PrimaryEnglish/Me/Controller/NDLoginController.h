//
//  NDLoginController.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/18.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserModel;

@interface NDLoginController : UIViewController

@property (nonatomic,copy) void(^userLoginBlock)(UserModel *loginModel);

@property (nonatomic,strong) UserModel *userLoginModel;

@end
