//
//  UnitDetailController.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/21.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NDDetailModel,UnitTabBar;

@interface BookReaderController : UIViewController
/**
 *  该单元的请求参数
 */
@property (nonatomic,copy) NSString *senceid;
//单元标题
@property (nonatomic,strong) NSMutableArray *unitsArray;
//选中单元下标
@property (nonatomic,assign) NSInteger selectIndex;
@property (nonatomic,copy) NSString *courseID;
@property (nonatomic,copy) NSString *courseName;

@property (nonatomic,copy) void (^learningReaderBlock)(NDDetailModel *model,NSString *title,NSInteger selectIndex,NSArray *unitsArray,NSString *courseID);

@end
