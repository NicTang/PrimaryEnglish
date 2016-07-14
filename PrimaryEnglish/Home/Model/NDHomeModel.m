//
//  NDHome.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/11.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "NDHomeModel.h"

@implementation NDHomeModel

+ (instancetype)homeWithArray:(NSArray *)array
{
    return [[self alloc]initWithArray:array];
}

- (instancetype)initWithArray:(NSArray *)array
{
    if (self = [super init]) {
        
        for (int i = 0; i<array.count; i++) {
            if (i==0) {
                self.homeID = array[i];
            } else if(i==1){
                self.img = array[i];
            }else
            {
                self.name = array[i];
            }
        }
    }
    return self;
}

@end
