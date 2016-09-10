//
//  SettingAboutController.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/15.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "SettingAboutController.h"

@interface SettingAboutController ()

@end

@implementation SettingAboutController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIWebView *web = [[UIWebView alloc]initWithFrame:self.view.bounds];
    NSURL *url = [NSURL URLWithString:@"http://www.engua.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [web loadRequest:request];
    [self.view addSubview:web];
}
#pragma mark - 控制器销毁时释放内存
- (void)dealloc
{
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}
@end
