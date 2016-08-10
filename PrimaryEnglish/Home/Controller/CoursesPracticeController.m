//
//  VocabularyPracticeController.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/28.
//  Copyright © 2016年 Nic. All rights reserved.
//

#define DataSavePath @"/Users/tangzhaoning/词汇练习数据/%@-%@.plist"
#define ScaleValue KScreenWidth/375
#define Padding 20*ScaleValue
#define PaddingX 20*ScaleValue
#define ProgressLabelW 40*ScaleValue
#define PlayBtnWH 30*ScaleValue
#define ChoiceLabelH 3*PaddingX
#define NextBtnH 40*ScaleValue

#define MatchPaddingX 3*Padding
#define MatchPaddingY 10*ScaleValue

#define BaseImgW (KScreenWidth-3*MatchPaddingX)*7/13
#define BaseImgH BaseImgW*255/300

#define MatchImgW (KScreenWidth-3*MatchPaddingX)*6/13
#define MatchImgH MatchImgW*255/300

#import "CoursesPracticeController.h"
#import "AFHTTPSessionManager.h"//网络请求
#import "UIImageView+AFNetworking.h"//显示网络图片
#import "RDVTabBarController.h"
#import "NDSelectModel.h"//词汇练习所有题目模型
#import "NDChooseModel.h"//词汇练习选择题目模型
#import "NDMatchModel.h"//词汇练习图片拖拽连线模型
#import "NDFillingModel.h"//词汇练习填空题模型
#import "NDWordModel.h"//词汇练习选词成句模型
#import <AVFoundation/AVFoundation.h>//音频播放

@interface CoursesPracticeController ()<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    UIView *_exerciseView;
    UIProgressView *_progressView;
    AVPlayer *_player;
    NSTimer *_timer;
}
@property (nonatomic,strong) NSMutableDictionary *cardDict;
@property (nonatomic,strong) NSMutableArray *exerciseArray;
//@property (nonatomic,strong) NSArray *matchingArray;
@property (nonatomic,assign) NSInteger tapCount;
@property (nonatomic,assign) NSInteger currentPage;

