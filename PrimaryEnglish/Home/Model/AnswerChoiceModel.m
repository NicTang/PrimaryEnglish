//
//  AnswerChoiceModel.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/8/11.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "AnswerChoiceModel.h"

@implementation AnswerChoiceModel

- (NSString *)description
{
    return [NSString stringWithFormat:@"userIndex@ %ld--trueIndex@ %ld--isRight @%d",self.userIndex,self.trueIndex,self.isRight];
}

@end
