//
//  VocabularyPracticeController.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/28.
//  Copyright © 2016年 Nic. All rights reserved.
//

#define BaseScrollViewTag 100
#define ResultScrollViewTag 300

#define SelectViewBaseTag 300
#define IsRightChoiceWH 60*ScaleValueX
#define IsRightMatchWH 32*ScaleValueX

#define LimitViewX 20*ScaleValueX
#define LimitViewY 30*ScaleValueY
#define CrossBtnWH 30*ScaleValueY

#define CardPageViewH 49*ScaleValueY
#define CardPaddingX 30*ScaleValueX
#define CardPaddingY 30*ScaleValueX
#define CardPagePaddingY 20*ScaleValueY
#define PageLabelW 66*ScaleValueX
#define PageLabelH 40*ScaleValueY

#import "CoursesPracticeController.h"
#import "AFHTTPSessionManager.h"//网络请求
#import "UIImageView+AFNetworking.h"//显示网络图片
#import "RDVTabBarController.h"
#import "NDSelectModel.h"//词汇练习所有题目模型
#import "NDChooseModel.h"//词汇练习选择题目模型
#import "NDMatchModel.h"//词汇练习图片拖拽连线模型
#import <AVFoundation/AVFoundation.h>//音频播放
#import "AnswerChoiceModel.h"
#import "AnswerResultView.h"
#import "UMSocialSnsService.h"//友盟分享
#import "UMSocialSnsPlatformManager.h"
#import "UIImage+NewImage.h"
#import "UserModel.h"

@interface CoursesPracticeController ()<UIScrollViewDelegate,AnswerResultViewDelegate>
{
    UIScrollView *_scrollView;
    UIView *_exerciseView;
    UIProgressView *_progressView;
    AVPlayer *_player;
    NSTimer *_timer;
    UIView *_resultDetailView;
    UIView *_cardPageView;
    UILabel *_pageLabel;
}
@property (nonatomic,strong) NSMutableDictionary *cardDict;
@property (nonatomic,strong) NSMutableArray *exerciseArray;
@property (nonatomic,assign) NSInteger tapCount;
@property (nonatomic,assign) NSInteger currentPage;

@property (nonatomic,strong) UIView *selectedView;

@property (nonatomic,strong) UIButton *nextButton;//下一题
@property (nonatomic,copy) NSString *playMp3Url;
//拖拽连线
@property (nonatomic,strong) NSMutableArray *baseFrameArray;
@property (nonatomic,strong) NSMutableArray *matchFrameArray;

@property (nonatomic,strong) NSMutableArray *baseImgArray;
@property (nonatomic,strong) NSMutableArray *matchImgArray;
@property (nonatomic,strong) NSMutableDictionary *matchLineDict;

@property (nonatomic,strong) NSMutableArray *baseIsEmptyIndexes;
@property (nonatomic,strong) NSMutableArray *matchTransIndexes;
@property (nonatomic,strong) NSMutableArray *answerArray;
//答题情况
@property (nonatomic,assign) NSInteger trueAnswerIndex;
@property (nonatomic,assign) NSInteger choiceIndex;//用户选择
@property (nonatomic,strong) NSDictionary *currentLineDict;
@property (nonatomic,strong) NSMutableDictionary *answerMp3Dict;
@end

