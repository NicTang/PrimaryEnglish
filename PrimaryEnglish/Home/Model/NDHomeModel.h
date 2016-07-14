//
//  NDHome.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/11.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NDHomeModel : NSObject

@property (nonatomic,copy) NSString *homeID;
@property (nonatomic,copy) NSString *img;
@property (nonatomic,copy) NSString *name;

+ (instancetype)homeWithArray:(NSArray *)array;
- (instancetype)initWithArray:(NSArray *)array;
@end
