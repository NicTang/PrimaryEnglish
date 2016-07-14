//
//  NDCourseController.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/11.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "NDCourseController.h"
#import "AFHTTPSessionManager.h"
#import "NDCourseModel.h"
#import "NDCourseCell.h"
#import "MJRefresh.h"
#import "NDDetailController.h"
#import "RDVTabBarController.h"

@interface NDCourseController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,assign) int currentPage;

@end

@implementation NDCourseController
/**
 *  不隐藏底部tabbar
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPage = 1;
    
    [self requestData];
    [self createUI];
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (void)createUI
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = 30;
    layout.minimumInteritemSpacing = 20;
    layout.itemSize = CGSizeMake(160, 238);
    layout.sectionInset = UIEdgeInsetsMake(20, 17, 60, 17);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    //导航栏不透明，占有一定的frame
    self.navigationController.navigationBar.translucent = NO;
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    //注册cell
    [_collectionView registerNib:[UINib nibWithNibName:@"NDCourseCell" bundle:nil] forCellWithReuseIdentifier:@"courseCell"];
    [self.view addSubview:_collectionView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    //添加手势
    //设置下拉刷新（重新请求第一页数据）
    self.collectionView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        [self.dataArray removeAllObjects];
        self.currentPage ++;
        [self requestData];
    }];
    //设置上拉加载更多(请求下一页数据)
    self.collectionView.footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        self.currentPage++;
        [self requestData];
    }];
}
- (void)requestData
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSString *url = [NSString stringWithFormat:kCourseUrlString,self.currentPage];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = responseObject[@"data"];
        NSArray *array = dict[@"rlist"];
        
        [self.dataArray addObjectsFromArray:[NDCourseModel arrayOfModelsFromDictionaries:array]];
        
//        NSLog(@"count:%ld",self.dataArray.count);
        [self.collectionView reloadData];
        //！！！千万记得结束刷新
        [self.collectionView.header endRefreshing];
        [self.collectionView.footer endRefreshing];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            NSLog(@"error :%@",error.localizedDescription);
        }
    }];
}
#pragma mark - UICollectionView数据源方法UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
//设置cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NDCourseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"courseCell" forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.item];
    return cell;
}
#pragma mark - UICollectionView代理方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NDCourseModel *model = self.dataArray[indexPath.item];
    NDDetailController *detailVc= [[NDDetailController alloc]init];
    detailVc.courseID = model.pkgid;
    [self.navigationController pushViewController:detailVc animated:YES];
}
@end
