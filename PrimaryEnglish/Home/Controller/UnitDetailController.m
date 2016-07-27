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

//@property (nonatomic,strong) NSArray *imgArray;
@property (nonatomic,strong) NSArray *mp3Array;
@property (nonatomic,strong) NSDictionary *imgDict;
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
//- (NSArray *)imgArray
//{
//    if (!_imgArray) {
//        _imgArray = [NSArray array];
//    }
//    return _imgArray;
//}
- (NSArray *)mp3Array
{
    if (!_mp3Array) {
        _mp3Array = [NSArray array];
    }
    return _mp3Array;
}
- (NSDictionary *)imgDict
{
    if (!_imgDict) {
        _imgDict = [NSDictionary dictionary];
    }
    return _imgDict;
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
    //创建任务组变量
//    dispatch_group_t group=dispatch_group_create();
//    //获取全局的并行队列
//    dispatch_queue_t queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //在任务组中添加任务
//    dispatch_group_async(group, queue, ^{
        for (NDDetailModel *model in self.unitsArray) {
            [self requestDataWithSenceid:model.senceid completion:^(NSArray *arr) {
//                NSLog(@"dict:%ld-%@",dict.count,dict);
//                [self.totalDataArray addObject:dict];
            }];
        }
        NSLog(@"totalDataArray:%ld",self.totalDataArray.count);
//    });
//    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
////        NSLog(@"totalDataArray:%ld",self.totalDataArray.count);
//        self.tabBar.currentPageLabel.text = [NSString stringWithFormat:@"1/%ld",self.totalDataArray.count];
//    });
}

- (void)refreshUI
{
    //创建任务组变量
    dispatch_group_t group=dispatch_group_create();
    //获取全局的并行队列
    dispatch_queue_t queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //获取一个自定义的串行队列（顺序执行）
//    dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
    
    //在任务组中添加任务
    dispatch_group_async(group, queue, ^{
        
        [self requestDataWithSenceid:self.senceid completion:^(NSArray *arr) {
//            NSLog(@"dict:%ld-%@",dict.count,dict);
//            NSArray *array = dict[self.senceid];
            NSLog(@"arrcount:%ld-%@",arr.count,arr);
            //主线程上更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                for (int i = 0 ; i<arr.count; i++) {
                    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i*KScreenWidth, 0, KScreenWidth, KScreenHeight-64-49)];
                    //!!!   URL != String
                    NSURL *url = [NSURL URLWithString:arr[i]];
                    [imageView setImageWithURL:url];
                    //设置垂直方向不能滚动
                    self.scrollView.contentSize = CGSizeMake(arr.count*KScreenWidth, 0);
                    [self.scrollView addSubview:imageView];
                }
            });
        }];
    });
    //在任务组中添加任务
//    for (NDDetailModel *model in self.unitsArray) {
//        dispatch_group_async(group, queue, ^{
//            [self requestDataWithSenceid:model.senceid completion:^(NSArray *array, NSDictionary *dict) {
//                NSLog(@"dict:%ld-%@",dict.count,dict);
////                [self.totalDataArray addObject:dict];
//            }];
//        });
//    }
    //当group中的所有任务执行完毕后，在队列中执行block
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
//        [self requestTotalDataArray];
        NSLog(@"totalDataArray:%ld",self.totalDataArray.count);
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
- (void)requestDataWithSenceid:(NSString *)senceid completion:(void (^)(NSArray *arr))completion
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //拼接URL路径
    NSString *url = [NSString stringWithFormat:KUnitDetailString,senceid];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *rootArray = responseObject;
        NSArray *array = [self parseDataFromArray:rootArray withSenceid:senceid];
        
        completion(array);
//        if (self.imgArray.count!=0)
//        {
//            completion(self.imgArray,nil);
////            NSLog(@"self.imgArray.count:%ld",self.imgArray.count);
//            
//        }
//        //字典里面有值
//        if (self.imgDict.count!=0) {
//            completion(nil,self.imgDict);
////            NSLog(@"self.imgDict.count:%ld",self.imgDict.count);
////            [self.totalDataArray addObject:self.imgDict];
//        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            NSLog(@"error:%@",error.localizedDescription);
        }
    }];
}
/**
 *  解析数据，分割出需要的字符串
*/
- (NSArray *)parseDataFromArray:(NSArray *)rootArray withSenceid:(NSString *)senceid
{
    NSMutableArray *imageArray = [NSMutableArray array];
    NSMutableArray *mp3Array = [NSMutableArray array];
//    NSMutableDictionary *imageDict = [NSMutableDictionary dictionary];
//    NSMutableDictionary *mp3Dictionary = [NSMutableDictionary dictionary];
    
    for (NSDictionary *rootDict in rootArray) {
        NSArray *content = rootDict[@"content"];
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
                    [imageArray addObject:img];
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
    NSArray *imgArray = [[NSArray alloc]init];
    imgArray = imageArray;
    self.mp3Array = mp3Array;
    return imgArray;
//    [imageDict setObject:_imgArray forKey:senceid];
//    return imageDict;
//    [imageArray removeAllObjects];
    
//    [mp3Dictionary setObject:mp3Array forKey:senceid];
//    [imageDict setObject:self.imgArray forKey:senceid];
//    [mp3Dictionary setObject:self.mp3Array forKey:senceid];
//    
//    self.imgDict = imageDict;
//    self.mp3Dict = mp3Dictionary;
    
//    NSLog(@"%ld-%@",self.imgArray.count,self.imgDict);
//    NSLog(@"%ld-%@",self.mp3Array.count,self.mp3Dict);
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
