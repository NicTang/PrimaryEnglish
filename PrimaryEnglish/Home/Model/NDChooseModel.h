//
//  NDChooseModel.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/8/2.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NDChooseModel : NSObject

@property (nonatomic,copy) NSString *type;
@property (nonatomic,copy) NSString *mp3Url;
@property (nonatomic,copy) NSString *tipLabelText;
//@property (nonatomic,strong) NSArray *choices;
@property (nonatomic,assign) NSInteger trueAnswerIndex;

@property (nonatomic,assign) BOOL isPic;
@property (nonatomic,strong) NSMutableArray *imageArray;
@property (nonatomic,strong) NSArray *textArray;
@end
