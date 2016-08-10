//
//  NDHomeController.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/11.
//  Copyright © 2016年 Nic. All rights reserved.
//

#define learningViewH 200
#define learningLabelH 40
#define headerDefaultH 40
#define headerLearningH 240

#import "NDHomeController.h"
#import "NDHomeModel.h"
#import "NDHomeCell.h"
#import "TextView.h"
#import "AFHTTPSessionManager.h"
#import "NDDetailController.h"
#import "RDVTabBarController.h"
#import "UIImageView+AFNetworking.h"
#import "NDDetailModel.h"
#import "BookReaderController.h"
#import "CoursesPracticeController.h"

@interface NDHomeController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *dataArray;

//正在学
@property (nonatomic,strong) NDDetailModel *learningCourse;
@property (nonatomic,copy) NSString *learningTitle;
@property (nonatomic,assign) NSInteger learningSelectIndex;
@property (nonatomic,strong) NSArray *learningUnits;
@property (nonatomic,copy) NSString *learningCourseID;

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
- (NDDetailModel *)learningCourse
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *imageStr = [defaults stringForKey:@"bgImage"];
    NSString *unitStr = [defaults stringForKey:@"unitTitle"];
    NSString *senceid = [defaults stringForKey:@"senceid"];
    if (_learningCourse==nil) {
        if (imageStr!=nil&&unitStr!=nil) {
            NSLog(@"learningCourse:imageStr:%@-unitStr:%@",imageStr,unitStr);
            NDDetailModel *model = [[NDDetailModel alloc]init];
            model.cover = imageStr;
            model.title = unitStr;
            model.senceid = senceid;
            _learningCourse = model;
        }
    }else
    {
        NDDetailModel *model = [[NDDetailModel alloc]init];
        model.cover = imageStr;
        model.title = unitStr;
        model.senceid = senceid;
        _learningCourse = model;
    }
    return _learningCourse;
}
- (void)createUI
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = 20;
    layout.minimumInteritemSpacing = 20;
    layout.itemSize = CGSizeMake(100, 169);
    layout.sectionInset = UIEdgeInsetsMake(0, 17, 60, 17);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    //注册cell
    [_collectionView registerNib:[UINib nibWithNibName:@"NDHomeCell" bundle:nil] forCellWithReuseIdentifier:@"homeCell"];
    //注册头部视图
    [_collectionView registerClass:[TextView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerView"];
    [self.view addSubview:_collectionView];
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
        textView.userInteractionEnabled = NO;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToDetailUI:)];
        [textView addGestureRecognizer:tap];
        
