//
//  UnitDetailController.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/21.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnitDetailController : UIViewController

@property (nonatomic,copy) NSString *senceid;
//单元标题
@property (nonatomic,strong) NSMutableArray *unitsArray;
//选中单元下标
@property (nonatomic,assign) NSInteger selectIndex;

@end
