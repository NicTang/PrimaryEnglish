//
//  NDSelectModel.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/28.
//  Copyright © 2016年 Nic. All rights reserved.
//  词汇练习选择题模型

#import "JSONModel.h"

@interface NDSelectModel : JSONModel
//共有
@property (nonatomic,copy) NSString<Optional> *type;
@property (nonatomic,strong) NSDictionary<Optional> *audio;
@property (nonatomic,copy) NSString<Optional> *ques;
@property (nonatomic,copy) NSString<Optional> *expl;
//卡片独有
@property (nonatomic,strong) NSNumber<Optional>* ispic;
@property (nonatomic,strong) NSArray<Optional> *choices;

//填空、卡片
@property (nonatomic,copy) NSString<Optional> *content;
@property (nonatomic,strong) NSArray<Optional> *keys;
//图片匹配
@property (nonatomic,strong) NSArray<Optional> *baseImgArr;
@property (nonatomic,strong) NSArray<Optional> *matchImgArr;

//自定义属性
@property (nonatomic,strong) NSArray<Optional> *chooseArray;
@property (nonatomic,strong) NSArray<Optional> *matchingArray;
@property (nonatomic,strong) NSArray<Optional> *fillingArray;

- (id)parseDataByType:(NSString *)type;

@end