@implementation CoursesPracticeController
/**
 *  不隐藏底部tabbar
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self createUI];
    
    [self requestDataWithSenceid:self.senceid completionHandler:^(NSMutableDictionary *cardDict, NSArray *exerciseArray) {
        self.currentPage = 0;
        [self refreshUI:^{
            NSArray *mp3Array = cardDict[@(self.currentPage)];
            [self initMp3PlayerWithArray:mp3Array];
        }];
    }];
}
- (NSMutableDictionary *)cardDict
{
    if (!_cardDict) {
        _cardDict = [NSMutableDictionary dictionary];
    }
    return _cardDict;
}
- (NSMutableArray *)exerciseArray
{
    if (!_exerciseArray) {
        _exerciseArray = [NSMutableArray array];
    }
    return _exerciseArray;
}
- (NSMutableArray *)baseFrameArray
{
    if (!_baseFrameArray) {
        _baseFrameArray = [NSMutableArray array];
    }
    return _baseFrameArray;
}
- (NSMutableArray *)matchFrameArray
{
    if (!_matchFrameArray) {
        _matchFrameArray = [NSMutableArray array];
    }
    return _matchFrameArray;
}
- (NSMutableArray *)baseImgArray
{
    if (!_baseImgArray) {
        _baseImgArray = [NSMutableArray array];
    }
    return _baseImgArray;
}
- (NSMutableArray *)matchImgArray
{
    if (!_matchImgArray) {
        _matchImgArray = [NSMutableArray array];
    }
    return _matchImgArray;
}
- (NSMutableDictionary *)matchLineDict
{
    if (!_matchLineDict) {
        _matchLineDict = [NSMutableDictionary dictionary];
    }
    return _matchLineDict;
}
- (NSMutableArray *)baseIsEmptyIndexes
{
    if (!_baseIsEmptyIndexes) {
        _baseIsEmptyIndexes = [NSMutableArray array];
    }
    return _baseIsEmptyIndexes;
}
- (NSMutableArray *)matchTransIndexes
{
    if (!_matchTransIndexes) {
        _matchTransIndexes = [NSMutableArray array];
    }
    return _matchTransIndexes;
}
- (NSMutableArray *)answerArray
{
    if (!_answerArray) {
        _answerArray = [NSMutableArray array];
    }
    return _answerArray;
}
- (NSMutableDictionary *)answerMp3Dict
{
    if (!_answerMp3Dict) {
        _answerMp3Dict = [NSMutableDictionary dictionary];
    }
    return _answerMp3Dict;
}
- (void)createUI
{
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64)];
    _scrollView.pagingEnabled = YES;
    _scrollView.tag = BaseScrollViewTag;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    self.view.backgroundColor = Color(234, 103, 37);
    [self.view addSubview:_scrollView];
}
#pragma mark - 请求数据之后刷新UI
- (void)refreshUI:(void(^)())completionHandler
{
    if (self.cardDict.count!=0) {
        for (int i = 0; i<self.cardDict.count; i++) {
            NSArray *cardArray = self.cardDict[@(i)];
            UIImageView *imageView = [[UIImageView alloc]init];
            self.tapCount = 0;//初始化手势点击次数
            [imageView setImageWithURL:[NSURL URLWithString:cardArray[0]]];
            imageView.tag = i;
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(rotateToShowBackgroundImage:)];
            [imageView addGestureRecognizer:tap];
            imageView.frame = CGRectMake(i*KScreenWidth+CardPaddingX, CardPaddingY, KScreenWidth-2*CardPaddingX, KScreenHeight-64-CardPaddingY-CardPageViewH-CardPagePaddingY);
            [_scrollView addSubview:imageView];
        }
        CGFloat cardPageViewY = CGRectGetMaxY(_scrollView.frame)-CardPageViewH;
        _cardPageView = [[UIView alloc]init];
        _cardPageView.frame = CGRectMake(0, cardPageViewY, KScreenWidth, CardPageViewH);
        _cardPageView.hidden = NO;
        _cardPageView.backgroundColor = Color(234, 103, 37);
        [self.view addSubview:_cardPageView];
        
        _pageLabel = [[UILabel alloc]initWithFrame:CGRectMake((KScreenWidth-PageLabelW)/2, (CardPageViewH-PageLabelH)/2, PageLabelW, PageLabelH)];
        [_pageLabel setText:[NSString stringWithFormat:@"1 / %ld",self.cardDict.count]];
        [_pageLabel setTextColor:[UIColor whiteColor]];
        [_pageLabel setFont:[UIFont systemFontOfSize:20*ScaleValueX]];
        [_cardPageView addSubview:_pageLabel];
        //播放音频
        completionHandler();
    }
    CGRect viewFrame = CGRectMake(self.cardDict.count*KScreenWidth, 0, KScreenWidth, KScreenHeight);
    _exerciseView = [self createViewWithIndex:0 viewFrame:viewFrame width:KScreenWidth height:KScreenHeight isResultFlag:NO userAnswer:nil];
    _scrollView.contentSize = CGSizeMake(KScreenWidth*(self.cardDict.count+1), 0);
    [_scrollView addSubview:_exerciseView];
}
#pragma mark - 下一题界面设计
- (UIView *)createViewWithIndex:(NSInteger)index viewFrame:(CGRect)frame width:(CGFloat)width height:(CGFloat)height isResultFlag:(BOOL)flag userAnswer:(id)answer
{
    NSDictionary *modelDict = self.exerciseArray[index];
    NSString *type = modelDict.allKeys[0];
    
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor whiteColor];
    view.frame = frame;
    
    CGFloat scaleNumberX = 1.0*width/KScreenWidth;
    CGFloat scaleNumberY = 1.0*height/KScreenHeight;
    CGFloat paddingX = 20*scaleNumberX;
    CGFloat paddingY = 20*scaleNumberY;
    CGFloat progressLabelW = 40*scaleNumberX;
    
    CGFloat progressW = width-2*paddingX - progressLabelW;
    _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(paddingX, 1.5*paddingY, progressW, 10*scaleNumberY)];
    _progressView.transform = CGAffineTransformMakeScale(1.0f, 4.0f*scaleNumberY);
    _progressView.contentMode = UIViewContentModeScaleAspectFill;
    _progressView.layer.cornerRadius = 3.5;
    _progressView.layer.masksToBounds = YES;
    _progressView.trackTintColor = Color(230, 230, 230);
    _progressView.progressTintColor = Color(92, 219, 85);
    _progressView.progress = (index+1)*1.0/self.exerciseArray.count;
    [view addSubview:_progressView];
    
    CGFloat labelX = CGRectGetMaxX(_progressView.frame);
    UILabel *progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(labelX, paddingY, progressLabelW, 20*scaleNumberY)];
    
    NSString *textStr = [NSString stringWithFormat:@"%ld/%ld",(index+1),self.exerciseArray.count];
    [self setAttributedTextForLabel:progressLabel withTextString:textStr textColor:Color(168, 168, 168) font:[UIFont boldSystemFontOfSize:12*scaleNumberY]];
    [view addSubview:progressLabel];    
    
    CGFloat textX = paddingX;
    CGFloat playBtnWH = 25*scaleNumberY;
    CGFloat textY = CGRectGetMaxY(_progressView.frame) + paddingY;
    CGRect playBtnFrame = CGRectMake(paddingX, textY, playBtnWH, playBtnWH);
    //简单选择题
    if ([type isEqualToString:@"simple_choose"]) {
        NDChooseModel *choose = modelDict[type];
        UIButton *playBtn = [self isCreatePlayBtnByMp3Url:choose.mp3Url withFrame:playBtnFrame playImage:@"playMp340"];
        if (playBtn!=nil) {
            [self.answerMp3Dict setObject:choose.mp3Url forKey:@(index)];
            textX += playBtnWH + 3*scaleNumberX;
            [view addSubview:playBtn];
        }else
        {
           [self.answerMp3Dict setObject:@"0" forKey:@(index)];
        }
        CGFloat textW = width - textX - paddingX/5;
        UILabel *tipLabel = [self tipLabelWithFrame:CGRectMake(textX, textY, textW, playBtnWH) labelText:choose.tipLabelText];
        [tipLabel setFont:[UIFont systemFontOfSize:15*scaleNumberY]];
        [view addSubview:tipLabel];
        
        NSInteger choiceIndex = -1;
        NSInteger trueIndex = -1;
        if (answer!=nil) {
            if ([answer isKindOfClass:[AnswerChoiceModel class]]) {
                AnswerChoiceModel *model = answer;
                choiceIndex = model.userIndex;
                trueIndex = model.trueIndex;
            }
        }
        CGFloat chooseY = CGRectGetMaxY(tipLabel.frame) + paddingY;
        CGFloat nextBtnH = 40*scaleNumberY;
        CGFloat totalImgH = height - 64-chooseY-nextBtnH-2*paddingY;
        
        if (choose.isPic) {      //图片
            CGFloat imgPaddingY = 20*scaleNumberY;
            CGFloat imgPaddingX = paddingX;
            int maxRow = 2;//图片匹配题：一页最多2行图片
            int maxCol = 2;//最多两列
            CGFloat baseImgViewWH = (totalImgH-imgPaddingY)/maxRow;
            CGFloat thinkImgViewWH = (width-(maxCol+1)*paddingX)/maxCol;
            CGFloat imgViewWH = MIN(thinkImgViewWH, baseImgViewWH);
            if (imgViewWH==baseImgViewWH) {
                imgPaddingX = (width - maxCol*imgViewWH)/(maxCol+1);
            }
            for (int i = 0; i<choose.imageArray.count; i++) {
                UIImageView *imageView = [[UIImageView alloc]init];
                imageView.tag = choose.trueAnswerIndex+SelectViewBaseTag+i;
                self.trueAnswerIndex = choose.trueAnswerIndex;
                CGFloat imageY = chooseY +i/maxCol*(imgViewWH + imgPaddingY);
                imageView.frame = CGRectMake(i%maxCol*(imgPaddingX+imgViewWH)+imgPaddingX, imageY, imgViewWH, imgViewWH);
                NSURL *url = [NSURL URLWithString:choose.imageArray[i]];
                [imageView setImageWithURL:url];
                imageView.layer.borderWidth = 2;
                imageView.layer.borderColor = Color(168, 168, 168).CGColor;
                imageView.backgroundColor = Color(245, 245, 245);
                
                CGPoint center = CGPointMake(imgViewWH, imgViewWH);
                UIView *colorView = [[UIView alloc]init];
                colorView.bounds = CGRectMake(0, 0, 40*scaleNumberY, 40*scaleNumberY);
                colorView.backgroundColor = Color(92, 219, 85);
                colorView.center = center;
                colorView.transform = CGAffineTransformMakeRotation(M_PI_4);
                CGFloat isRightChoiceWH = imgViewWH/2;
                //对错图片
                CGFloat isRightViewX = imgViewWH - isRightChoiceWH;
                CGFloat isRightViewY = imgViewWH - isRightChoiceWH;
                CGRect isRightViewFrame = CGRectMake(isRightViewX, isRightViewY, isRightChoiceWH, isRightChoiceWH);
                if (flag) {
                    if (choiceIndex!=-1&&trueIndex!=-1) {
                        if (choiceIndex==trueIndex) {
                            if (i==choiceIndex) {
                                colorView.hidden = NO;
                                UIImageView *isRightView = [[UIImageView alloc]initWithFrame:isRightViewFrame];
                                isRightView.image = [UIImage imageNamed:@"right_choose"];
                                [imageView addSubview:isRightView];
                                imageView.layer.borderColor = Color(92, 219, 85).CGColor;
                            }else
                            {
                                colorView.hidden = YES;
                            }
                        }else
                        {
                            if (i==choiceIndex) {
                                colorView.hidden = NO;
                                UIImageView *isRightView = [[UIImageView alloc]initWithFrame:isRightViewFrame];
                                isRightView.image = [UIImage imageNamed:@"wrong_choose"];
                                [imageView addSubview:isRightView];
                                imageView.layer.borderColor = Color(92, 219, 85).CGColor;
                            }else if (i==trueIndex)
                            {
                                colorView.hidden = YES;
                                UIImageView *isRightView = [[UIImageView alloc]initWithFrame:isRightViewFrame];
                                isRightView.image = [UIImage imageNamed:@"right_choose"];
                                [imageView addSubview:isRightView];
                            }else
                            {
                                colorView.hidden = YES;
                                UIImageView *isRightView = [[UIImageView alloc]initWithFrame:isRightViewFrame];
                                isRightView.image = [UIImage imageNamed:@"wrong_choose"];
                                [imageView addSubview:isRightView];
                            }
                        }
                    }
                }else
                {
                    colorView.hidden = YES;
                }
                imageView.clipsToBounds = YES;
                [imageView addSubview:colorView];
                
                imageView.userInteractionEnabled = !flag;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToSelectView:)];
                [imageView addGestureRecognizer:tap];
                [view addSubview:imageView];
            }
        }else     //文字
        {
            CGFloat textPaddingX = 20*scaleNumberY;
            CGFloat textPaddingY = 16*scaleNumberY;
            int maxRow = 4;//图片匹配题：一页最多4行图片
            int maxCol = 1;//最多1列
            
            CGFloat baseTextViewH = (totalImgH-(maxRow-1)*textPaddingY)/maxRow;
            CGFloat thinkTextViewH = 60*scaleNumberY;
            
            CGFloat textViewH = MIN(baseTextViewH, thinkTextViewH);
            CGFloat textViewW = width-(maxCol+1)*textPaddingX;
            
            for (int j = 0; j<choose.textArray.count; j++) {
                UILabel *choiceLabel = [[UILabel alloc]initWithFrame:CGRectMake(textPaddingX, chooseY+j*(textViewH+textPaddingY), textViewW, textViewH)];
                [self setAttributedTextForLabel:choiceLabel withTextString:choose.textArray[j] textColor:[UIColor whiteColor] font:[UIFont boldSystemFontOfSize:17*scaleNumberY]];
                choiceLabel.backgroundColor = Color(168, 168, 168);
                choiceLabel.tag = choose.trueAnswerIndex + SelectViewBaseTag+j;
                self.trueAnswerIndex = choose.trueAnswerIndex;
                //对错图片
                CGFloat isRightChoiceWH = textViewH;
                CGFloat isRightViewX = width-2*textPaddingX - isRightChoiceWH;
                CGRect isRightViewFrame = CGRectMake(isRightViewX, 0, isRightChoiceWH, isRightChoiceWH);
                if (flag) {
                    if (choiceIndex!=-1&&trueIndex!=-1) {
                        if (choiceIndex==trueIndex) {
                            if (j==choiceIndex) {
                                UIImageView *isRightView = [[UIImageView alloc]initWithFrame:isRightViewFrame];
                                isRightView.image = [UIImage imageNamed:@"right_choose"];
                                [choiceLabel addSubview:isRightView];
                                choiceLabel.backgroundColor = Color(92, 219, 85);
                            }else
                            {
                                choiceLabel.backgroundColor = Color(168, 168, 168);
                            }
                        }else
                        {
                            if (j==choiceIndex) {
                                UIImageView *isRightView = [[UIImageView alloc]initWithFrame:isRightViewFrame];
                                isRightView.image = [UIImage imageNamed:@"wrong_choose"];
                                [choiceLabel addSubview:isRightView];
                                choiceLabel.backgroundColor = Color(92, 219, 85);
                            }else if (j==trueIndex)
                            {
                                UIImageView *isRightView = [[UIImageView alloc]initWithFrame:isRightViewFrame];
                                isRightView.image = [UIImage imageNamed:@"right_choose"];
                                [choiceLabel addSubview:isRightView];
                                choiceLabel.backgroundColor = Color(168, 168, 168);
                            }else
                            {
                                UIImageView *isRightView = [[UIImageView alloc]initWithFrame:isRightViewFrame];
                                isRightView.image = [UIImage imageNamed:@"wrong_choose"];
                                [choiceLabel addSubview:isRightView];
                                choiceLabel.backgroundColor = Color(168, 168, 168);
                            }
                        }
                    }
                }else
                {
                    choiceLabel.backgroundColor = Color(168, 168, 168);
                }
                choiceLabel.userInteractionEnabled = !flag;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToSelectView:)];
                [choiceLabel addGestureRecognizer:tap];
                [view addSubview:choiceLabel];
            }
        }
    }
    else if ([type isEqualToString:@"img_matching"]){
        //图片匹配题
        NDMatchModel *match = modelDict[type];
        UIButton *playBtn = [self isCreatePlayBtnByMp3Url:match.mp3Url withFrame:playBtnFrame playImage:@"playMp340"];
        if (playBtn!=nil) {
            [self.answerMp3Dict setObject:match.mp3Url forKey:@(index)];
            textX += playBtnWH + 3*scaleNumberX;
            [view addSubview:playBtn];
        }else
        {
            [self.answerMp3Dict setObject:@"0" forKey:@(index)];
        }
        CGFloat textW = width - textX - paddingX/5;
        UILabel *tipLabel = [self tipLabelWithFrame:CGRectMake(textX, textY, textW, playBtnWH) labelText:match.tipLabelText];
        [tipLabel setFont:[UIFont systemFontOfSize:15*scaleNumberY]];
        [view addSubview:tipLabel];
        CGFloat chooseY = CGRectGetMaxY(tipLabel.frame) + paddingY/2;
        
        CGFloat nextBtnH = 40*scaleNumberY;
        CGFloat totalImgH = height - 64-chooseY-nextBtnH-2*paddingY;
        CGFloat imgPaddingY = 16*scaleNumberY;
        int maxRow = 4;//图片匹配题：一页最多4行图片
        int maxCol = 2;//最多两列
        CGFloat baseImgH = (totalImgH-(maxRow-1)*imgPaddingY)/maxRow;
        CGFloat baseImgW = 300*baseImgH/255;
        CGFloat matchImgH = baseImgH*6/7;
        CGFloat matchImgW = baseImgW*6/7;
        CGFloat imgPaddingX = (width-baseImgW-matchImgW)/(maxCol+1);
        CGFloat isRightMatchWH = 32*scaleNumberY;
        
        for (int m = 0; m<match.baseImgArr.count; m++) {
            UIImageView *baseImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imgPaddingX, chooseY+m*(baseImgH+imgPaddingY), baseImgW, baseImgH)];
            [self addShadowForView:baseImageView withColor:Color(168, 168, 168)];
            NSURL *baseImgUrl = [NSURL URLWithString:match.baseImgArr[m]];
            [baseImageView setImageWithURL:baseImgUrl];
            [view addSubview:baseImageView];
            
            [self.baseImgArray addObject:baseImageView];
            [self.baseIsEmptyIndexes addObject:@(1)];
            [self.baseFrameArray addObject:[NSValue valueWithCGRect:baseImageView.frame]];
            if (flag) {
                //如果是答案，左边view旋转
                [self addAnimationForView:baseImageView withScaleX:0.7 scaleY:0.7 rotate:-M_PI/6];
            }
        }
        for (int n = 0; n<match.matchImgArr.count; n++) {
            UIView *matchView = [[UIView alloc]init];
            matchView.backgroundColor = [UIColor whiteColor];
            matchView.bounds = CGRectMake(0, 0, matchImgW, matchImgH);
            CGRect baseFrame = [self.baseFrameArray[n] CGRectValue];
            CGFloat baseCenterX = baseFrame.origin.x + baseFrame.size.width/2;
            CGFloat baseCenterY = baseFrame.origin.y + baseFrame.size.height/2;
            CGFloat centerX = baseCenterX + (baseImgW+matchImgW)/2 + imgPaddingX;
            matchView.center = CGPointMake(centerX, baseCenterY);
            
            [self.matchFrameArray addObject:[NSValue valueWithCGRect:matchView.frame]];
            [self addShadowForView:matchView withColor:Color(168, 168, 168)];
            [view addSubview:matchView];
            
            UIImageView *matchImageView = [[UIImageView alloc]initWithFrame:matchView.frame];
            
            NSURL *matchImgUrl = [NSURL URLWithString:match.matchImgArr[n]];
            matchImageView.tag = n;
            
            [matchImageView setImageWithURL:matchImgUrl];
            [self.matchImgArray addObject:matchImageView];
            [self.matchTransIndexes addObject:@(0)];
            
            matchImageView.userInteractionEnabled = !flag;
            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panViewToMatchOtherView:)];
            pan.maximumNumberOfTouches = 1;
            [matchImageView addGestureRecognizer:pan];
            [view addSubview:matchImageView];
            //图片匹配答案显示
            if (flag&&answer!=nil) {
                if ([answer isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *answerDict = answer;
                    NSInteger valueIndex = [[answerDict objectForKey:@(n)] integerValue];
                    CGRect valueFrame = [self.baseFrameArray[valueIndex] CGRectValue];
                    if (!CGRectEqualToRect(valueFrame, CGRectZero)) {
                        UIImageView *matchImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, matchImgW, matchImgH)];
                        matchImgView.frame = [self getNewFrameForView:matchImgView ByFrame:valueFrame];
                        NSURL *matchImgUrl = [NSURL URLWithString:match.matchImgArr[n]];
                        [matchImgView setImageWithURL:matchImgUrl];
                        
                        CGFloat isRightViewX = (matchImgW-isRightMatchWH)/2;
                        UIImageView *isRightView = [[UIImageView alloc]initWithFrame:CGRectMake(isRightViewX, -isRightMatchWH/2, isRightMatchWH, isRightMatchWH)];
                        if (n==valueIndex) {
                            isRightView.image = [UIImage imageNamed:@"right_match"];
                        }else{
                            isRightView.image = [UIImage imageNamed:@"wrong_match"];
                        }
                        [matchImgView addSubview:isRightView];
                        [view addSubview:matchImgView];
                        [self addAnimationForView:matchImgView withScaleX:0.7 scaleY:0.7 rotate:M_PI/6];
                    }
                }
            }
        }
    }
    if (!flag) {
        UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat nextBtnH = 40*scaleNumberY;
        CGFloat nextBtnY = height - nextBtnH - 64 - paddingY;
        nextBtn.frame = CGRectMake(paddingX, nextBtnY, width-2*paddingX, nextBtnH);
        NSString *titleStr = (index==self.exerciseArray.count-1)?@"提交":@"下一题";
        [nextBtn setTitle:titleStr forState:UIControlStateNormal];
        [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [nextBtn setBackgroundColor:Color(168, 168, 168)];
        nextBtn.layer.cornerRadius = 5;
        nextBtn.enabled = NO;
        nextBtn.tag = index;
        [nextBtn addTarget:self action:@selector(nextViewForExercise:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:nextBtn];
        self.nextButton = nextBtn;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(observingIsChooseOver:) name:@"matchLineDict" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(observingIsChooseOver:) name:@"userIndex" object:nil];
    }
    return view;
}
#pragma mark - 拖拽UIImageView进行匹配
- (void)panViewToMatchOtherView:(UIPanGestureRecognizer *)panGesture
{
    NSInteger index = panGesture.view.tag;
    [panGesture.view.superview bringSubviewToFront:panGesture.view];
    CGPoint panPoint = [panGesture locationInView:self.view];
    panGesture.view.center = panPoint;
    
    if (panGesture.state==UIGestureRecognizerStateEnded) {
        NSInteger count = self.baseFrameArray.count;
        for (int i = 0;i<count;i++) {
            CGRect baseFrame = [self.baseFrameArray[i] CGRectValue];
            if (CGRectContainsPoint(baseFrame, panPoint)) {
                UIImageView *imgView = self.baseImgArray[i];
                [self addShadowForView:imgView withColor:Color(168, 168, 168)];
                //左边i位置imgView上为空
                if ([self.baseIsEmptyIndexes[i] integerValue]==1) {
                    //拖动的imgView已经发生形变
                    if ([self.matchTransIndexes[index] integerValue]==1) {
                        //拿到左边之前连线的imgView，恢复原状
                        NSInteger imgIndex = [[self.matchLineDict objectForKey:@(index)] integerValue];
                        UIImageView *lineImgView = self.baseImgArray[imgIndex];
                        lineImgView.frame = [self.baseFrameArray[imgIndex] CGRectValue];
                        [self addAnimationForView:lineImgView withScaleX:1 scaleY:1 rotate:0];
                        self.baseIsEmptyIndexes[imgIndex] = @(1);
                        [self.matchLineDict removeObjectForKey:@(index)];
                    }
                    [self addAnimationForView:imgView withScaleX:0.7 scaleY:0.7 rotate:-M_PI/6];
                    panGesture.view.frame = [self getNewFrameForView:panGesture.view ByFrame:baseFrame];
                    [self addAnimationForView:panGesture.view withScaleX:0.7 scaleY:0.7 rotate:M_PI/6];
                    self.baseIsEmptyIndexes[i] = @(0);
                    self.matchTransIndexes[index] = @(1);
                    [self.matchLineDict setObject:@(i) forKey:@(index)];
                }else if ([self.baseIsEmptyIndexes[i] integerValue]==0){//左边的imgView上有图片拖过来
                    //拖动的imgView已经发生形变
                    if ([self.matchTransIndexes[index] integerValue]==1){
                        //在原地拖动
                        if ([[self.matchLineDict objectForKey:@(index)] isEqual:@(i)]) {
                            panGesture.view.frame = [self getNewFrameForView:panGesture.view ByFrame:baseFrame];
                            [self addAnimationForView:panGesture.view withScaleX:0.7 scaleY:0.7 rotate:M_PI/6];
                            self.matchTransIndexes[index]=@(1);
                            self.baseIsEmptyIndexes[i]=@(0);
                        }else
                        {//两个imgView上都有图片，交换位置
                            //跟当前view连线的左边imgView下标
                            NSInteger lineIndex = [[self.matchLineDict objectForKey:@(index)] integerValue];
                            //通过matchLineDict找到i位置所对应的key值，即从右边拖来已形变view的下标
                            NSInteger changeIndex = -1;
                            for (NSNumber *number in self.matchLineDict.allKeys) {
                                if ([self.matchLineDict[number] isEqualToValue:@(i)]) {
                                    changeIndex = [number integerValue];
                                    break;
                                }
                            }
                            if (changeIndex!=-1) {
                                [self.matchLineDict removeObjectForKey:@(changeIndex)];
                                UIImageView *matchImgView = self.matchImgArray[changeIndex];
                                matchImgView.frame = [self getNewFrameForView:matchImgView ByFrame:[self.baseFrameArray[lineIndex] CGRectValue]];
                                [self addAnimationForView:matchImgView withScaleX:0.7 scaleY:0.7 rotate:M_PI/6];
                                [self.matchLineDict setObject:@(lineIndex) forKey:@(changeIndex)];
                                self.matchTransIndexes[changeIndex]=@(1);
                                self.baseIsEmptyIndexes[i]=@(0);
                            }
                            panGesture.view.frame = [self getNewFrameForView:panGesture.view ByFrame:baseFrame];
                            [self addAnimationForView:panGesture.view withScaleX:0.7 scaleY:0.7 rotate:M_PI/6];
                            //移除连线
                            [self.matchLineDict removeObjectForKey:@(index)];
                            [self.matchLineDict setObject:@(i) forKey:@(index)];
                            self.matchTransIndexes[index]=@(1);
                            self.baseIsEmptyIndexes[lineIndex]=@(0);
                        }
                    }else
                    {
                        CGRect frame = [self.matchFrameArray[index] CGRectValue];
                        panGesture.view.frame = frame;
                        self.matchTransIndexes[index]=@(0);
                    }
                }
                break;
            }else
            {
                CGRect frame = [self.matchFrameArray[index] CGRectValue];
                panGesture.view.frame = frame;
                //拖动view已经形变
                if ([self.matchTransIndexes[index] integerValue]==1) {
                    //拿到左边之前连线的imgView，恢复原状
                    NSInteger imgIndex = [[self.matchLineDict objectForKey:@(index)] integerValue];
                    UIImageView *lineImgView = self.baseImgArray[imgIndex];
                    lineImgView.frame = [self.baseFrameArray[imgIndex] CGRectValue];
                    [self addAnimationForView:lineImgView withScaleX:1 scaleY:1 rotate:0];
                    self.baseIsEmptyIndexes[imgIndex] = @(1);
                    [self.matchLineDict removeObjectForKey:@(index)];
                    
                    self.matchTransIndexes[index] = @(0);
                    
                    [self addAnimationForView:panGesture.view withScaleX:1 scaleY:1 rotate:0];
                }
            }
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"matchLineDict" object:nil userInfo:@{@"matchLineDict":self.matchLineDict}];
    }else if (panGesture.state==UIGestureRecognizerStateChanged){
        NSInteger count = self.baseFrameArray.count;
        for (int i = 0;i<count;i++) {
            UIImageView *imgView = self.baseImgArray[i];
            CGRect baseFrame = [self.baseFrameArray[i] CGRectValue];
            if (CGRectContainsPoint(baseFrame, panPoint)) {
                [self addShadowForView:imgView withColor:[UIColor redColor]];
                break;
            }else
            {
                [self addShadowForView:imgView withColor:Color(168, 168, 168)];
            }
        }
    }
}
#pragma mark - 观察用户是否做完本页题目
- (void)observingIsChooseOver:(NSNotification *)notify
{
    NSDictionary *matchDict = notify.userInfo[@"matchLineDict"];
    NSInteger matchCount = matchDict.count;
    NSInteger chooseIndex = [notify.userInfo[@"userIndex"] integerValue];
    if (matchCount==self.baseImgArray.count||chooseIndex>=SelectViewBaseTag) {
        self.choiceIndex = chooseIndex;
        self.nextButton.enabled = YES;
        [self.nextButton setBackgroundColor:Color(234, 103, 37)];
    } else {
        self.nextButton.enabled = NO;
        [self.nextButton setBackgroundColor:Color(168, 168, 168)];
    }
}
#pragma mark - 为View添加阴影
- (void)addShadowForView:(UIView *)view withColor:(UIColor *)shadowColor
{
    view.layer.shadowColor = shadowColor.CGColor;
    view.layer.shadowOffset = CGSizeMake(0,0);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
    view.layer.shadowOpacity = 0.6;//阴影透明度，默认0
    view.layer.shadowRadius = 2;//阴影半径，默认3
}
- (CGRect)getNewFrameForView:(UIView *)view ByFrame:(CGRect)frame
{
    CGSize viewSize = view.frame.size;
    CGFloat viewX = frame.origin.x + frame.size.width/2;
    CGFloat viewY = CGRectGetMaxY(frame) - viewSize.height;
    return CGRectMake(viewX, viewY, viewSize.width, viewSize.height);
}
- (void)addAnimationForView:(UIView *)view withScaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY rotate:(CGFloat)angle
{
    CABasicAnimation *basic1 = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    basic1.toValue = @(scaleX);
    
    CABasicAnimation *basic2 = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    basic2.toValue = @(scaleY);
    
    CABasicAnimation *basic3 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    basic3.toValue = @(angle);
    
    //创建组动画
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[basic1,basic2,basic3];
    group.duration = 1;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    [view.layer addAnimation:group forKey:nil];
}
#pragma mark - 选择题 手势调用方法
- (void)tapToSelectView:(UITapGestureRecognizer *)tapGesture
{
    if (self.selectedView==nil) {
        self.selectedView = [[UIView alloc]init];
    }
    BOOL isChanged = NO;
    UIView *view = tapGesture.view;
    NSInteger chooseIndex = view.tag;
    isChanged = (self.selectedView==view)? NO:YES;
    
    if ([view isKindOfClass:[UIImageView class]]) {
        if (isChanged) {
            UIView *colorView = view.subviews[0];
            colorView.hidden = NO;
            view.layer.borderColor = Color(92, 219, 85).CGColor;
            if (self.selectedView.subviews.count!=0) {
                UIView *selColorView = self.selectedView.subviews[0];
                selColorView.hidden = YES;
                self.selectedView.layer.borderColor = Color(168, 168, 168).CGColor;
            }
        }
    }else if ([view isKindOfClass:[UILabel class]]){
        if (isChanged) {
            view.backgroundColor = Color(92, 219, 85);
            self.selectedView.backgroundColor = Color(168, 168, 168);
        }
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"userIndex" object:nil userInfo:@{@"userIndex":@(chooseIndex)}];
    self.selectedView = view;
}
#pragma mark - 点击创建“下一题”界面
- (void)nextViewForExercise:(UIButton *)nextBtn
{
    NSInteger nextIndex = nextBtn.tag+1;
    
    self.currentLineDict = [NSDictionary dictionaryWithDictionary:self.matchLineDict];
    if (self.choiceIndex>=SelectViewBaseTag) {
        AnswerChoiceModel *choiceModel = [[AnswerChoiceModel alloc]init];
        choiceModel.userIndex = self.choiceIndex - SelectViewBaseTag-self.trueAnswerIndex;
        choiceModel.trueIndex = self.trueAnswerIndex;
        choiceModel.isRight = choiceModel.userIndex==choiceModel.trueIndex;
        [self.answerArray addObject:choiceModel];
    }else if (self.currentLineDict.count==self.baseImgArray.count&&self.baseImgArray.count!=0) {
        [self.answerArray addObject:self.currentLineDict];
    }
    [_exerciseView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_exerciseView removeFromSuperview];
    _exerciseView = nil;
    [self.nextButton removeFromSuperview];
    self.nextButton = nil;
    [self.baseImgArray removeAllObjects];
    [self.baseFrameArray removeAllObjects];
    [self.baseIsEmptyIndexes removeAllObjects];
    [self.matchImgArray removeAllObjects];
    [self.matchFrameArray removeAllObjects];
    [self.matchTransIndexes removeAllObjects];
    [self.matchLineDict removeAllObjects];
    
    if (nextIndex<self.exerciseArray.count) {
        CGRect viewFrame = CGRectMake(self.cardDict.count*KScreenWidth, 0, KScreenWidth, KScreenHeight);
        _exerciseView = [self createViewWithIndex:nextIndex viewFrame:viewFrame width:KScreenWidth height:KScreenHeight isResultFlag:NO userAnswer:nil];
        
    }else if (nextIndex==self.exerciseArray.count)
    {
        CGRect frame = CGRectMake(self.cardDict.count*KScreenWidth, 0, KScreenWidth, KScreenHeight);
        AnswerResultView *resultView = [[AnswerResultView alloc]initWithFrame:frame];
        resultView.delegate = self;
        NSInteger rightCount = 0;
        NSInteger wrongCount = 0;
        for (int i=0; i<self.answerArray.count; i++) {
            id answer = self.answerArray[i];
            if ([answer isKindOfClass:[AnswerChoiceModel class]]) {
                AnswerChoiceModel *model = answer;
                if (model.isRight) {
                    rightCount++;
                }else
                {
                    wrongCount++;
                }
            } else if ([answer isKindOfClass:[NSDictionary class]]){
                for (NSNumber *number in [answer allKeys]) {
                    if (![[answer objectForKey:number]isEqual:number]) {
                        wrongCount++;
                        break;
                    } else if([[answer allKeys]indexOfObject:number]==([answer count]-1)){
                        rightCount++;
                    }
                }
            }
        }
        UserModel *model = [NSKeyedUnarchiver unarchiveObjectWithFile:NDModelSavePath];
        NSString *userName = (model==nil||model.status==1)?@"我(未登录)":model.nickName;
        CGFloat score = rightCount*100.0/self.answerArray.count;
        NSString *scoreStr = [NSString stringWithFormat:@"%.0f",score];
        resultView.resultScore = scoreStr;
        resultView.rightCount = rightCount;
        resultView.wrongCount = wrongCount;
        resultView.userName = userName;
        [resultView setNeedsDisplay];
        [resultView createUserScoreUI];
        resultView.backgroundColor = [UIColor whiteColor];
        _exerciseView = resultView;
    }
    [_scrollView addSubview:_exerciseView];
}
#pragma mark - AnswerResultViewDelegate代理方法
- (void)resultViewCilckToViewResult:(AnswerResultView *)resultView
{
    UIView *view = [[UIView alloc]initWithFrame:resultView.bounds];
    view.backgroundColor = Color(234, 103, 37);
    _resultDetailView = view;
    [resultView addSubview:_resultDetailView];
    CGFloat width = KScreenWidth-2*LimitViewX;
    CGFloat height = KScreenHeight-64-LimitViewX-LimitViewY;
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(LimitViewX, LimitViewY, width, height)];
    
    CGFloat crossBtnX = CGRectGetMaxX(scrollView.frame)-CrossBtnWH;
    CGFloat crossBtnY = CGRectGetMinY(scrollView.frame)-CrossBtnWH;
    CGRect crossBtnFrame = CGRectMake(crossBtnX, crossBtnY, CrossBtnWH, CrossBtnWH);
    UIButton *crossBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    crossBtn.frame = crossBtnFrame;
    [crossBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [crossBtn addTarget:self action:@selector(cancelShowResultView:) forControlEvents:UIControlEventTouchUpInside];
    [resultView addSubview:crossBtn];
    
    for (int i = 0; i<self.exerciseArray.count; i++) {
        CGRect viewFrame = CGRectMake(i*width, 0, width, height);
        UIView *subView = [self createViewWithIndex:i viewFrame:viewFrame width:width height:height isResultFlag:YES userAnswer:self.answerArray[i]];
        [scrollView addSubview:subView];
    }
    scrollView.backgroundColor = Color(234, 103, 37);
    scrollView.contentSize = CGSizeMake(self.exerciseArray.count*width, 0);
    scrollView.pagingEnabled = YES;
    scrollView.tag = ResultScrollViewTag;
    scrollView.showsHorizontalScrollIndicator = YES;
    scrollView.delegate = self;
    [view addSubview:scrollView];
}
- (void)resultViewCilckToShareInfo:(AnswerResultView *)resultView
{
    [UMSocialData defaultData].extConfig.wechatSessionData.url = @"http://baidu.com";
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = @"http://baidu.com";
    [UMSocialData defaultData].extConfig.wechatSessionData.title = self.title;
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = self.title;
    NSString *infoString = [NSString stringWithFormat:@"在 %@ 中我的得分是：%@",self.title,resultView.resultScore];
    //分享png、jpg图片
    [UMSocialSnsService presentSnsIconSheetView:self appKey:KUMengAppKeyString shareText:infoString shareImage:[UIImage captureImageWithView:resultView] shareToSnsNames:@[UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline] delegate:nil];
}
- (void)resultViewCilckToReturn:(AnswerResultView *)resultView
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)cancelShowResultView:(UIButton *)crossButton
{
    [crossButton removeFromSuperview];
    crossButton = nil;
    [_resultDetailView removeFromSuperview];
    _resultDetailView = nil;
}
#pragma mark - 根据mp3Url决定是否创建播放音频按钮
- (UIButton *)isCreatePlayBtnByMp3Url:(NSString *)mp3Url withFrame:(CGRect)frame playImage:(NSString *)playImage
{
    if (![mp3Url isEqualToString:@""]&&mp3Url.length!=0) {
        UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        playBtn.frame = frame;
        [playBtn setImage:[UIImage imageNamed:playImage] forState:UIControlStateNormal];
        self.playMp3Url = mp3Url;
        [playBtn addTarget:self action:@selector(clickToPlayMp3:) forControlEvents:UIControlEventTouchUpInside];
        return playBtn;
    }
    return nil;
}
- (void)clickToPlayMp3:(UIButton *)button
{
    [self playMp3ByString:self.playMp3Url];
}
- (void)playMp3ByString:(NSString *)mp3String
{
    if (_player) {
        _player = nil;
    }
    if (![mp3String isEqualToString:@""]&&mp3String.length!=0) {
        NSURL *mp3Url = [NSURL URLWithString:mp3String];
        _player = [[AVPlayer alloc]initWithURL:mp3Url];
        [_player play];
    }
}
#pragma mark - 创建并返回UILabel
- (UILabel *)tipLabelWithFrame:(CGRect)frame labelText:(NSString *)text
{
    UILabel *tipLabel = [[UILabel alloc]initWithFrame:frame];
    tipLabel.numberOfLines = 0;
    tipLabel.text = text;
    return tipLabel;
}
- (void)setAttributedTextForLabel:(UILabel *)label withTextString:(NSString *)textString textColor:(UIColor *)textColor font:(UIFont *)font
{
    NSDictionary *dict = @{NSForegroundColorAttributeName:textColor,NSFontAttributeName:font};
    NSAttributedString *attrs = [[NSAttributedString alloc]initWithString:textString attributes:dict];
    label.textAlignment = NSTextAlignmentCenter;
    [label setAttributedText:attrs];
}
#pragma mark - 卡片 点击切换图片，播放声音
- (void)rotateToShowBackgroundImage:(UITapGestureRecognizer *)tap
{
    self.tapCount++;
    UIImageView *imageView = (UIImageView *)tap.view;
    NSInteger tag = imageView.tag;
    NSArray *cardArray = self.cardDict[@(tag)];
    NSInteger index = (self.tapCount%2==1?cardArray.count - 1:0);
    [imageView setImageWithURL:[NSURL URLWithString:cardArray[index]]];
    CATransition *transition = [CATransition animation];
    //设置翻页样式
    transition.type = @"oglFlip";
    //设置翻转的方向
    transition.subtype = (self.tapCount%2==1?kCATransitionFromRight:kCATransitionFromLeft);
    transition.duration = 1;
    //设置动画效果的速度，开始结束缓慢，中间快速
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [imageView.layer addAnimation:transition forKey:nil];
    if (self.tapCount%2==0) {
        [self performSelector:@selector(initMp3PlayerWithArray:) withObject:cardArray afterDelay:1.0];
    }
}
#pragma mark - 请求网络数据
- (void)requestDataWithSenceid:(NSString *)senceid completionHandler:(void(^)(NSMutableDictionary *cardDict,NSArray *exerciseArray))handler
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //拼接URL路径
    NSString *url = [NSString stringWithFormat:KUnitDetailString,senceid];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *rootArray = responseObject;
        for (int i = 0; i<rootArray.count; i++) {
            NSDictionary *dict = rootArray[i];
            NSArray *array = dict[@"content"];
            NSDictionary *contentDict = [array firstObject];
            NSString *content = contentDict[@"content"];
            NSDictionary *dataDict = [NSDictionary dictionary];
            if ([content containsString:@"\"type\":\"card\""]) {//卡片
                dataDict = [self cutOffString:content WithSign:@"uniqueID"];
                NSArray *arr = dataDict[@"testObj"];//卡片数组
                for (int j=0; j<arr.count; j++) {
                    NSArray *cardArr = [NSArray array];
                    NSDictionary *cardDict = arr[j];
                    
                    NSString *backImg = [self getUrlWithDict:cardDict relyOn:@"back" returnUrlKey:@"imgUrl"];
                    NSString *frontImg = [self getUrlWithDict:cardDict relyOn:@"front" returnUrlKey:@"imgUrl"];
                    NSDictionary *frontDict = cardDict[@"front"];
                    NSString *frontMp3 = [self getUrlWithDict:frontDict relyOn:@"audio" returnUrlKey:@"url"];
                    cardArr = @[frontImg,frontMp3,backImg];
                    [self.cardDict setObject:cardArr forKey:@(j)];
                }
            }else if ([content containsString:@"\"type\":\"objective\""]){//题目
                dataDict = [self cutOffString:content WithSign:@"type"];
                NSArray *dataArr = dataDict[@"data"];
                NSArray *modelArray = [NDSelectModel arrayOfModelsFromDictionaries:dataArr];
                for (NDSelectModel *model in modelArray) {
                    NSMutableDictionary *exerciseDict = [NSMutableDictionary dictionary];
                    NSString *type = model.type;
                    id exercise = [model parseDataByType:type];
                    if (exercise==nil) {
                        continue;
                    }
                    if ([type isEqualToString:@"simple_choose"]) {
                        NDChooseModel *choose = exercise;
                        [exerciseDict setObject:choose forKey:type];
                    } else if ([type isEqualToString:@"img_matching"]){
                        NDMatchModel *match = exercise;
                        [exerciseDict setObject:match forKey:type];
                    }
                    [self.exerciseArray addObject:exerciseDict];
                }
            }
        }
        handler(self.cardDict,self.exerciseArray);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"网络请求失败提示信息" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self dismissViewControllerAnimated:alert completion:nil];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}
- (NSString *)getUrlWithDict:(NSDictionary *)dict relyOn:(NSString *)newDictName returnUrlKey:(NSString *)urlKey
{
    NSDictionary *newDict = dict[newDictName];
    NSString *urlString = [NSString stringWithFormat:PrefixForUrl,newDict[urlKey]];
    return urlString;
}
//根据题目类型截取字符串，返回一个字典
- (NSDictionary *)cutOffString:(NSString *)string WithSign:(NSString *)sign
{
    NSDictionary *dict = [NSDictionary dictionary];
    NSRange headrange = [string rangeOfString:sign];
    if (headrange.location!=NSNotFound) {
        NSInteger fromIndex = headrange.location - 2;
        NSRange endRange = [string rangeOfString:@"/div"];
        NSInteger toIndex = endRange.location - 1;
        NSInteger length = toIndex - fromIndex;
        NSRange range = NSMakeRange(fromIndex, length);
        NSString *subString = [string substringWithRange:range];
        NSData *data = [subString dataUsingEncoding:NSUTF8StringEncoding];
        dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    }
    return dict;
}
#pragma mark - UIScrollViewDelegate代理方法
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag==BaseScrollViewTag) {
        // 当前滚动到第几张图片
        int index = scrollView.contentOffset.x/KScreenWidth;
        //滚动之后如果还在当前页，则不播放音乐
        if (self.currentPage==index) {
            return;
        }else
        {
            self.currentPage = index;
        }
        [_pageLabel setText:[NSString stringWithFormat:@"%d / %ld",index+1,self.cardDict.count]];
        _cardPageView.hidden = index==self.cardDict.count;
        NSArray *mp3Array = self.cardDict[@(index)];
        [self initMp3PlayerWithArray:mp3Array];
    }else if (scrollView.tag==ResultScrollViewTag){
        CGFloat width = KScreenWidth-2*LimitViewX;
        int index = scrollView.contentOffset.x/width;
        NSString *currentMp3Url = [self.answerMp3Dict objectForKey:@(index)];
        if (![currentMp3Url isEqualToString:@"0"]&&![currentMp3Url isEqualToString:@""]) {
            self.playMp3Url = currentMp3Url;
        }
    }
}
- (void)initMp3PlayerWithArray:(NSArray *)mp3Array
{
    NSURL *mp3Url = [NSURL URLWithString:mp3Array[1]];
    _player = [[AVPlayer alloc]initWithURL:mp3Url];
    [_player play];
}
#pragma mark - 控制器销毁时释放内存
- (void)dealloc
{
    if (_cardPageView) {
        [_cardPageView removeFromSuperview];//移除card页面的页数控件
    }
    [self.baseImgArray removeAllObjects];
    [self.baseFrameArray removeAllObjects];
    [self.baseIsEmptyIndexes removeAllObjects];
    
    [self.matchImgArray removeAllObjects];
    [self.matchFrameArray removeAllObjects];
    [self.matchTransIndexes removeAllObjects];
    [self.matchLineDict removeAllObjects];
    
    [self.cardDict removeAllObjects];
    [self.exerciseArray removeAllObjects];
    
    [self.answerArray removeAllObjects];
    [self.answerMp3Dict removeAllObjects];
    self.currentLineDict = nil;
    
    [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _scrollView = nil;
    _player = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
