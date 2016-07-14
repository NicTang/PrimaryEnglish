//
//  NDCourseModel.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/12.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "JSONModel.h"

@interface NDCourseModel : JSONModel

@property (nonatomic,copy) NSString *pkgid;
@property (nonatomic,copy) NSString *cover;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *price;
@property (nonatomic,copy) NSString *purchaseid;

@end
