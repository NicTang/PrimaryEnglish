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
#import "BookReaderController.h"//课本点读
#import "CoursesPracticeController.h"//词汇练习

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
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) style:UITableViewStyleGrouped];
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
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
        self.model = model;
        
        NSArray *array = responseObject[@"senceList"];
        self.cellDataArray = [NDDetailModel arrayOfModelsFromDictionaries:array];
        //刷新cell
        [self.tableView reloadData];
        
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
    NDDetailModel *detailModel = self.cellDataArray[indexPath.row];
    NSInteger selIndex = indexPath.row;
    //导航栏返回按钮文字为空
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    if ([self.title containsString:@"课本点读"]) {
        BookReaderController *readerVc = [[BookReaderController alloc]init];
        readerVc.selectIndex = indexPath.row;
        //当前书本的所有信息数组
        readerVc.unitsArray = self.cellDataArray;
        //接收请求单元详细数据的参数
        readerVc.senceid = detailModel.senceid;
        
        //设置导航栏标题
        readerVc.title = detailModel.title;
        readerVc.courseID = self.courseID;
        readerVc.courseName = self.title;
        [self.navigationController pushViewController:readerVc animated:YES];
    }else if([self.title containsString:@"词汇练习"]||[self.title containsString:@"配套练习"])
    {
        CoursesPracticeController *practiceVc = [[CoursesPracticeController alloc]init];
        practiceVc.title = detailModel.title;
        //请求单元详情的参数
        practiceVc.senceid = detailModel.senceid;
        practiceVc.courseID = self.courseID;
        [self.navigationController pushViewController:practiceVc animated:YES];
    }
    if (self.learningDetailBlock) {
        self.learningDetailBlock(detailModel,self.title,selIndex,self.cellDataArray,self.courseID);
    }
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
    return 220*ScaleValueY;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120*ScaleValueY;
}
#pragma mark - 控制器销毁时释放内存
- (void)dealloc
{
    [self.tableView removeFromSuperview];
    self.tableView = nil;
    [self.cellDataArray removeAllObjects];
}
@end
