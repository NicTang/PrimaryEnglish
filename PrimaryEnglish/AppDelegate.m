//
//  AppDelegate.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/11.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "AppDelegate.h"
#import "NDRootViewController.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import "UIImage+NewImage.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //设置友盟社会化组件appkey
    [UMSocialData setAppKey:KUMengAppKeyString];
    //设置微信AppId、appSecret，分享url
    [UMSocialWechatHandler setWXAppId:KWeChatAppIDString appSecret:KWeChatAppSecretString url:@"http://www.umeng.com/social"];
    //打开新浪微博的SSO开关，设置新浪微博回调地址，这里必须要和你在新浪微博后台设置的回调地址一致。需要 #import "UMSocialSinaSSOHandler.h"
    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:KSinaAppIDString secret:KSinaAppSecretString RedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    NSDictionary *dict = @{NSFontAttributeName :[UIFont systemFontOfSize:18*ScaleValueX],NSForegroundColorAttributeName:[UIColor whiteColor]};
    //设置导航栏的标题文本样式
    [[UINavigationBar appearance]setTitleTextAttributes:dict];
    //设置导航栏的样式为黑色
    [[UINavigationBar appearance]setBarStyle:UIBarStyleBlack];
    //导航栏的背景色（用颜色生成图片，作为导航条的背景图片）
    [[UINavigationBar appearance]setBackgroundImage:[UIImage createImageWithColor:Color(234, 103, 37)] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance]setShadowImage:[UIImage createImageWithColor:[UIColor clearColor]]];
    //设置导航栏返回按钮文字颜色
    [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];
    
    //1、创建窗口
    self.window.backgroundColor = [UIColor whiteColor];
    //自定义控制器
    NDRootViewController *Vc = [[NDRootViewController alloc]init];
    //2、设置窗口的根控制器
    self.window.rootViewController = Vc;
    //3、设置窗口可见
    [self.window makeKeyAndVisible];
    
    return YES;
}
//社交分享回调方法
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = [UMSocialSnsService handleOpenURL:url];
    if (result == FALSE) {
        //调用其他SDK，例如支付宝SDK等
    }
    return result;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
