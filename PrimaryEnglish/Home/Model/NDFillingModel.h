//
//  NDFillingModel.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/29.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "JSONModel.h"

@interface NDFillingModel : JSONModel

@property (nonatomic,strong) NSDictionary *audio;
@property (nonatomic,copy) NSString *content;
@property (nonatomic,copy) NSString *expl;
@property (nonatomic,strong) NSArray *keys;
@property (nonatomic,copy) NSString *ques;
@property (nonatomic,copy) NSString *type;

@end