@property (nonatomic,strong) UIView *selectedView;

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
        NSLog(@"%ld-%ld",cardDict.count,exerciseArray.count);
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
//- (NSArray *)matchingArray
//{
//    if (!_matchingArray) {
//        _matchingArray = [NSArray array];
//    }
//    return _matchingArray;
//}
- (void)createUI
{
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64)];
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    self.view.backgroundColor = Color(234, 103, 37);
    [self.view addSubview:_scrollView];
}
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
            imageView.frame = CGRectMake(i*KScreenWidth+30, 30, KScreenWidth-60, KScreenHeight-150);
            [_scrollView addSubview:imageView];
        }
        //播放音频
        completionHandler();
    }
    _exerciseView = [self createViewWithIndex:0];
    _scrollView.contentSize = CGSizeMake(KScreenWidth*(self.cardDict.count+1), 0);
    [_scrollView addSubview:_exerciseView];
}
- (UIView *)createViewWithIndex:(NSInteger)index
{
    NSDictionary *modelDict = self.exerciseArray[index];
    NSString *type = modelDict.allKeys[0];
    
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor whiteColor];
    view.frame = CGRectMake(self.cardDict.count*KScreenWidth, 0, KScreenWidth, KScreenHeight);
    CGFloat progressW = KScreenWidth-2*PaddingX - ProgressLabelW;
    _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(PaddingX, 1.5*Padding, progressW, 30)];
    _progressView.transform = CGAffineTransformMakeScale(1.0f, 4.0f);
    _progressView.contentMode = UIViewContentModeScaleAspectFill;
    _progressView.layer.cornerRadius = 3.5;
    _progressView.layer.masksToBounds = YES;
    _progressView.trackTintColor = Color(230, 230, 230);
    _progressView.progressTintColor = Color(92, 219, 85);
    _progressView.progress = (index+1)*1.0/self.exerciseArray.count;
    [view addSubview:_progressView];
    
    CGFloat labelX = CGRectGetMaxX(_progressView.frame);
    UILabel *progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(labelX, Padding, ProgressLabelW, 20)];
    
    NSString *textStr = [NSString stringWithFormat:@"%ld/%ld",(index+1),self.exerciseArray.count];
    [self setAttributedTextForLabel:progressLabel withTextString:textStr textColor:Color(168, 168, 168) font:[UIFont boldSystemFontOfSize:13]];
    [view addSubview:progressLabel];    
    
    CGFloat textX = PaddingX;
    CGFloat textY = CGRectGetMaxY(_progressView.frame) + Padding;
    CGRect playBtnFrame = CGRectMake(PaddingX, textY, PlayBtnWH, PlayBtnWH);
    if ([type isEqualToString:@"simple_choose"]) {
        NDChooseModel *choose = modelDict[type];
        UIButton *playBtn = [self isCreatePlayBtnByMp3Url:choose.mp3Url withFrame:playBtnFrame playImage:@"playMp340" pauseImage:nil];
        if (playBtn!=nil) {
            
            NSURL *mp3Url = [NSURL URLWithString:choose.mp3Url];
            AVPlayer *player = [AVPlayer playerWithURL:mp3Url];
            [player play];
            
            textX += PlayBtnWH + 5;
            [view addSubview:playBtn];
        }
        CGFloat textW = KScreenWidth - textX - PaddingX;
        UILabel *tipLabel = [self tipLabelWithFrame:CGRectMake(textX, textY, textW, PlayBtnWH) labelText:choose.tipLabelText];
        [view addSubview:tipLabel];
        
        CGFloat chooseY = CGRectGetMaxY(tipLabel.frame) + Padding;
        if (choose.isPic) {
            int columns = 2;
            CGFloat imgViewWH = (KScreenWidth - (columns+1)*PaddingX)/columns;
            for (int i = 0; i<choose.imageArray.count; i++) {
                UIImageView *imageView = [[UIImageView alloc]init];
                imageView.tag = choose.trueAnswerIndex+i;
                CGFloat imageY = chooseY +i/columns*(imgViewWH + Padding);
                imageView.frame = CGRectMake(i%columns*(PaddingX+imgViewWH)+PaddingX, imageY, imgViewWH, imgViewWH);
                NSURL *url = [NSURL URLWithString:choose.imageArray[i]];
                [imageView setImageWithURL:url];
                imageView.layer.borderWidth = 2;
                imageView.layer.borderColor = Color(168, 168, 168).CGColor;
                imageView.backgroundColor = Color(245, 245, 245);
                
                CGPoint center = CGPointMake(imgViewWH, imgViewWH);
                UIView *colorView = [[UIView alloc]init];
                colorView.bounds = CGRectMake(0, 0, 40, 40);
                colorView.backgroundColor = Color(92, 219, 85);
                colorView.center = center;
                colorView.transform = CGAffineTransformMakeRotation(M_PI_4);
                colorView.hidden = YES;
                imageView.clipsToBounds = YES;
                [imageView addSubview:colorView];
                
                imageView.userInteractionEnabled = YES;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToSelectView:)];
                [imageView addGestureRecognizer:tap];
                [view addSubview:imageView];
            }
        }else
        {
            for (int j = 0; j<choose.textArray.count; j++) {
                UILabel *choiceLabel = [[UILabel alloc]initWithFrame:CGRectMake(PaddingX, chooseY+j*(ChoiceLabelH+Padding), KScreenWidth-2*PaddingX, ChoiceLabelH)];
                [self setAttributedTextForLabel:choiceLabel withTextString:choose.textArray[j] textColor:[UIColor whiteColor] font:[UIFont boldSystemFontOfSize:18]];
                choiceLabel.backgroundColor = Color(168, 168, 168);
                choiceLabel.tag = choose.trueAnswerIndex + j;
                
                choiceLabel.userInteractionEnabled = YES;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToSelectView:)];
                [choiceLabel addGestureRecognizer:tap];
                [view addSubview:choiceLabel];
            }
        }
    } else if ([type isEqualToString:@"img_matching"]){
        NDMatchModel *match = modelDict[type];
        UIButton *playBtn = [self isCreatePlayBtnByMp3Url:match.mp3Url withFrame:playBtnFrame playImage:@"playMp340" pauseImage:nil];
        if (playBtn!=nil) {
            textX += PlayBtnWH + 5;
            [view addSubview:playBtn];
        }
        CGFloat textW = KScreenWidth - textX - PaddingX;
        UILabel *tipLabel = [self tipLabelWithFrame:CGRectMake(textX, textY, textW, PlayBtnWH) labelText:match.tipLabelText];
        [view addSubview:tipLabel];
        CGFloat chooseY = CGRectGetMaxY(tipLabel.frame) + Padding;
        for (int m = 0; m<match.baseImgArr.count; m++) {
            UIImageView *baseImageView = [[UIImageView alloc]initWithFrame:CGRectMake(MatchPaddingX, chooseY+m*(BaseImgH+MatchPaddingY), BaseImgW, BaseImgH)];
            baseImageView.layer.borderWidth = 3;
            NSURL *baseImgUrl = [NSURL URLWithString:match.baseImgArr[m]];
            [baseImageView setImageWithURL:baseImgUrl];
            [view addSubview:baseImageView];
            
            UIView *matchView = [[UIView alloc]init];
            matchView.backgroundColor = [UIColor whiteColor];
            matchView.bounds = CGRectMake(0, 0, MatchImgW, MatchImgH);
            CGFloat centerX = baseImageView.center.x + (BaseImgW+MatchImgW)/2 + MatchPaddingX;
            matchView.center = CGPointMake(centerX, baseImageView.center.y);
            matchView.layer.borderWidth = 3;
            matchView.layer.shadowColor = Color(234, 103, 37).CGColor;
            UIImageView *matchImageView = [[UIImageView alloc]initWithFrame:matchView.bounds];
            NSURL *matchImgUrl = [NSURL URLWithString:match.matchImgArr[m]];
            [matchImageView setImageWithURL:matchImgUrl];
            [matchView addSubview:matchImageView];
            [view addSubview:matchView];
        }
        
    }