//        NSLog(@"self.learningCourse:%@",self.learningCourse);
        
        if (self.learningCourse!=nil) {
            //创建view
            textView.model = self.learningCourse;
            //修改frame
            textView.recommendLabel.frame = CGRectMake(20, learningViewH, KScreenWidth, learningLabelH);
            //可交互
            textView.userInteractionEnabled = YES;
        }
        reusableView = textView;
    }
    return reusableView;
}
- (void)tapToDetailUI:(UITapGestureRecognizer *)tapGesture
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:NDLearningSavePath];
    self.learningTitle = dict[@"title"];
    self.learningCourseID = dict[@"courseID"];
    self.learningSelectIndex = [dict[@"selectIndex"] integerValue];
    
    NSMutableArray *unitArray = [NSMutableArray arrayWithContentsOfFile:NDUnitsSavePath];
    NSMutableArray *learningUnits = [NSMutableArray array];
    for (NSMutableDictionary *unitDict in unitArray) {
        NDDetailModel *detail = [[NDDetailModel alloc]init];
        [detail setValuesForKeysWithDictionary:unitDict];
        [learningUnits addObject:detail];
    }
    self.learningUnits = learningUnits;
    
    //导航栏返回按钮文字为空，在此可以统一设置
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    if ([self.learningTitle containsString:@"课本点读"]) {
        if (self.learningUnits.count!=0)
        {
            BookReaderController *readerVc = [[BookReaderController alloc]init];
            readerVc.selectIndex = self.learningSelectIndex;
            readerVc.unitsArray = [NSMutableArray arrayWithArray:self.learningUnits];
            readerVc.senceid = self.learningCourse.senceid;
            readerVc.title = self.learningCourse.title;
            readerVc.courseID = self.learningCourseID;
            readerVc.courseName = self.learningTitle;
//            readerVc.navigationController.navigationBar.translucent = YES;
            readerVc.learningReaderBlock = ^(NDDetailModel *model,NSString *title,NSInteger selectIndex,NSArray *unitsArray,NSString *courseID){
                [self saveLearningDataWithModel:model title:title selectIndex:selectIndex unitsArray:unitsArray courseID:courseID];
//                NSLog(@"点了课本点读的第%ld单元，有点tableView-%@--self.learningCourse:%@",selectIndex,title,self.learningCourse);
            };
            [self.navigationController pushViewController:readerVc animated:YES];
        }
    }else if([self.learningTitle containsString:@"词汇练习"]||[self.learningTitle containsString:@"配套练习"])
    {
        NDDetailController *detailVc= [[NDDetailController alloc]init];
        detailVc.courseID = self.learningCourseID;
        detailVc.title = self.learningTitle;
        detailVc.learningDetailBlock = ^(NDDetailModel *model,NSString *title,NSInteger selectIndex,NSArray *unitsArray,NSString *courseID){
            
            [self saveLearningDataWithModel:model title:title selectIndex:selectIndex unitsArray:unitsArray courseID:courseID];
        };
        [self.navigationController pushViewController:detailVc animated:YES];
    }
}
#pragma mark - UICollectionView代理方法UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NDHomeModel *model = self.dataArray[indexPath.item];
    NDDetailController *detailVc= [[NDDetailController alloc]init];
    detailVc.courseID = model.homeID;
    detailVc.title = model.name;
    detailVc.learningDetailBlock = ^(NDDetailModel *model,NSString *title,NSInteger selectIndex,NSArray *unitsArray,NSString *courseID){
        NSLog(@"点了课本点读的第%ld单元，没有点tableview-%@",selectIndex,title);
        [self saveLearningDataWithModel:model title:title selectIndex:selectIndex unitsArray:unitsArray courseID:courseID];
    };
    [self.navigationController pushViewController:detailVc animated:YES];
}
- (void)saveLearningDataWithModel:(NDDetailModel *)model title:(NSString *)title selectIndex:(NSInteger)selectIndex unitsArray:(NSArray *)unitsArray courseID:(NSString *)courseID
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:title forKey:@"title"];
    [dict setObject:@(selectIndex) forKey:@"selectIndex"];
    [dict setObject:courseID forKey:@"courseID"];
    [dict writeToFile:NDLearningSavePath atomically:YES];
    
    NSMutableArray *detailArr = [NSMutableArray array];
    for (NDDetailModel *detail in unitsArray) {
        NSMutableDictionary *detailDict = [NSMutableDictionary dictionary];
        [detailDict setObject:detail.senceid forKey:@"senceid"];
        [detailDict setObject:detail.title forKey:@"title"];
        [detailDict setObject:detail.cover forKey:@"cover"];
        [detailDict setObject:detail.free forKey:@"free"];
        [detailArr addObject:detailDict];
    }
    [detailArr writeToFile:NDUnitsSavePath atomically:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *imgStr = [NSString stringWithFormat:PrefixForUrl,model.cover];
    [defaults setValue:imgStr forKey:@"bgImage"];
    [defaults setValue:model.title forKey:@"unitTitle"];
    [defaults setValue:model.senceid forKey:@"senceid"];
//    NSLog(@"NSUserDefaults:imageStr:%@-unitStr:%@",imgStr,model.title);
    [self.collectionView reloadData];
}
#pragma mark - UICollectionViewDelegateFlowLayout代理方法
//设置头部视图的size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize size = CGSizeZero;
    if (self.learningCourse==nil) {
        size = CGSizeMake(KScreenWidth, headerDefaultH);
    }else{
        size = CGSizeMake(KScreenWidth, headerLearningH);
    }
    return size;
}
@end
