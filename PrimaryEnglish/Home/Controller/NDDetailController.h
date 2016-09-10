//
//  NDDetailController.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/11.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NDDetailModel;

@interface NDDetailController : UIViewController

@property (nonatomic,copy) NSString *courseID;

@property (nonatomic,copy) void (^learningDetailBlock)(NDDetailModel *model,NSString *title,NSInteger selectIndex,NSArray *unitsArray,NSString *courseID);

@end
