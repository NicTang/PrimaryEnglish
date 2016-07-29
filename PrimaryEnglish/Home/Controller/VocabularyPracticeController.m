//
//  VocabularyPracticeController.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/28.
//  Copyright © 2016年 Nic. All rights reserved.
//

#define DataSavePath @"/Users/tangzhaoning/词汇练习数据/%@.plist"
#import "VocabularyPracticeController.h"
#import "AFHTTPSessionManager.h"//网络请求
#import "UIImageView+AFNetworking.h"//显示网络图片
#import "NDSelectModel.h"//词汇练习选择题模型
#import "NDMatchModel.h"//词汇练习图片拖拽连线模型
#import "NDFillingModel.h"

@interface VocabularyPracticeController ()<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    UIView *_selectView;
}
@end

@implementation VocabularyPracticeController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self createUI];
    [self requestDataWithSenceid:self.senceid];
}

- (void)createUI
{
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64)];
    _scrollView.delegate = self;
    self.view.backgroundColor = Color(234, 103, 37);
    [self.view addSubview:_scrollView];
}
- (UIView *)createViewWithType:(NSString *)type
{
    return nil;
}
- (void)requestDataWithSenceid:(NSString *)senceid
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //拼接URL路径
    NSString *url = [NSString stringWithFormat:KUnitDetailString,senceid];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *rootArray = responseObject;
//        [rootArray writeToFile:[NSString stringWithFormat:DataSavePath,self.senceid] atomically:YES];
        
        for (int i = 0; i<rootArray.count; i++) {
            NSDictionary *dict = rootArray[i];
            NSArray *array = dict[@"content"];
            NSDictionary *contentDict = [array firstObject];
            NSString *content = contentDict[@"content"];
            
            NSDictionary *dataDict = [NSDictionary dictionary];
            if (i==0) {//卡片
                dataDict = [self cutOffString:content WithSign:@"uniqueID"];
                NSArray *arr = dataDict[@"testObj"];
                for (int j=0; j<arr.count; j++) {
                    NSArray *cardArr = [NSArray array];
                    NSDictionary *cardDict = arr[j];
                    
                    NSString *backImg = [self getUrlWithDict:cardDict relyOn:@"back" returnUrlKey:@"imgUrl"];
                    NSString *frontImg = [self getUrlWithDict:cardDict relyOn:@"front" returnUrlKey:@"imgUrl"];
                    NSDictionary *frontDict = cardDict[@"front"];
                    NSString *frontMp3 = [self getUrlWithDict:frontDict relyOn:@"audio" returnUrlKey:@"url"];
                    cardArr = @[backImg,frontImg,frontMp3];
                    NSLog(@"cardArr:%@",cardArr);
                }
                NSLog(@"card-arr:%ld",arr.count);
            }else if (i==rootArray.count-1){//题目
                dataDict = [self cutOffString:content WithSign:@"type"];
                NSArray *dataArr = dataDict[@"data"];
                [dataArr writeToFile:[NSString stringWithFormat:DataSavePath,self.title] atomically:YES];
//                NSLog(@"obj-arr:%ld-%@",dataArr.count,dataArr);
                
                NSMutableArray *chooseArr = [NSMutableArray array];
                NSMutableArray *matchingArr = [NSMutableArray array];
                NSMutableArray *fillingArr = [NSMutableArray array];
                
                for (NSDictionary *dataArrDict in dataArr) {
                    NSString *type = dataArrDict[@"type"];
                    if ([type isEqualToString:@"simple_choose"]) {
                        [chooseArr addObject:dataArrDict];
                    } else if ([type isEqualToString:@"img_matching"]) {
                        [matchingArr addObject:dataArrDict];
                    }else if ([type isEqualToString:@"filling"]) {
                        [fillingArr addObject:dataArrDict];
                    }
                }
                NSArray *chooseArray = [NDSelectModel arrayOfModelsFromDictionaries:chooseArr];
//                NSLog(@"obj-chooseArray:%ld",chooseArray.count);
//                NSLog(@"obj-chooseArray:%ld-%@",chooseArray.count,chooseArray);
                
                NSArray *matchArray = [NDMatchModel arrayOfModelsFromDictionaries:matchingArr];
//                NSLog(@"obj-matchArray:%ld",matchArray.count);
//                NSLog(@"obj-matchArray:%ld-%@",matchArray.count,matchArray);
                
                NSArray *fillingArray = [NDFillingModel arrayOfModelsFromDictionaries:fillingArr];
//                NSLog(@"obj-fillingArray:%ld",fillingArray.count);
//                NSLog(@"obj-fillingArray:%ld-%@",fillingArray.count,fillingArray);
            }
        }
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
@end
