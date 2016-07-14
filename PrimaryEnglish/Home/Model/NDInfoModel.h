//
//  NDDetailModel.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/11.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "JSONModel.h"

@interface NDInfoModel : JSONModel
@property (nonatomic,copy) NSString *pkgid;
@property (nonatomic,copy) NSString *intro;
@property (nonatomic,copy) NSString *cover;
@property (nonatomic,copy) NSString *price;
@property (nonatomic,strong) NSNumber *purchase;
@property (nonatomic,copy) NSString *title;
@end
