//
//  NDRootViewController.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/11.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "NDRootViewController.h"
#import "NDHomeController.h"
#import "NDCourseController.h"
#import "NDMeController.h"
#import "RDVTabBarItem.h"
#import "RDVTabBarController.h"

@interface NDRootViewController ()
@property (nonatomic,strong) NSArray *titles;
@end

@implementation NDRootViewController
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self createViewControllers];
    [self customizeTabBarItem];
}

- (NSArray *)titles
{
    if (!_titles) {
        _titles = @[@"首页",@"课程库",@"我"];
    }
    return _titles;
}
- (void)createViewControllers
{
    NSMutableArray *subVcs = [NSMutableArray array];
    NSArray *vcNames = @[@"NDHomeController",@"NDCourseController",@"NDMeController"];
    for (int i = 0;i<vcNames.count;i++) {
        
        Class class = NSClassFromString(vcNames[i]);
        UIViewController *vc = [[class alloc]init];
        vc.navigationItem.title = self.titles[i];
        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:vc];
        [subVcs addObject:navi];
    }
    self.viewControllers = subVcs;
}

- (void)customizeTabBarItem
{    
    NSArray *images = @[@"tabbar_home",@"tabbar_course",@"tabbar_profile"];
    NSDictionary *unselectedDict = @{NSFontAttributeName : [UIFont systemFontOfSize:13],NSForegroundColorAttributeName:Color(117, 117, 117)};
    NSDictionary *selectedDict = @{NSFontAttributeName : [UIFont systemFontOfSize:13],NSForegroundColorAttributeName:Color(234, 103, 37)};
    
    int index = 0;
    for(RDVTabBarItem *item in self.tabBar.items){
        item.unselectedTitleAttributes = unselectedDict;
        item.selectedTitleAttributes = selectedDict;
        NSString *unSelectedImg = [NSString stringWithFormat:@"%@",images[index]];
        NSString *selectedImg = [NSString stringWithFormat:@"%@_selected",images[index]];
        [item setFinishedSelectedImage:[UIImage imageNamed:selectedImg] withFinishedUnselectedImage:[UIImage imageNamed:unSelectedImg]];
        item.title = self.titles[index];
        
        index++;
    }
}

@end
