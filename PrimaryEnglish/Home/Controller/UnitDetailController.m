//
//  UnitDetailController.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/21.
//  Copyright © 2016年 Nic. All rights reserved.
//
#define Path [NSString stringWithFormat:@"/Users/tangzhaoning/Desktop/简历素材/%@.plist",self.senceid]

#import "UnitDetailController.h"
#import "AFHTTPSessionManager.h"
#import "UIImageView+AFNetworking.h"

@interface UnitDetailController ()

@end

@implementation UnitDetailController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    [self requestData];
}
- (void)requestData
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //拼接URL路径
    NSString *url = [NSString stringWithFormat:KUnitDetailString,self.senceid];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray *rootArray = responseObject;
//        NSString *path = [NSString stringWithFormat:@"/Users/tangzhaoning/Desktop/简历素材/%@.plist",self.pkgid];
        [rootArray writeToFile:Path atomically:YES];
        [self parseDataFromArray:rootArray];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            NSLog(@"error:%@",error.localizedDescription);
        }
    }];
}
- (void)parseDataFromArray:(NSArray *)rootArray
{
    NSMutableArray *imgArr = [NSMutableArray array];
    NSMutableArray *mp3Arr = [NSMutableArray array];
    NSMutableArray *fileArr = [NSMutableArray array];
    
    for (NSDictionary *rootDict in rootArray) {
        NSArray *content = rootDict[@"content"];
        for (int i = 0; i<content.count; i++) {
            NSDictionary *contentDict = content[i];
            NSString *urlString = contentDict[@"content"];
            [fileArr addObject:urlString];
            NSString *url = [NSString stringWithFormat:@"/Users/tangzhaoning/plist/%@.txt",self.senceid];
            [fileArr writeToFile:url atomically:YES];
            
            if ([urlString containsString:@".jpg"]) {
                NSString *imgUrl = urlString;
                [imgArr addObject:imgUrl];
            } else if([urlString containsString:@".mp3"]){
                NSString *mp3Url = urlString;
                [mp3Arr addObject:mp3Url];
            }
        }
    }
    NSString *url = [NSString stringWithFormat:@"/Users/tangzhaoning/plist/%@.txt",self.senceid];
    [imgArr writeToFile:url atomically:YES];
    [mp3Arr writeToFile:url atomically:YES];
}
@end
