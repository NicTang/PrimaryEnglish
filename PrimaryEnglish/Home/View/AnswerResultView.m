//
//  AnswerResultView.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/8/12.
//  Copyright © 2016年 Nic. All rights reserved.
//

#define PaddingY 50*ScaleValueY
#define PaddingX 120*ScaleValueX
#define MarginY 220*ScaleValueY
#define NameLabelH 60*ScaleValueY
#define MarginScoreY 20*ScaleValueY
#define MarginNumberY 10*ScaleValueY
#define NumberLabelH 30*ScaleValueY

#define NumberFontSize 15*ScaleValueY
#define ScoreFontSize 26*ScaleValueY
#define LineWidth 5*ScaleValueY

#define MarginAnswerY 36*ScaleValueY
#define ButtonH 40*ScaleValueY
#define AnswerButtonH 30*ScaleValueY
#define AnswerButtonW 100*ScaleValueX
#define AnswerFontSize 13*ScaleValueY

#define MarginButtonY 28*ScaleValueY
#define ButtonPaddingX 20*ScaleValueX
#define ButtonPadding 20*ScaleValueX
#define ButtonFontSize 17*ScaleValueY
#define ButtonW (KScreenWidth - 2*ButtonPaddingX - ButtonPadding)/2

#import "AnswerResultView.h"

@interface AnswerResultView ()

@end

@implementation AnswerResultView

- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat centerX = rect.size.width/2;
    CGFloat radius = (rect.size.width - 2*PaddingX)/2;
    CGFloat centerY = PaddingY + radius;
    CGContextAddArc(ctx, centerX, centerY, radius, -M_PI_2, M_PI_2*3, 0);
    CGContextSetLineWidth(ctx, LineWidth);
    [Color(180, 180, 180) set];
    CGContextStrokePath(ctx);
    
    int progress = [self.resultScore intValue];
    CGFloat proAngle = (progress*(M_PI*2)/100+ M_PI_2);
    CGContextAddArc(ctx, centerX, centerY, radius, -M_PI_2, -proAngle, 1);
    [Color(255, 0, 0) set];
    CGContextStrokePath(ctx);
    
    CGFloat tipStrH = 2*radius/7;
    CGRect tipFrame = CGRectMake(centerX-radius, centerY-tipStrH/2, radius*2, tipStrH);
    NSString *tipStr = @"你的得分";
    [tipStr drawInRect:tipFrame withAttributes:[self setAttributesWithFont:[UIFont systemFontOfSize:16*ScaleValueY] textColor:Color(255, 0, 0)]];
    CGFloat scoreX = centerX - radius/3;
    CGFloat scoreY = centerY + tipStrH ;
    CGRect scoreFrame = CGRectMake(scoreX, scoreY, radius/1.5, radius/1.5);
    [self.resultScore drawInRect:scoreFrame withAttributes:[self setAttributesWithFont:[UIFont boldSystemFontOfSize:ScoreFontSize] textColor:Color(255, 0, 0)]];
}
- (NSMutableDictionary *)setAttributesWithFont:(UIFont *)font textColor:(UIColor *)textColor
{
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByClipping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSFontAttributeName] = font;//字体
    dict[NSForegroundColorAttributeName] = textColor;//颜色
    dict[NSParagraphStyleAttributeName] = paragraphStyle;
    return dict;
}
- (void)createUserScoreUI
{
    NSString *name = [NSString stringWithFormat:@"%@ 同学",self.userName];
    NSRange nameRange = [name rangeOfString:self.userName];
    UILabel *nameLabel = [self createLabelByBaseFrame:CGRectZero withMargin:MarginY labelHeight:NameLabelH TextString:name fontSize:ScoreFontSize];
    NSMutableAttributedString *nameAttri = [[NSMutableAttributedString alloc]initWithAttributedString:nameLabel.attributedText];
    [nameAttri addAttribute:NSForegroundColorAttributeName value:Color(255, 0, 0) range:nameRange];
    [nameAttri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:ScoreFontSize*1.5] range:nameRange];
    [nameLabel setAttributedText:nameAttri];
    [self addSubview:nameLabel];
    
    NSString *score = [NSString stringWithFormat:@"你的得分 %@",self.resultScore];
    NSRange scoreRange = [score rangeOfString:self.resultScore];
    UILabel *scoreLabel = [self createLabelByBaseFrame:nameLabel.frame withMargin:MarginScoreY labelHeight:NumberLabelH TextString:score fontSize:NumberFontSize];
    NSMutableAttributedString *scoreAttri = [[NSMutableAttributedString alloc]initWithAttributedString:scoreLabel.attributedText];
    [scoreAttri addAttributes:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:NumberFontSize*1.5]} range:scoreRange];
    [scoreLabel setAttributedText:scoreAttri];
    [self addSubview:scoreLabel];
    
    NSString *right = [NSString stringWithFormat:@"做对了 %ld 道题",self.rightCount];
    NSRange rightRange = [right rangeOfString:[NSString stringWithFormat:@"%ld",self.rightCount]];
    UILabel *rightLabel = [self createLabelByBaseFrame:scoreLabel.frame withMargin:MarginNumberY labelHeight:NumberLabelH TextString:right fontSize:NumberFontSize];
    NSMutableAttributedString *rightAttri = [[NSMutableAttributedString alloc]initWithAttributedString:rightLabel.attributedText];
    [rightAttri addAttributes:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:NumberFontSize*1.5]} range:rightRange];
    [rightLabel setAttributedText:rightAttri];
    [self addSubview:rightLabel];
    
    NSString *wrong = [NSString stringWithFormat:@"做对了 %ld 道题",self.wrongCount];
    NSRange wrongRange = [wrong rangeOfString:[NSString stringWithFormat:@"%ld",self.wrongCount]];
    UILabel *wrongLabel = [self createLabelByBaseFrame:rightLabel.frame withMargin:MarginNumberY labelHeight:NumberLabelH TextString:[NSString stringWithFormat:@"做错了 %ld 道题",self.wrongCount] fontSize:NumberFontSize];
    NSMutableAttributedString *wrongAttri = [[NSMutableAttributedString alloc]initWithAttributedString:wrongLabel.attributedText];
    [wrongAttri addAttributes:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:NumberFontSize*1.5]} range:wrongRange];
    [wrongLabel setAttributedText:wrongAttri];
    [self addSubview:wrongLabel];
    
    CGFloat answerY = CGRectGetMaxY(wrongLabel.frame) + MarginAnswerY;
    CGFloat answerX = KScreenWidth/2 - AnswerButtonW/2;
    CGRect answerFrame = CGRectMake(answerX, answerY, AnswerButtonW, AnswerButtonH);
    UIButton *viewAnswerBtn = [self createButtonByFrame:answerFrame withText:@"查看得分情况" textColor:Color(92, 219, 85) fontSize:AnswerFontSize backgroundColor:nil];
    viewAnswerBtn.layer.borderWidth = 2;
    viewAnswerBtn.layer.borderColor = Color(92, 219, 85).CGColor;
    [viewAnswerBtn addTarget:self action:@selector(viewResultScore:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:viewAnswerBtn];
    
    CGFloat buttonY = CGRectGetMaxY(viewAnswerBtn.frame) + MarginButtonY;
    CGRect shareBtnFrame = CGRectMake(ButtonPaddingX, buttonY, ButtonW, ButtonH);
    CGRect backBtnFrame = CGRectMake(ButtonPaddingX+ButtonW+ButtonPadding, buttonY, ButtonW, ButtonH);
    UIButton *shareBtn = [self createButtonByFrame:shareBtnFrame withText:@"马上分享" textColor:[UIColor whiteColor] fontSize:ButtonFontSize backgroundColor:Color(234, 103, 37)];
    UIButton *backBtn = [self createButtonByFrame:backBtnFrame withText:@"返回继续" textColor:[UIColor whiteColor] fontSize:ButtonFontSize backgroundColor:Color(234, 103, 37)];
    [shareBtn addTarget:self action:@selector(shareExerciseInfo:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn addTarget:self action:@selector(backToReturn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:shareBtn];
    [self addSubview:backBtn];
}
- (UILabel *)createLabelByBaseFrame:(CGRect)frame withMargin:(CGFloat)marginY labelHeight:(CGFloat)labelH TextString:(NSString *)textString fontSize:(CGFloat)fontSize
{
    CGFloat labelY = CGRectGetMaxY(frame)+ marginY;
    CGRect labelFrame = CGRectMake(0, labelY, KScreenWidth, labelH);
    UILabel *label = [[UILabel alloc]initWithFrame:labelFrame];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSFontAttributeName] = [UIFont systemFontOfSize:fontSize];
    NSAttributedString *attrStr = [[NSAttributedString alloc]initWithString:textString attributes:dict];
    [label setAttributedText:attrStr];
    return label;
}
- (UIButton *)createButtonByFrame:(CGRect)frame withText:(NSString *)text textColor:(UIColor *)textColor fontSize:(CGFloat)fontSize  backgroundColor:(UIColor *)bgColor
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setBackgroundColor:bgColor];
    
    NSDictionary *dict = @{NSForegroundColorAttributeName:textColor,NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};
    NSAttributedString *attrs = [[NSAttributedString alloc]initWithString:text attributes:dict];
    button.contentMode = UIViewContentModeCenter;
    [button setAttributedTitle:attrs forState:UIControlStateNormal];
    button.layer.cornerRadius = 5;
    return button;
}
- (void)viewResultScore:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(resultViewCilckToViewResult:)]) {
        [self.delegate performSelector:@selector(resultViewCilckToViewResult:) withObject:self];
    }
}
- (void)shareExerciseInfo:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(resultViewCilckToShareInfo:)]) {
        [self.delegate performSelector:@selector(resultViewCilckToShareInfo:) withObject:self];
    }
}
- (void)backToReturn:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(resultViewCilckToReturn:)]) {
        [self.delegate performSelector:@selector(resultViewCilckToReturn:) withObject:self];
    }
}
@end
