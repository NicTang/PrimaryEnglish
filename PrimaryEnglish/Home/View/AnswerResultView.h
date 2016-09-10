//
//  AnswerResultView.h
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/8/12.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AnswerResultView;

@protocol AnswerResultViewDelegate <NSObject>

@optional
- (void)resultViewCilckToViewResult:(AnswerResultView *)resultView;
- (void)resultViewCilckToShareInfo:(AnswerResultView *)resultView;
- (void)resultViewCilckToReturn:(AnswerResultView *)resultView;

@end


@interface AnswerResultView : UIView

@property (nonatomic,copy) NSString *resultScore;
@property (nonatomic,copy) NSString *userName;
@property (nonatomic,assign) NSInteger rightCount;
@property (nonatomic,assign) NSInteger wrongCount;

@property (nonatomic,weak) id<AnswerResultViewDelegate>delegate;

- (void)createUserScoreUI;

@end
