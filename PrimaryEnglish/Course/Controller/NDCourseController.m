//
//  NDCourseController.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/11.
//  Copyright © 2016年 Nic. All rights reserved.
//

#define LineSpacing 30*ScaleValueY
#define ItemSpacing 20*ScaleValueX
#define ItemWidth (KScreenWidth - 3*ItemSpacing)/2
#define ItemHeight 238*ItemWidth/160

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
    layout.minimumLineSpacing = LineSpacing;
    layout.minimumInteritemSpacing = ItemSpacing;
    layout.itemSize = CGSizeMake(ItemWidth, ItemHeight);
    layout.sectionInset = UIEdgeInsetsMake(20*ScaleValueY, 20*ScaleValueX, 60*ScaleValueY, 20*ScaleValueX);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    //导航栏不透明，占有一定的frame
//    self.navigationController.navigationBar.translucent = NO;
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
        
        [self.collectionView reloadData];
        //！！！千万记得结束刷新
        [self.collectionView.header endRefreshing];
        [self.collectionView.footer endRefreshing];
        
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
    cell.layer.masksToBounds = YES;
    return cell;
}
#pragma mark - UICollectionView代理方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //导航栏返回按钮文字为空，在此可以统一设置
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    NDCourseModel *model = self.dataArray[indexPath.item];
    NDDetailController *detailVc= [[NDDetailController alloc]init];
    detailVc.courseID = model.pkgid;
    detailVc.title = model.title;
    [self.navigationController pushViewController:detailVc animated:YES];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(ItemWidth, ItemHeight);
}
#pragma mark - 控制器销毁时释放内存
- (void)dealloc
{
    [self.dataArray removeAllObjects];
    [self.collectionView removeFromSuperview];
    self.collectionView = nil;
}
@end
