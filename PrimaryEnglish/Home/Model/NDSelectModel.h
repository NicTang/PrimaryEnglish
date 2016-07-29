//
//  NDSelectModel.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/28.
//  Copyright © 2016年 Nic. All rights reserved.
//  词汇练习选择题模型

#import "JSONModel.h"

@interface NDSelectModel : JSONModel

@property (nonatomic,copy) NSString *type;
@property (nonatomic,strong) NSDictionary *audio;
@property (nonatomic,assign) BOOL ispic;

@property (nonatomic,strong) NSArray *choices;
@property (nonatomic,copy) NSString *ques;
@property (nonatomic,strong) NSArray *keys;
@property (nonatomic,copy) NSString *expl;
@end
