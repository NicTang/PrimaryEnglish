//
//  NDMatchModel.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/29.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "NDMatchModel.h"

@implementation NDMatchModel

- (NSString *)description
{
    NSString *str = [NSString stringWithFormat:@"type:%@-mp3Url:%@-tipLabelText:%@-baseImgArr:%@-matchImgArr:%@",self.type,self.mp3Url,self.tipLabelText,self.baseImgArr,self.matchImgArr];
    return str;
}

@end
