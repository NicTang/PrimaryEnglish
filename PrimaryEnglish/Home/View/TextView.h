//
//  TextView.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/11.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NDDetailModel;

@interface TextView : UICollectionReusableView

@property (nonatomic,strong) NDDetailModel *model;
@property (nonatomic,strong) UILabel *recommendLabel;
@end
