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

@interface NDMeController ()<UITableViewDataSource,UITableViewDelegate>

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
        UserModel *model = [[UserModel alloc]init];
        model.image = [UIImage imageNamed:@"placeHolderImage"];
        model.phone = @"18930422589";
        model.nickName = @"未登录";
        _model = model;
    }
    return _model;
}
- (void)prepareData
{
    NSArray *textArray1 = @[@"",@"已下载课程",@"已购课程"];
    NSArray *textArray2 = @[@"设置"];
    self.nameArray = @[textArray1,textArray2];
    NSArray *imgArray1 = @[@"",@"download_60X60",@"purchased_60X60"];
    NSArray *imgArray2 = @[@"setting_60X60"];
    self.iconArray = @[imgArray1,imgArray2];
}
- (void)createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage createImageWithColor:Color(234, 103, 37)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage createImageWithColor:[UIColor clearColor]]];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) style:UITableViewStyleGrouped];
    _tableView.scrollEnabled = NO;
    _tableView.contentInset = UIEdgeInsetsMake(-17, 0, 0, 0);
    
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
    if (indexPath.section==0&&indexPath.row==0) {
        NDMeInfoController *meInfoVc = [[NDMeInfoController alloc]init];
        meInfoVc.user = self.model;
        meInfoVc.title = @"我的信息";
        meInfoVc.showUserBlock = ^(UserModel *model){
            self.model = model;
            [self.tableView reloadData];
//            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        };
        [self.navigationController pushViewController:meInfoVc animated:YES];
    }else if (indexPath.section==1)
    {
        NDSettingController *settingVc = [[NDSettingController alloc]init];
        settingVc.title = self.nameArray[indexPath.section][indexPath.row];
        [self.navigationController pushViewController:settingVc animated:YES];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0&&indexPath.row==0) {
        return 160;
    }
    return 60;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 16;
}

@end