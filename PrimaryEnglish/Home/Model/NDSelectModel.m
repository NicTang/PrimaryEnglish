//
//  NDSelectModel.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/28.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "NDSelectModel.h"
#import "NDChooseModel.h"
#import "NDMatchModel.h"
#import "NDFillingModel.h"

@interface NDSelectModel()

@end

@implementation NDSelectModel

- (id)parseDataByType:(NSString *)type
{
//    self.selectArray = [[NSMutableArray alloc]init];
    if ([type isEqualToString:@"simple_choose"]) {
        
        NDChooseModel *choose = [[NDChooseModel alloc]init];
        choose.type = type;
        if(self.audio.count!=0){
            choose.mp3Url = self.audio[@"path"];
        }
        choose.tipLabelText = self.ques;
        choose.choices = self.choices;
        choose.trueAnswerIndex = [self.keys[0] integerValue];
        return choose;
//        [self.selectArray addObject:choose];
    } else if ([type isEqualToString:@"img_matching"]){
        NDMatchModel *match = [[NDMatchModel alloc]init];
        match.type = type;
        if(self.audio.count!=0){
            match.mp3Url = self.audio[@"path"];
        }
        match.tipLabelText = self.ques;
        match.baseImgArr = self.baseImgArr;
        match.matchImgArr = self.matchImgArr;
        return match;
//        [self.selectArray addObject:match];
    }else if ([type isEqualToString:@"filling"]){
        NDFillingModel *filling = [[NDFillingModel alloc]init];
        filling.type = type;
        if(self.audio.count!=0){
            filling.mp3Url = self.audio[@"path"];
        }
        filling.tipLabelText = self.ques;
        filling.content = self.content;
        filling.keys = self.keys;
        return filling;
//        [self.selectArray addObject:filling];
    }
//    return self.selectArray;
    return nil;
}

@end
