//
//  NDMeController.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/11.
//  Copyright © 2016年 Nic. All rights reserved.
//
#import "NDMeController.h"
#import "UserModel.h"
#import "NDHeaderCell.h"
#import "UIImage+NewImage.h"
#import "NDMeInfoController.h"
#import "RDVTabBarController.h"
#import "NDSettingController.h"

@interface NDMeController ()<UITableViewDataSource,UITableViewDelegate,SettingControllerDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray *iconArray;
@property (nonatomic,strong) NSArray *nameArray;
@end

@implementation NDMeController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareData];
    [self createUI];
}
- (UserModel *)model
{
    if (_model==nil) {
        _model = [NSKeyedUnarchiver unarchiveObjectWithFile:NDModelSavePath];
        if (_model==nil||_model.status==1) {
            _model = [[UserModel alloc]init];
            _model.image = [UIImage imageNamed:@"placeHolderImage"];
            _model.nickName = @"未登录";
            _model.status = 1;
        }
    }
    return _model;
}
- (void)prepareData
{
    NSArray *textArray1 = @[@"",@"已下载课程",@"已购课程"];
    NSArray *textArray2 = @[@"设置"];
    self.nameArray = @[textArray1,textArray2];
    NSArray *imgArray1 = @[@"",@"download",@"purchased"];
    NSArray *imgArray2 = @[@"setting"];
    self.iconArray = @[imgArray1,imgArray2];
    
}
- (void)createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) style:UITableViewStyleGrouped];
    _tableView.scrollEnabled = NO;
    _tableView.contentInset = UIEdgeInsetsMake(-17*ScaleValueY, 0, 30*ScaleValueY, 0);
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [_tableView registerNib:[UINib nibWithNibName:@"NDHeaderCell" bundle:nil] forCellReuseIdentifier:@"headerCell"];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.nameArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.nameArray[section] count];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section==0&&indexPath.row==0) {
        NDHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"headerCell" forIndexPath:indexPath];
        cell.model = self.model;
        return cell;
    }
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.imageView.image = [UIImage imageNamed:self.iconArray[indexPath.section][indexPath.row]];
    cell.textLabel.text = self.nameArray[indexPath.section][indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //未登录
    if (self.model.status) {
        
        NDLoginController *login = [[NDLoginController alloc]init];
        login.userLoginModel = self.model;
        
        login.userLoginBlock = ^(UserModel *loginModel){
            self.model = loginModel;
            [self.tableView reloadData];
            // 存储数据
            [NSKeyedArchiver archiveRootObject:self.model toFile:NDModelSavePath];
        };
        [self presentViewController:login animated:YES completion:nil];
    }else
    {
        if (indexPath.section==0) {
            if (indexPath.row==0) {
                NDMeInfoController *meInfoVc = [[NDMeInfoController alloc]init];
                meInfoVc.user = self.model;
                meInfoVc.title = @"我的信息";
                meInfoVc.showUserBlock = ^(UserModel *model){
                    self.model = model;
                    [self.tableView reloadData];
                    // 存储数据
                    [NSKeyedArchiver archiveRootObject:self.model toFile:NDModelSavePath];
                };
                [self.navigationController pushViewController:meInfoVc animated:YES];
            }else if (indexPath.row==1){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"已下载课程提示信息" message:@"暂时还不支持离线，后续版本可能会加入该功能，敬请期待！" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self dismissViewControllerAnimated:alert completion:nil];
                }]];
                [self presentViewController:alert animated:YES completion:nil];
            }else if (indexPath.row==2){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"已购课程提示信息" message:@"暂无购买，本阶段所有课程免费试学，赶快来体验吧😊！" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self dismissViewControllerAnimated:alert completion:nil];
                }]];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }else if (indexPath.section==1)
        {
            NDSettingController *settingVc = [[NDSettingController alloc]init];
            //成为代理
            settingVc.delegate = self;
            settingVc.title = self.nameArray[indexPath.section][indexPath.row];
            [self.navigationController pushViewController:settingVc animated:YES];
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0&&indexPath.row==0) {
        return 160*ScaleValueX;
    }
    return 60*ScaleValueX;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 16*ScaleValueY;
}
#pragma mark - SettingControllerDelegate代理方法
- (void)settingController:(NDSettingController *)vc logout:(int)status
{
    self.model.status = status;
    [NSKeyedArchiver archiveRootObject:self.model toFile:NDModelSavePath];
//    self.model.image = [UIImage imageNamed:@"placeholderImage"];
    self.model.nickName = @"未登录";
    [self.tableView reloadData];
}
#pragma mark - 控制器销毁时释放内存
- (void)dealloc
{
    [self.tableView removeFromSuperview];
    self.iconArray = nil;
    self.nameArray = nil;
}
@end