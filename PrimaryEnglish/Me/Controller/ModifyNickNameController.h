//
//  ModifyNickNameController.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/15.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModifyNickNameController : UIViewController

@property (nonatomic,copy) void (^nameblock)(NSString *nickName);

@property (nonatomic,copy) NSString *nickName;

@end
