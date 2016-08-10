//
//  ModifyNickNameController.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/15.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "ModifyNickNameController.h"

@interface ModifyNickNameController ()<UITextFieldDelegate>
{
    UITextField *_nickNameText;
    UIButton *_saveBtn;
}
@end

@implementation ModifyNickNameController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
}
- (void)createUI
{
    _nickNameText = [[UITextField alloc]initWithFrame:CGRectMake(5, 16, KScreenWidth-5*2, 40)];
    _nickNameText.clearButtonMode = UITextFieldViewModeAlways;
    _nickNameText.borderStyle = UITextBorderStyleRoundedRect;
    _nickNameText.text = self.nickName;
    _nickNameText.backgroundColor = [UIColor whiteColor];
    _nickNameText.delegate = self;
    [self.view addSubview:_nickNameText];
    
    _saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    CGFloat btnX = 23;
    CGFloat btnY = CGRectGetMaxY(_nickNameText.frame) + 20;
    CGFloat btnW = KScreenWidth - 2*btnX;
    _saveBtn.frame = CGRectMake(btnX, btnY, btnW, 46);
    [_saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_saveBtn addTarget:self action:@selector(saveNickName:) forControlEvents:UIControlEventTouchUpInside];
    _saveBtn.layer.cornerRadius = 6;
    [_saveBtn setBackgroundColor:Color(234, 103, 37)];
    [self.view addSubview:_saveBtn];
    self.view.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:gesture];
}
- (void)saveNickName:(UIButton *)button
{
    if ([_nickNameText.text isEqualToString:@""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示信息" message:@"昵称不能为空！" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            _nickNameText.text = self.nickName;
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }else
    {
        if (self.nameblock) {
            self.nameblock(_nickNameText.text);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - UITextFieldDelegate方法
//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    if ([textField.text isEqualToString:@""]) {
//        _saveBtn.enabled = NO;
//    }
//}
@end
