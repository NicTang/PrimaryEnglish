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

@interface NDSelectModel()

@end

@implementation NDSelectModel

- (id)parseDataByType:(NSString *)type
{
    if ([type isEqualToString:@"simple_choose"]) {
        
        NDChooseModel *choose = [[NDChooseModel alloc]init];
        choose.type = type;
        if(self.audio.count!=0){
            NSString *path = self.audio[@"path"];
            choose.mp3Url = [NSString stringWithFormat:PrefixForUrl,path];
        }
        choose.isPic = [self.ispic boolValue];
        if (choose.isPic) {
            choose.imageArray = [NSMutableArray array];
            for (NSDictionary *dict in self.choices) {
                NSString *url = dict[@"url"];
                NSString *imgUrl = [NSString stringWithFormat:PrefixForUrl,url];
                [choose.imageArray addObject:imgUrl];
            }
        }else
        {
            choose.textArray = self.choices;
        }
        choose.tipLabelText = self.ques;
        choose.trueAnswerIndex = [self.keys[0] integerValue];
        return choose;
    } else if ([type isEqualToString:@"img_matching"]){
        NDMatchModel *match = [[NDMatchModel alloc]init];
        match.type = type;
        if(self.audio.count!=0){
            NSString *path = self.audio[@"path"];
            match.mp3Url = [NSString stringWithFormat:PrefixForUrl,path];
        }
        match.tipLabelText = self.ques;
        match.baseImgArr = [self addPrefixForStringsOfArray:self.baseImgArr];
        match.matchImgArr = [self addPrefixForStringsOfArray:self.matchImgArr];
        return match;
    }
    return nil;
}
- (NSArray *)addPrefixForStringsOfArray:(NSArray *)imageArray
{
    NSMutableArray *newArr = [NSMutableArray array];
    for (NSString *string in imageArray) {
        NSString *urlString = [NSString stringWithFormat:PrefixForUrl,string];
        [newArr addObject:urlString];
    }
    return newArr;
}
@end
