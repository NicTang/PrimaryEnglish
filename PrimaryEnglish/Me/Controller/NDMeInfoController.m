//
//  NDMeInfoController.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/14.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "NDMeInfoController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MeIconCell.h"
#import "MeNameCell.h"
#import "UserModel.h"
#import "RDVTabBarController.h"
#import "ModifyNickNameController.h"
#import "UIImage+NewImage.h"

@interface NDMeInfoController ()<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UITableView *_tableView;
}
@end

@implementation NDMeInfoController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) style:UITableViewStyleGrouped];
    _tableView.contentInset = UIEdgeInsetsMake(-10, 0, 0, 0);
    _tableView.scrollEnabled = NO;
    
    [_tableView registerNib:[UINib nibWithNibName:@"MeIconCell" bundle:nil] forCellReuseIdentifier:@"meIcon"];
    [_tableView registerNib:[UINib nibWithNibName:@"MeNameCell" bundle:nil] forCellReuseIdentifier:@"meName"];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}
- (UserModel *)user
{
    if (!_user) {
        _user = [[UserModel alloc]init];
    }
    return _user;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0) {
        MeIconCell *cell = [tableView dequeueReusableCellWithIdentifier:@"meIcon" forIndexPath:indexPath];
        cell.icon = self.user.image;
        return cell;
    }
    MeNameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"meName" forIndexPath:indexPath];
    cell.name = self.user.nickName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //修改头像
    if (indexPath.section==0) {
        [self modifyUserIconByActionSheet];
    }else
    {
    //修改昵称
        ModifyNickNameController *nickNameVc = [[ModifyNickNameController alloc]init];
        nickNameVc.title = @"修改昵称";
        //上一个界面传来的昵称，用于在修改昵称界面显示其名字
        nickNameVc.nickName = self.user.nickName;
        nickNameVc.nameblock = ^(NSString *nickName){
            self.user.nickName = nickName;
//            [tableView reloadData];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
            if(self.showUserBlock){
                self.showUserBlock(self.user);
            }
        };
        
        [self.navigationController pushViewController:nickNameVc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        return 80;
    }
    return 60;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
/**
 *  自定义弹出提示框
 */
- (void)alertViewWithTitle:(NSString *)title
{
    __block UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 36)];
    label.center = self.view.center;
    label.layer.cornerRadius = 10;
    label.clipsToBounds = YES;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    [label setBackgroundColor:[UIColor lightGrayColor]];
    label.alpha = 0.7;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:15],NSForegroundColorAttributeName:[UIColor whiteColor]};
    NSAttributedString *attrs = [[NSAttributedString alloc]initWithString:title attributes:dict];
    [label setAttributedText:attrs];
    
    [self.view addSubview:label];
    
    [UIView animateWithDuration:3.0 animations:^{
        label.alpha = 1;
    } completion:^(BOOL finished) {
        [label removeFromSuperview];
        label = nil;
    }];
}
- (void)modifyUserIconByActionSheet
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请选择更改头像方式" preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"使用相机拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectPictureByTakingPhoto];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"通过相册选图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectPictureFromPhotoLibrary];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:alert completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)selectPictureFromPhotoLibrary
{
    //如果相册可以访问
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        UIImagePickerController *imgPicker = [[UIImagePickerController alloc]init];
        //设置选择的文件资源的来源
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //设置代理
        imgPicker.delegate = self;
        //设置是否允许编辑
        imgPicker.allowsEditing = YES;
        //显示相册选择界面（视图控制器）
        [self presentViewController:imgPicker animated:YES completion:nil];
        
    }else
    {
        NSLog(@"相册无法访问！");
    }
}
- (void)selectPictureByTakingPhoto
{
    //如果照相机可以使用
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *imgPicker = [[UIImagePickerController alloc]init];
        imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imgPicker.delegate = self;
        imgPicker.allowsEditing = YES;
        [self presentViewController:imgPicker animated:YES completion:nil];
        
    }else
    {
        NSLog(@"照相机不能使用！");
    }
}
#pragma mark - UIImagePickerControllerDelegate方法
/**
 *  选择媒体文件后被调用
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //获取选择文件的类型（图片／视频）
    NSString *type = info[UIImagePickerControllerMediaType];
    if ([type isEqualToString:(NSString *)kUTTypeImage]) {
        //取出编辑后的图片
        UIImage *image = info[UIImagePickerControllerEditedImage];
        //修改用户模型头像
        self.user.image = image;
        NSIndexPath *indexPath = _tableView.indexPathForSelectedRow;
        MeIconCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"meIcon" forIndexPath:indexPath];
        //裁剪并返回一张圆形图片
        UIImage *newImage = [UIImage clipImageWithImage:image setSize:cell.iconView.frame.size];
        cell.icon = newImage;
        //刷新这一行
        [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
//        [_tableView reloadData];
        if(self.showUserBlock){
            self.showUserBlock(self.user);
        }
    }
    //返回
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
