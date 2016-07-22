//
//  NDDetailController.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/11.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "NDDetailController.h"
#import "RDVTabBarController.h"
#import "AFHTTPSessionManager.h"//发送网络请求
#import "NDInfoModel.h"
#import "NDDetailModel.h"
#import "NDDetailCell.h"
#import "DetailHeaderView.h"
#import "UIImage+NewImage.h"
#import "UnitDetailController.h"

@interface NDDetailController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NDInfoModel *model;
@property (nonatomic,strong) NSMutableArray *cellDataArray;
@end

@implementation NDDetailController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
//    self.automaticallyAdjustsScrollViewInsets = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestData];
    [self createUI];
    
}
- (NSMutableArray *)cellDataArray
{
    if (!_cellDataArray) {
        _cellDataArray = [NSMutableArray array];
    }
    return _cellDataArray;
}
- (void)createUI
{
//    self.navigationController.navigationBar.translucent = YES;//?
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage createImageWithColor:Color(234, 103, 37)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage createImageWithColor:[UIColor clearColor]]];
    
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    [_tableView registerNib:[UINib nibWithNibName:@"NDDetailCell" bundle:nil] forCellReuseIdentifier:@"detailCell"];
}

- (void)requestData
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //POST请求
    NSDictionary *dict = @{@"id":self.courseID};
    [manager POST:KCourseDetailUrlString parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *infoDict = responseObject[@"pkgInfo"];
        NDInfoModel *model = [[NDInfoModel alloc]init];
        [model setValuesForKeysWithDictionary:infoDict];
//        NSLog(@"model:%@",model);
        self.model = model;
        self.navigationItem.title = model.title;
        
        NSArray *array = responseObject[@"senceList"];
        self.cellDataArray = [NDDetailModel arrayOfModelsFromDictionaries:array];
        //刷新cell
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            NSLog(@"error :%@",error.localizedDescription);
        }
    }];
}
#pragma mark - UITableViewDataSource数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cellDataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NDDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell" forIndexPath:indexPath];
    cell.model = self.cellDataArray[indexPath.row];
    
    return cell;
}
#pragma mark - UITableViewDelegate代理方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UnitDetailController *unitVc = [[UnitDetailController alloc]init];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    //传递参数
    unitVc.senceid = [self.cellDataArray[indexPath.row] senceid];
    //设置导航栏标题
    unitVc.title = [self.cellDataArray[indexPath.row] title];
    [self.navigationController pushViewController:unitVc animated:YES];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    DetailHeaderView *headerView = [[DetailHeaderView alloc]init];
    headerView.backgroundColor = Color(234, 103, 37);
    headerView.model = self.model;
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 220;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}
@end
