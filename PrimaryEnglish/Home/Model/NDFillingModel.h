//
//  NDFillingModel.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/29.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "JSONModel.h"

@interface NDFillingModel : NSObject

@property (nonatomic,copy) NSString *mp3Url;
@property (nonatomic,copy) NSString *content;
@property (nonatomic,strong) NSArray *keys;
@property (nonatomic,copy) NSString *tipLabelText;
@property (nonatomic,copy) NSString *type;

@end
