//
//  NDDetailController.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/11.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NDDetailController : UIViewController

@property (nonatomic,copy) NSString *courseID;
/**
 *  当前书的类别标记（点读，词汇，配套）
 */
@property (nonatomic,assign) NSInteger flag;

@end
