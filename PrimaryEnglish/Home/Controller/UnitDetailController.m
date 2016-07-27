//
//  UnitDetailController.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/21.
//  Copyright © 2016年 Nic. All rights reserved.
//
#define HttpUrl @"http://app.ekaola.com"
#define DataSavePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject]stringByAppendingPathComponent:@"total.plist"]

#import "UnitDetailController.h"
#import "AFHTTPSessionManager.h"
#import "UIImageView+AFNetworking.h"
#import "UnitTabBar.h"
#import "SelectCourseHeader.h"
#import "NDDetailModel.h"

@interface UnitDetailController ()<UnitTabBarDelegate,UITableViewDelegate,UITableViewDataSource,SelectCourseHeaderDelegate>

@property (nonatomic,strong) NSArray *mp3Array;
@property (nonatomic,strong) NSDictionary *mp3Dict;
@property (nonatomic,strong) NSMutableArray *totalDataArray;

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIView *coverView;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,assign) NSIndexPath *selectedIndexPath;
@property (nonatomic,strong) UnitTabBar *tabBar;

@end

@implementation UnitDetailController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createUI];
    [self refreshUI];
//    [self requestTotalDataArray];
}
- (NSIndexPath *)selectedIndexPath
{
    if (_selectedIndexPath==nil) {
        _selectedIndexPath = [NSIndexPath indexPathForRow:self.selectIndex inSection:0];
    }
    return _selectedIndexPath;
}
- (NSArray *)mp3Array
{
    if (!_mp3Array) {
        _mp3Array = [NSArray array];
    }
    return _mp3Array;
}
- (NSDictionary *)mp3Dict
{
    if (!_mp3Dict) {
        _mp3Dict = [NSDictionary dictionary];
    }
    return _mp3Dict;
}
- (NSMutableArray *)totalDataArray
{
    if (!_totalDataArray) {
        _totalDataArray = [NSMutableArray array];
    }
    return _totalDataArray;
}
- (void)requestTotalDataArray
{
    for (NDDetailModel *model in self.unitsArray) {
        [self requestDataWithSenceid:model.senceid completion:^(NSDictionary *imageDict) {
            NSLog(@"dictionary:%ld-%@",imageDict.count,imageDict);
            [self.totalDataArray addObject:imageDict];
        }];
    }
}
- (void)refreshUI
{
//    //创建任务组变量
//    dispatch_group_t group=dispatch_group_create();
//    //获取全局的并行队列
    dispatch_queue_t queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    //在任务组中添加任务
//    dispatch_group_async(group, queue, ^{
//        
//        [self requestDataWithSenceid:self.senceid completion:^(NSDictionary *imageDict) {
//            NSArray *imgArray = imageDict[self.senceid];
//            NSLog(@"arrcount:%ld-%@",imgArray.count,imgArray);
//            //主线程上更新UI
//            dispatch_async(dispatch_get_main_queue(), ^{
//                for (int i = 0 ; i<imgArray.count; i++) {
//                    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i*KScreenWidth, 0, KScreenWidth, KScreenHeight-64-49)];
//                    //!!!   URL != String
//                    NSURL *url = [NSURL URLWithString:imgArray[i]];
//                    [imageView setImageWithURL:url];
//                    //设置垂直方向不能滚动
//                    self.scrollView.contentSize = CGSizeMake(imgArray.count*KScreenWidth, 0);
//                    [self.scrollView addSubview:imageView];
//                }
//            });
//        }];
//    });
//    //当group中的所有任务执行完毕后，在队列中执行block
//    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
//        [self requestTotalDataArray];
//    });
    
    //获取一个自定义的串行队列（顺序执行）
//    dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
    
    //将任务放在队列中，同步执行，(不会创建子线程)
    dispatch_async(queue, ^{
        [self requestDataWithSenceid:self.senceid completion:^(NSDictionary *imageDict) {
            NSArray *imgArray = imageDict[self.senceid];
            NSLog(@"arrcount:%ld-%@",imgArray.count,imgArray);
            //主线程上更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                for (int i = 0 ; i<imgArray.count; i++) {
                    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i*KScreenWidth, 0, KScreenWidth, KScreenHeight-64-49)];
                    //!!!   URL != String
                    NSURL *url = [NSURL URLWithString:imgArray[i]];
                    [imageView setImageWithURL:url];
                    //设置垂直方向不能滚动
                    self.scrollView.contentSize = CGSizeMake(imgArray.count*KScreenWidth, 0);
                    [self.scrollView addSubview:imageView];
                }
            });
        }];
    });
    dispatch_async(queue, ^{
        for (NDDetailModel *model in self.unitsArray) {
            [self requestDataWithSenceid:model.senceid completion:^(NSDictionary *imageDict) {
                NSLog(@"dictionary:%ld-%@",imageDict.count,imageDict);
                [self.totalDataArray addObject:imageDict];
            }];
        }
    });
}
- (void)createUI
{
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    [self.view addSubview:_scrollView];
    
    _tabBar = [UnitTabBar unitTabbar];
    _tabBar.frame = CGRectMake(0, KScreenHeight-64-49, KScreenWidth, 49);
    _tabBar.delegate = self;
    [self.view addSubview:_tabBar];
}
- (void)requestDataWithSenceid:(NSString *)senceid completion:(void (^)(NSDictionary *imageDict))completion
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //拼接URL路径
    NSString *url = [NSString stringWithFormat:KUnitDetailString,senceid];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *rootArray = responseObject;
        [rootArray writeToFile:@"/Users/tangzhaoning/Desktop/2.plist" atomically:YES];
        NSDictionary *imgDict = [self parseDataFromArray:rootArray withSenceid:senceid];
        //回调传值，将每单元的图片字典回传
        completion(imgDict);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            NSLog(@"error:%@",error.localizedDescription);
        }
    }];
}
/**
 *  解析数据，分割出需要的字符串
*/
- (NSDictionary *)parseDataFromArray:(NSArray *)rootArray withSenceid:(NSString *)senceid
{
    NSMutableArray *imageArray = [NSMutableArray array];
    NSMutableArray *mp3Array = [NSMutableArray array];
    NSMutableDictionary *imageDict = [NSMutableDictionary dictionary];
//    NSMutableDictionary *mp3Dictionary = [NSMutableDictionary dictionary];
    for (NSDictionary *rootDict in rootArray) {
        NSArray *content = rootDict[@"content"];
        int flag = 0;//是否添加图片标志
        for (int i = 0; i<content.count; i++) {
            NSDictionary *contentDict = content[i];
            NSString *urlString = contentDict[@"content"];
            if ([urlString containsString:@".jpg"]) {
                NSString *imgUrl = urlString;
                NSRange range = [imgUrl rangeOfString:@"src"];
                if(range.location!=NSNotFound){
                    NSInteger index = range.location+range.length+2;
                    NSString *srcString = [imgUrl substringFromIndex:index];
                    NSString *imgString = [srcString substringToIndex:srcString.length-2];
                    NSString *img = [NSString stringWithFormat:@"%@%@",HttpUrl,imgString];
                    //添加图片之前判断是否继续添加
                    if (flag<1) {
                        [imageArray addObject:img];
                        flag++;
                    }
                }
            } else if([urlString containsString:@".mp3"]){
                NSString *mp3Url = urlString;
                NSRange urlRange = [mp3Url rangeOfString:@"url"];
                NSRange mp3Range = [mp3Url rangeOfString:@"mp3"];
                if (urlRange.location!=NSNotFound && mp3Range.location!=NSNotFound) {
                    NSInteger fromIndex = urlRange.location+urlRange.length+3;
                    NSInteger toIndex = mp3Range.location + mp3Range.length;
                    NSInteger length = toIndex - fromIndex;
                    NSString *mp3String = [urlString substringWithRange:NSMakeRange(fromIndex, length)];
                    NSString *mp3 = [NSString stringWithFormat:@"%@/%@",HttpUrl,mp3String];
                    [mp3Array addObject:mp3];
                }
            }
        }
    }
    self.mp3Array = mp3Array;
    //每单元的senceid->imageArray组成一个字典
    [imageDict setObject:imageArray forKey:senceid];
    return imageDict;
}
#pragma mark - UnitTabBarDelegate代理方法
- (void)tabBarItemClickToShowMenu:(UnitTabBar *)tabBar
{
    //添加遮盖
    _coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64)];
    _coverView.backgroundColor = [UIColor blackColor];
    _coverView.alpha = 0.5;
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, KScreenHeight-64-450-60, KScreenWidth, 510) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
    [self.view addSubview:_coverView];
    [self.view addSubview:_tableView];
}
- (void)tabBarItemClickToShareInfo:(UnitTabBar *)tabBar
{
    NSLog(@"tabBarItemClickToShareInfo");
}
#pragma mark - SelectCourseHeaderDelegate代理方法
- (void)selectCourseCancel:(SelectCourseHeader *)header
{
    [self.coverView removeFromSuperview];
    [self.tableView removeFromSuperview];
    self.coverView = nil;
    self.tableView = nil;
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.unitsArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"unit";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    if (indexPath==self.selectedIndexPath) {
        [cell.textLabel setTextColor:[UIColor redColor]];
    }
    NDDetailModel *model = self.unitsArray[indexPath.row];
    cell.textLabel.text = model.title;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
#pragma mark - UITableViewDelegate代理方法
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        SelectCourseHeader *header = [SelectCourseHeader selectCourseHeader];
        header.delegate = self;
        return header;
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
    [lastCell.textLabel setTextColor:[UIColor blackColor]];
    //更新
    self.selectedIndexPath = indexPath;
    UITableViewCell *SelectCell = [tableView cellForRowAtIndexPath:indexPath];
    [SelectCell.textLabel setTextColor:[UIColor redColor]];
}
@end
