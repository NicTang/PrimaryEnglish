//
//  VocabularyPracticeController.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/28.
//  Copyright © 2016年 Nic. All rights reserved.
//

#define DataSavePath @"/Users/tangzhaoning/词汇练习数据/%@-%@.plist"
#import "VocabularyPracticeController.h"
#import "AFHTTPSessionManager.h"//网络请求
#import "UIImageView+AFNetworking.h"//显示网络图片
#import "NDSelectModel.h"//词汇练习所有题目模型
#import "NDChooseModel.h"//词汇练习选择题目模型
#import "NDMatchModel.h"//词汇练习图片拖拽连线模型
#import "NDFillingModel.h"//词汇练习填空题模型
#import <AVFoundation/AVFoundation.h>//音频播放

@interface VocabularyPracticeController ()<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    UIView *_selectView;
    AVPlayer *_player;
}
@property (nonatomic,strong) NSMutableDictionary *cardDict;
@property (nonatomic,strong) NSMutableArray *exerciseArray;
//@property (nonatomic,strong) NSArray *matchingArray;
//@property (nonatomic,strong) NSArray *fillingArray;
@property (nonatomic,assign) NSInteger tapCount;
@property (nonatomic,assign) NSInteger currentPage;
@end

@implementation VocabularyPracticeController

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
//- (NSArray *)fillingArray
//{
//    if (!_fillingArray) {
//        _fillingArray = [NSArray array];
//    }
//    return _fillingArray;
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
        CGRect frame = CGRectMake(self.cardDict.count*KScreenWidth, 0, KScreenWidth, KScreenHeight);
         UIView *view = [self createViewWithFrame:frame Type:@""];
        view.backgroundColor = [UIColor greenColor];
        _scrollView.contentSize = CGSizeMake(KScreenWidth*(self.cardDict.count+1), 0);
        [_scrollView addSubview:view];
        completionHandler();
    }
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
#pragma mark - UIScrollViewDelegate代理方法
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //  当前滚动到第几张图片
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
- (UIView *)createViewWithFrame:(CGRect)frame Type:(NSString *)type
{
    UIView *view = [[UIView alloc]init];
    view.frame = frame;
//    if ([type isEqualToString:@""]) {
//        
//    } else if ([type isEqualToString:@""]){
//        
//    }else if ([type isEqualToString:@""]){
//        
//    }
    return view;
}
- (void)requestDataWithSenceid:(NSString *)senceid completionHandler:(void(^)(NSMutableDictionary *cardDict,NSArray *exerciseArray))handler
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //拼接URL路径
    NSString *url = [NSString stringWithFormat:KUnitDetailString,senceid];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *rootArray = responseObject;
//        [rootArray writeToFile:[NSString stringWithFormat:DataSavePath,self.title] atomically:YES];
        for (int i = 0; i<rootArray.count; i++) {
            NSDictionary *dict = rootArray[i];
            NSArray *array = dict[@"content"];
            NSDictionary *contentDict = [array firstObject];
            NSString *content = contentDict[@"content"];
            
            NSDictionary *dataDict = [NSDictionary dictionary];
            if ([content containsString:@"card"]) {//卡片
//                if (i==0&&i!=rootArray.count-1) {//卡片
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
//                    [cardArr writeToFile:[NSString stringWithFormat:DataSavePath,@"cardArr",self.title] atomically:YES];
                    [self.cardDict setObject:cardArr forKey:@(j)];
                }
            }else if ([content containsString:@"objective"]){//题目
//            }else if (i==rootArray.count-1){//题目
                dataDict = [self cutOffString:content WithSign:@"type"];
                NSArray *dataArr = dataDict[@"data"];
                [dataArr writeToFile:[NSString stringWithFormat:DataSavePath,@"dataArr",self.title] atomically:YES];
//                NSLog(@"obj-arr:%ld-%@",dataArr.count,dataArr);
                
//                self.exerciseArray = [NDSelectModel arrayOfModelsFromDictionaries:dataArr];
                NSArray *modelArray = [NDSelectModel arrayOfModelsFromDictionaries:dataArr];
//                NSMutableDictionary *exerciseDict = [NSMutableDictionary dictionary];
                NSLog(@"modelArray:%ld",modelArray.count);
                for (NDSelectModel *model in modelArray) {
//                    NSDictionary *exerciseDict = [NSDictionary dictionary];
                    NSMutableDictionary *exerciseDict = [NSMutableDictionary dictionary];
                    NSString *type = model.type;
                    id exercise = [model parseDataByType:type];
                    if ([type isEqualToString:@"simple_choose"]) {
                        NDChooseModel *choose = exercise;
                        NSLog(@"choose:%@-%ld",choose,choose.trueAnswerIndex);
//                        [exerciseDict setValue:choose forKey:type];
                        [exerciseDict setObject:choose forKey:type];
                    } else if ([type isEqualToString:@"img_matching"]){
                        NDMatchModel *match = exercise;
                        NSLog(@"match:%@-%@",match,match.matchImgArr);
//                        [exerciseDict setValue:match forKey:type];
                        [exerciseDict setObject:match forKey:type];
                    }else if ([type isEqualToString:@"filling"]){
                        NDFillingModel *filling = exercise;
                        NSLog(@"filling:%@-%@",filling,filling.content);
//                        [exerciseDict setValue:filling forKey:type];
                        [exerciseDict setObject:filling forKey:type];
                    }
                    [self.exerciseArray addObject:exerciseDict];
                }
                NSLog(@"self.exerciseArray:%@",self.exerciseArray);
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
    NSString *urlString = [NSString stringWithFormat:@"http://app.ekaola.com/%@",newDict[urlKey]];
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
