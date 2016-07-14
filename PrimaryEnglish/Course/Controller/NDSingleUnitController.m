//
//  NDSingleUnitController.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 20/7/13.
//  Copyright © 2020年 Nic. All rights reserved.
//

#import "NDSingleUnitController.h"
#import "AFHTTPSessionManager.h"

@interface NDSingleUnitController ()

@end

@implementation NDSingleUnitController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

//- (void)requestData
//{
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
//    //POST请求
////    NSDictionary *dict = @{@"id":self.courseID};
//    [manager POST:KCourseDetailUrlString parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//    
//        NSDictionary *infoDict = responseObject[@"pkgInfo"];
////        NDInfoModel *model = [[NDInfoModel alloc]init];
////        [model setValuesForKeysWithDictionary:infoDict];
//        //        NSLog(@"model:%@",model);
////        self.model = model;
////        self.navigationItem.title = model.title;
//        
//        NSArray *array = responseObject[@"senceList"];
//        self.cellDataArray = [NDDetailModel arrayOfModelsFromDictionaries:array];
//        //刷新cell
//        [self.tableView reloadData];
//        
//        //        NSLog(@"responseObject:%@",responseObject);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        if (error) {
//            NSLog(@"error :%@",error.localizedDescription);
//        }
//    }];
//}

@end
