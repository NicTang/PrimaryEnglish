//
//  NDDetailModel.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/11.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "JSONModel.h"

@interface NDDetailModel : JSONModel
@property (nonatomic,copy) NSString *senceid;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *cover;
@property (nonatomic,copy) NSString *free;
@end
