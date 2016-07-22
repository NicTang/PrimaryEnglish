//
//  NDSettingController.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/14.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "NDSettingController.h"
#import "RDVTabBarController.h"
#import "SettingAboutController.h"

@interface NDSettingController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIButton *logOutBtn;

@property (nonatomic,strong) NSArray *settingArray;
@end

@implementation NDSettingController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, 150) style:UITableViewStyleGrouped];
    //为了配合代理方法，压缩头部、尾部的高度
    _tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    _tableView.scrollEnabled = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _logOutBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    CGFloat btnX = 30;
    CGFloat btnY = CGRectGetMaxY(_tableView.frame);
    CGFloat btnW = KScreenWidth - btnX * 2;
    _logOutBtn.frame = CGRectMake(btnX, btnY, btnW, 60);
    [_logOutBtn setBackgroundColor:Color(231, 71, 78)];
    [_logOutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [_logOutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_logOutBtn addTarget:self action:@selector(logOutClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_logOutBtn];
    self.view.backgroundColor = Color(235, 235, 241);
}
- (NSArray *)settingArray
{
    if (!_settingArray) {
        _settingArray = @[@[@"推荐给好友"],@[@"关于我们"]];
    }
    return _settingArray;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.settingArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.settingArray[section] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"setting"];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"setting"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.settingArray[indexPath.section][indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        UIAlertController *alert = [ UIAlertController alertControllerWithTitle:@"分享" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"分享给微信好友" style:UIAlertActionStyleDefault handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"分享到朋友圈" style:UIAlertActionStyleDefault handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else if (indexPath.section==1)
    {
        SettingAboutController *about = [[SettingAboutController alloc]init];
        about.title = self.settingArray[indexPath.section][indexPath.row];
        [self.navigationController pushViewController:about animated:YES];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}
- (void)logOutClick:(UIButton *)button
{
    NSLog(@"logOutClick");
    if ([self.delegate respondsToSelector:@selector(settingController:logout:)]) {
        //将登录状态传给上一界面，未登录为1
        [self.delegate settingController:self logout:1];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
@end
