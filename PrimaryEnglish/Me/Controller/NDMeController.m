//
//  NDMeController.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/11.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "NDMeController.h"
#import "UserModel.h"
#import "IconHeaderView.h"
#import "UIImage+ImageFromColor.h"

@interface NDMeController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray *iconArray;
@property (nonatomic,strong) NSArray *nameArray;
@end

@implementation NDMeController
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self prepareData];
    [self createUI];
}
- (void)prepareData
{
    NSArray *textArray1 = @[@"激活码",@"已下载课程",@"已购课程"];
    NSArray *textArray2 = @[@"设置"];
    self.nameArray = @[textArray1,textArray2];
    NSArray *imgArray1 = @[@"信息_icon_60X60",@"已下载_icon_60X60",@"已购_icon_60X60"];
    NSArray *imgArray2 = @[@"设置_icon_60X60"];
    self.iconArray = @[imgArray1,imgArray2];
}
- (void)createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage createImageWithColor:Color(234, 103, 37)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage createImageWithColor:[UIColor clearColor]]];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [self.view addSubview:_tableView];
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section==1) {
        return nil;
    }
    IconHeaderView *header = [IconHeaderView iconHeaderView];
    header.backgroundColor = Color(234, 103, 37);
    UserModel *model = [[UserModel alloc]init];
    model.icon = @"01";
    model.phone = @"18930422589";
    model.nickName = @"未登录";
    header.model = model;
    return header;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return 160;
    }
    return 0;
}

@end