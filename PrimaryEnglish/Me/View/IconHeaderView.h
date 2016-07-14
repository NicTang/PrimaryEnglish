//
//  IconHeaderView.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 20/7/12.
//  Copyright © 2020年 Nic. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserModel;

@interface IconHeaderView : UIView
@property (nonatomic,strong) UserModel *model;

+ (instancetype)iconHeaderView;

@end
