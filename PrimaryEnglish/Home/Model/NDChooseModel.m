//
//  NDChooseModel.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/8/2.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "NDChooseModel.h"

@implementation NDChooseModel

- (NSString *)description
{
    NSString *str = [NSString stringWithFormat:@"type:%@-mp3Url:%@-tipLabelText:%@-imageArray:%@-textArray:%@-isPic:%d",self.type,self.mp3Url,self.tipLabelText,self.imageArray,self.textArray,self.isPic];
    return str;
}

@end
