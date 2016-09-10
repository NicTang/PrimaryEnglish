//
//  AnswerChoiceModel.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/8/11.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnswerChoiceModel : NSObject

@property (nonatomic,assign) NSInteger trueIndex;
@property (nonatomic,assign) NSInteger userIndex;
@property (nonatomic,assign) BOOL isRight;

@end
