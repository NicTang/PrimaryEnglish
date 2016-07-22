//
//  NDLoginController.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/18.
//  Copyright © 2016年 Nic. All rights reserved.
//
#define CountDown 30
#import "NDLoginController.h"
#import "AFHTTPSessionManager.h"
#import "UserModel.h"

@interface NDLoginController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phoneNum;
@property (weak, nonatomic) IBOutlet UITextField *codeNum;
@property (weak, nonatomic) IBOutlet UIButton *codeBtn;
@property (weak, nonatomic) IBOutlet UIImageView *phoneIcon;
@property (weak, nonatomic) IBOutlet UIImageView *codeIcon;

@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,assign) int countDowmTime;
- (IBAction)codeBtnClick:(id)sender;
- (IBAction)loginBtnClick:(id)sender;
- (IBAction)cancelBtnClick:(id)sender;
@end

@implementation NDLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.countDowmTime = CountDown;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard)];
    [self.view addGestureRecognizer:tap];
}

//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}
/**
 *  从xib中加载控制器
 */
- (instancetype)init
{
    return [self initWithNibName:@"NDLoginController" bundle:[NSBundle mainBundle]];
}
/**
 *  隐藏键盘
 */
- (void)hideKeyBoard
{
    [self.view endEditing:YES];
}
- (void)stopTimer
{
    self.countDowmTime = CountDown;
    self.codeBtn.enabled = YES;
    [self.codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.codeBtn setBackgroundColor:[UIColor greenColor]];
    [self.timer invalidate];
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
/**
 *  定时器调用方法
 */
- (void)countDown
{
    [self.codeBtn setBackgroundColor:[UIColor grayColor]];
    self.codeBtn.enabled = NO;
    self.countDowmTime--;
    
    [UIView animateWithDuration:0 animations:^{
        //添加以下代码，解决文字改变时闪动问题
        self.codeBtn.titleLabel.text = [NSString stringWithFormat:@"%d",self.countDowmTime];
        [self.codeBtn setTitle:[NSString stringWithFormat:@"%d",self.countDowmTime] forState:UIControlStateNormal];
    }];
    if (self.countDowmTime<0) {
        [self stopTimer];
    }
}
- (BOOL)isPhoneNumber
{
    if ([self.phoneNum.text isEqualToString:@""]||self.phoneNum.text==nil||[self.phoneNum.text doubleValue]==0) {
        return NO;
    }
    return YES;
}
- (BOOL)isPhoneCode
{
    if ([self.codeNum.text isEqualToString:@""]||self.codeNum.text==nil) {
        return NO;
    }
    return YES;
}
/**
 *  点击“获取验证码”按钮，发送验证码到手机
 */
- (IBAction)codeBtnClick:(id)sender {
    
    [self hideKeyBoard];
    if (![self isPhoneNumber]){
        [self alertViewWithTitle:@"请输入正确的手机号码！"];
        return;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //拼接URL路径
    NSString *url = [NSString stringWithFormat:KPhoneCodeString,self.phoneNum.text];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *result = responseObject[@"result"];
        if ([result isEqualToString:@"ok"]) {
            [self alertViewWithTitle:@"短信验证码发送成功！"];
        }else
        {
            NSString *msg = responseObject[@"msg"];
            [self alertViewWithTitle:msg];
            [self stopTimer];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            [self alertViewWithTitle:error.localizedDescription];
        }
    }];
}

- (IBAction)loginBtnClick:(id)sender {
    
    [self hideKeyBoard];
    
    if (![self isPhoneNumber]&&![self isPhoneCode]) {
        [self alertViewWithTitle:@"手机号码格式错误！\n请输入验证码！"];
        return;
    }
    if (![self isPhoneNumber]||self.phoneNum.text.length!=11) {
        [self alertViewWithTitle:@"手机号码格式错误！"];
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //post请求参数
    NSDictionary *dict = @{@"telphone":self.phoneNum.text,@"code":self.codeNum.text};
    [manager POST:kLoginCommitString parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = responseObject;
        if([dict.allKeys containsObject:@"msg"]){
            NSString *msg = dict[@"msg"];
            if (msg==nil) {
                [self alertViewWithTitle:@"请输入验证码！"];
            }else
            {
                [self alertViewWithTitle:dict[@"msg"]];
            }
            return;
        }
        NSLog(@"responseObject:%@",responseObject);
        NSInteger status = [responseObject[@"status"] integerValue];
        if (status==0) {
            UserModel *model = [NSKeyedUnarchiver unarchiveObjectWithFile:NDModelSavePath];
            if (model==nil) {
                [self alertViewWithTitle:@"登录成功！"];
                if ([self.userLoginModel.nickName isEqualToString:@"未登录"]) {
                    self.userLoginModel.nickName = @"我";
                }
                self.userLoginModel.status = status;
                self.userLoginModel.phone = self.phoneNum.text;
                self.userLoginModel.code = self.codeNum.text;
                //向上一个界面传值
                if (self.userLoginBlock) {
                    self.userLoginBlock(self.userLoginModel);
                }
            }else
            {
                //上次已退出登录
                if (model.status==1) {
                    model.status = status;
                }
                //向上一个界面传值
                if (self.userLoginBlock) {
                    self.userLoginBlock(model);
                }
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            NSLog(@"error:%@",error.localizedDescription);
        }
    }];
}

- (IBAction)cancelBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate代理方法
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.phoneNum]) {
        [self.phoneIcon setHighlighted:YES];
    }else
    {
        if (self.timer) {
            [self stopTimer];
        }
        [self.codeIcon setHighlighted:YES];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.phoneNum]) {
        [self.phoneIcon setHighlighted:NO];
    }else
    {
        [self.codeIcon setHighlighted:NO];
    }
}
@end
