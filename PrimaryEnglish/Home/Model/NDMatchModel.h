//
//  NDMatchModel.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/29.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "JSONModel.h"

@interface NDMatchModel : JSONModel

@property (nonatomic,copy) NSString *type;
@property (nonatomic,strong) NSDictionary *audio;
@property (nonatomic,copy) NSString *ques;
@property (nonatomic,strong) NSArray *baseImgArr;
@property (nonatomic,strong) NSArray *matchImgArr;
@property (nonatomic,copy) NSString *expl;

@end