//    else if ([type isEqualToString:@"filling"]){
////        NDFillingModel *filling = modelDict[type];
//        
//    }else if ([type isEqualToString:@"word_matching"]){
////        NDWordModel *word = modelDict[type];
//        
//    }
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat nextBtnY = KScreenHeight - NextBtnH - 64 - Padding;
    nextBtn.frame = CGRectMake(PaddingX, nextBtnY, KScreenWidth-2*PaddingX, NextBtnH);
    nextBtn.tag = index;
    NSString *titleStr = (index==self.exerciseArray.count-1)?@"提交":@"下一题";
    [nextBtn setTitle:titleStr forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextViewForExercise:) forControlEvents:UIControlEventTouchUpInside];
    [nextBtn setBackgroundColor:Color(234, 103, 37)];
    nextBtn.layer.cornerRadius = 5;
    [view addSubview:nextBtn];
    return view;
}
- (void)tapToSelectView:(UITapGestureRecognizer *)tapGesture
{
    if (self.selectedView==nil) {
        self.selectedView = [[UIView alloc]init];
    }
    BOOL isChanged = NO;
    UIView *view = tapGesture.view;
//    NSInteger index = view.tag;
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
    self.selectedView = view;
}
- (void)nextViewForExercise:(UIButton *)nextBtn
{
    [_exerciseView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_exerciseView removeFromSuperview];
    _exerciseView = nil;
    NSInteger nextIndex = nextBtn.tag+1;
    if (nextIndex<self.exerciseArray.count) {
        _exerciseView = [self createViewWithIndex:nextIndex];
    }else if (nextIndex==self.exerciseArray.count)
    {
        UIView *resultView = [[UIView alloc]initWithFrame:CGRectMake(self.cardDict.count*KScreenWidth+10, 10, KScreenWidth/2, KScreenHeight/2)];
        resultView.backgroundColor = [UIColor blueColor];
        _exerciseView = resultView;
    }
    [_scrollView addSubview:_exerciseView];
}
- (UIButton *)isCreatePlayBtnByMp3Url:(NSString *)mp3Url withFrame:(CGRect)frame playImage:(NSString *)playImage pauseImage:(NSString *)pauseImage
{
    if (![mp3Url isEqualToString:@""]&&mp3Url.length!=0) {
        UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        playBtn.frame = frame;
        [playBtn setImage:[UIImage imageNamed:playImage] forState:UIControlStateNormal];
        [playBtn addTarget:self action:@selector(playMp3:) forControlEvents:UIControlEventTouchUpInside];
        return playBtn;
    }
    return nil;
}
- (UILabel *)tipLabelWithFrame:(CGRect)frame labelText:(NSString *)text
{
    UILabel *tipLabel = [[UILabel alloc]initWithFrame:frame];
    [tipLabel setFont:[UIFont systemFontOfSize:16*ScaleValue]];
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
- (void)rotateToShowBackgroundImage:(UITapGestureRecognizer *)tap
{
    self.tapCount++;
    UIImageView *imageView = (UIImageView *)tap.view;
    NSInteger tag = imageView.tag;
    NSArray *cardArray = self.cardDict[@(tag)];
    NSInteger index = (self.tapCount%2==1?cardArray.count - 1:0);
    [imageView setImageWithURL:[NSURL URLWithString:cardArray[index]]];
    CATransition *transition = [CATransition animation];
    //设置样式
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
            if ([content containsString:@"card"]) {//卡片
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
            }else if ([content containsString:@"objective"]){//题目
                dataDict = [self cutOffString:content WithSign:@"type"];
                NSArray *dataArr = dataDict[@"data"];
                [dataArr writeToFile:[NSString stringWithFormat:DataSavePath,@"dataArr",self.title] atomically:YES];
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
//                    else if ([type isEqualToString:@"filling"]){
//                        NDFillingModel *filling = exercise;
//                        [exerciseDict setObject:filling forKey:type];
//                    }else if ([type isEqualToString:@"word_matching"]){
//                        NDWordModel *word = exercise;
//                        [exerciseDict setObject:word forKey:type];
//                    }
                    [self.exerciseArray addObject:exerciseDict];
                }
            }
        }
        handler(self.cardDict,self.exerciseArray);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            NSLog(@"error:%@",error.localizedDescription);
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
{    //  当前滚动到第几张图片
    int index = scrollView.contentOffset.x/KScreenWidth;
    //滚动之后如果还在当前页，则不播放音乐
    if (self.currentPage==index) {
        return;
    }else
    {
        self.currentPage = index;
    }
    NSArray *mp3Array = self.cardDict[@(index)];
    [self initMp3PlayerWithArray:mp3Array];
}
- (void)initMp3PlayerWithArray:(NSArray *)mp3Array
{
    NSURL *mp3Url = [NSURL URLWithString:mp3Array[1]];
    _player = [[AVPlayer alloc]initWithURL:mp3Url];
    [_player play];
}

//根据count的值得到一组不重复的随机数0～n-1
- (NSArray *)getNumbersOfRandoms:(NSInteger)count
{
    NSMutableArray *array = [NSMutableArray array];
    NSMutableArray *compareArr = [NSMutableArray arrayWithObject:@(-1)];
    
    for (int i = 0; i<count; i++) {
        int random = arc4random() % count ;
        BOOL flag = YES;
        for (int j = 0; j<compareArr.count; j++) {
            if (random == [compareArr[j] intValue]) {
                flag = NO;
                i--;
                break;
            }
        }
        if (flag==YES) {
            [array addObject:@(random)];
            [compareArr addObject:@(random)];
        }
    }
    return array;
}
@end
