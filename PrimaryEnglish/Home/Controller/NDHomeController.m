//
//  NDHomeController.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/11.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "NDHomeController.h"
#import "NDHomeModel.h"
#import "NDHomeCell.h"
#import "TextView.h"
#import "AFHTTPSessionManager.h"
#import "NDDetailController.h"
#import "RDVTabBarController.h"

@interface NDHomeController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@end

@implementation NDHomeController
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
    [self createUI];
    [self requestData];
    self.view.backgroundColor = [UIColor whiteColor];
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
    layout.minimumLineSpacing = 20;
    layout.minimumInteritemSpacing = 20;
    layout.itemSize = CGSizeMake(100, 169);
    layout.sectionInset = UIEdgeInsetsMake(0, 17, 60, 17);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
//    self.navigationController.navigationBar.translucent = NO;
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    //注册cell
    [_collectionView registerNib:[UINib nibWithNibName:@"NDHomeCell" bundle:nil] forCellWithReuseIdentifier:@"homeCell"];
    //注册头部视图
    [_collectionView registerClass:[TextView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerView"];
    [self.view addSubview:_collectionView];
//    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)requestData
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:KHomeUrlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *bigArray = responseObject[2];
        for (NSArray *array in bigArray) {
            NDHomeModel *model = [NDHomeModel homeWithArray:array];
            [self.dataArray addObject:model];
        }
        [self.collectionView reloadData];
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
    NDHomeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"homeCell" forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.item];
    return cell;
}
//设置头部视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;
{
    UICollectionReusableView *reusableView = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        TextView *textView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerView" forIndexPath:indexPath];
        reusableView = textView;
    }
    return reusableView;
}
#pragma mark - UICollectionView代理方法UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NDHomeModel *model = self.dataArray[indexPath.item];
    NDDetailController *detailVc= [[NDDetailController alloc]init];
    detailVc.courseID = model.homeID;
    [self.navigationController pushViewController:detailVc animated:YES];
}
#pragma mark - UICollectionViewDelegateFlowLayout代理方法
//设置头部视图的size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize size = CGSizeMake(KScreenWidth, 40);
    return size;
}
@end
