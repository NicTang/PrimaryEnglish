//
//  NDMatchModel.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/29.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "JSONModel.h"

@interface NDMatchModel : NSObject

@property (nonatomic,copy) NSString *type;
@property (nonatomic,copy) NSString *mp3Url;
@property (nonatomic,copy) NSString *tipLabelText;
@property (nonatomic,strong) NSArray *baseImgArr;
@property (nonatomic,strong) NSArray *matchImgArr;

@end
