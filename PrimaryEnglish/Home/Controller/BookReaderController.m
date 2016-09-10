//
//  UnitDetailController.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/21.
//  Copyright © 2016年 Nic. All rights reserved.
//
#define TableViewRowH 46*ScaleValueY
#define TableViewHeaderH 60*ScaleValueY
#define UnitTabBarH 49*ScaleValueY

#import "BookReaderController.h"
#import "AFHTTPSessionManager.h"
#import "UIImageView+AFNetworking.h"
#import "RDVTabBarController.h"
#import "UnitTabBar.h"
#import "SelectCourseHeader.h"
#import "NDDetailModel.h"
#import <AVFoundation/AVFoundation.h>//播放音乐
#import "UMSocialSnsService.h"//友盟分享
#import "UMSocialSnsPlatformManager.h"
#import "UIImage+NewImage.h"

@interface BookReaderController ()<UnitTabBarDelegate,UITableViewDelegate,UITableViewDataSource,SelectCourseHeaderDelegate,UIScrollViewDelegate>

@property (nonatomic,strong) NSArray *mp3Array;
@property (nonatomic,strong) NSDictionary *mp3Dict;
@property (nonatomic,strong) NSMutableArray *totalDataArray;

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIView *coverView;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,assign) NSIndexPath *selectedIndexPath;
@property (nonatomic,strong) UnitTabBar *unitTabBar;

@property (nonatomic,strong) AVQueuePlayer *mp3Player;
@property (nonatomic,assign) int currentPage;

@property (nonatomic,copy) void(^allDataBlock)(NSMutableArray *allDataArray);

@end

@implementation BookReaderController
/**
 *  隐藏底部tabbar
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createUI];
    [self refreshUI];
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
- (void)requestAllDataUntilCompletion:(void (^)(NSMutableArray *dataArray))completion
{
    for (NDDetailModel *model in self.unitsArray) {
        [self requestDataWithSenceid:model.senceid completion:^(NSDictionary *imageDict,NSDictionary *mp3Dict) {
            [self.totalDataArray addObject:imageDict];
            //返回传值
            completion(self.totalDataArray);
        }];
    }
}
- (void)showImageWithDict:(NSDictionary *)imgDict play:(NSDictionary *)mp3Dict senceid:(NSString *)senceid handler:(void(^)())handlerBlock
{
    //得到mp3字典
    self.mp3Dict = mp3Dict;
    NSArray *imgArray = imgDict[senceid];
    //主线程上更新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        for (int i = 0 ; i<imgArray.count; i++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i*KScreenWidth, 0, KScreenWidth, KScreenHeight-64-UnitTabBarH)];
            //!!!   URL != String
            NSURL *url = [NSURL URLWithString:imgArray[i]];
            [imageView setImageWithURL:url];
            //设置垂直方向不能滚动
            self.scrollView.contentSize = CGSizeMake(imgArray.count*KScreenWidth, 0);
            [self.scrollView addSubview:imageView];
        }
        _unitTabBar = [UnitTabBar unitTabbar];
        CGFloat unitTabBarY = CGRectGetMaxY(self.scrollView.frame);
        _unitTabBar.frame = CGRectMake(0, unitTabBarY, KScreenWidth, UnitTabBarH);
        _unitTabBar.totalPage = imgArray.count;
        _unitTabBar.currentPage = 1;
        _unitTabBar.delegate = self;
        [self.view addSubview:_unitTabBar];
    });
    //得到字典,更新显示图片之后，开始执行block中的代码，即播放音频
    //（延时执行某段代码）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        handlerBlock();
    });
}
- (void)refreshUI
{
    //获取全局的并行队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //将任务放在队列中，异步执行，(创建子线程)
    dispatch_async(queue, ^{
        [self requestDataWithSenceid:self.senceid completion:^(NSDictionary *imageDict,NSDictionary *mp3Dict) {
            [self showImageWithDict:imageDict play:mp3Dict senceid:self.senceid handler:^{
                self.mp3Player = nil;
                self.currentPage = 1;
                [self playMp3AtBeginWithSenceid:self.senceid];
            }];
        }];
    });
}
- (void)createUI
{
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64-UnitTabBarH)];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    [self.view addSubview:_scrollView];
}
- (void)requestDataWithSenceid:(NSString *)senceid completion:(void (^)(NSDictionary *imageDict,NSDictionary *mp3Dict))completion
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //拼接URL路径
    NSString *url = [NSString stringWithFormat:KUnitDetailString,senceid];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *rootArray = responseObject;
        //保存请求数据到本地
        [self parseDataFromArray:rootArray withSenceid:senceid completion:^(NSDictionary *imgDict, NSDictionary *mp3Dict) {
            //回调传值，将每单元的图片字典回传
            completion(imgDict,mp3Dict);
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"网络请求失败提示信息" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self dismissViewControllerAnimated:alert completion:nil];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}
/**
 *  解析数据，分割出需要的字符串
*/
- (void)parseDataFromArray:(NSArray *)rootArray withSenceid:(NSString *)senceid completion:(void (^)(NSDictionary *imgDict,NSDictionary *mp3Dict))completion
{
    NSMutableArray *imageArray = [NSMutableArray array];
    NSMutableDictionary *imageDict = [NSMutableDictionary dictionary];
    NSMutableArray *mp3Array = [NSMutableArray array];
    NSMutableDictionary *mp3Dict = [NSMutableDictionary dictionary];
    
    int mp3Index = 0;//mp3所对应的图片下标
    //遍历该单元所有图片
    for (int i = 0; i<rootArray.count; i++) {
        NSDictionary *rootDict = rootArray[i];
        NSArray *content = rootDict[@"content"];
        
        int flag = 0;//是否添加图片标志
        NSMutableDictionary *mp3Dictionary = [NSMutableDictionary dictionary];
        NSMutableArray *mp3Arr = [NSMutableArray array];
        
        //遍历一张图片上的所有声音
        for (int j = 0; j<content.count; j++) {
            NSDictionary *contentDict = content[j];
            NSString *urlString = contentDict[@"content"];
            if ([urlString containsString:@".jpg"]) {
                NSString *imgUrl = urlString;
                NSRange range = [imgUrl rangeOfString:@"src"];
                if(range.location!=NSNotFound){
                    NSInteger index = range.location+range.length+2;
                    NSString *srcString = [imgUrl substringFromIndex:index];
                    NSString *imgString = [srcString substringToIndex:srcString.length-2];
                    NSString *img = [NSString stringWithFormat:PrefixForUrl,imgString];
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
                    NSString *mp3 = [NSString stringWithFormat:PrefixForUrl,mp3String];
                    [mp3Arr addObject:mp3];
                }
            }
        }
        mp3Index++;
        [mp3Dictionary setObject:mp3Arr forKey:@(mp3Index)];
        [mp3Array addObject:mp3Dictionary];
    }
    //每单元的senceid->imageArray组成一个字典
    [imageDict setObject:imageArray forKey:senceid];
    [mp3Dict setObject:mp3Array forKey:senceid];
    //返回传值
    completion(imageDict,mp3Dict);
}
#pragma mark - UnitTabBarDelegate代理方法
- (void)tabBarItemClickToShowMenu:(UnitTabBar *)tabBar
{
    //添加遮盖
    _coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64)];
    _coverView.backgroundColor = [UIColor blackColor];
    _coverView.alpha = 0.5;
    CGFloat tableViewH = self.unitsArray.count*TableViewRowH+TableViewHeaderH;
    CGFloat tableViewY = KScreenHeight-64-tableViewH;
    CGRect frame = CGRectMake(0, tableViewY, KScreenWidth, tableViewH);
    _tableView = [[UITableView alloc]initWithFrame:frame style:UITableViewStyleGrouped];    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
    [self.view addSubview:_coverView];
    [self.view addSubview:_tableView];
}
- (void)tabBarItemClickToShareInfo:(UnitTabBar *)tabBar
{
    [UMSocialData defaultData].extConfig.wechatSessionData.url = @"http://baidu.com";
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = @"http://baidu.com";
    [UMSocialData defaultData].extConfig.wechatSessionData.title = self.title;
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = self.title;
    NSString *infoString = [NSString stringWithFormat:@"我正在学 %@，你也一起来吧！",self.title];
    //分享png、jpg图片
    [UMSocialSnsService presentSnsIconSheetView:self appKey:KUMengAppKeyString shareText:infoString shareImage:[UIImage captureImageWithView:self.view] shareToSnsNames:@[UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline] delegate:nil];
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TableViewRowH;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return TableViewHeaderH;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NDDetailModel *model = self.unitsArray[indexPath.row];
    if (self.learningReaderBlock) {
        self.learningReaderBlock(model,self.courseName,indexPath.row,self.unitsArray,self.courseID);
    };
    UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
    [lastCell.textLabel setTextColor:[UIColor blackColor]];
    //更新
    self.selectedIndexPath = indexPath;
    UITableViewCell *SelectCell = [tableView cellForRowAtIndexPath:indexPath];
    [SelectCell.textLabel setTextColor:[UIColor redColor]];
    
    NSString *senceid = model.senceid;
    self.title = model.title;
    
    self.mp3Player = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.senceid = senceid;
    
    [self requestDataWithSenceid:senceid completion:^(NSDictionary *imageDict, NSDictionary *mp3Dict) {
        [self showImageWithDict:imageDict play:mp3Dict senceid:senceid handler:^{
            self.currentPage = 1;
            self.scrollView.contentOffset = CGPointMake(0, 0);
            [self playMp3AtBeginWithSenceid:senceid];
        }];
    }];
    [self.coverView removeFromSuperview];
    [self.tableView removeFromSuperview];
    self.coverView = nil;
    self.tableView = nil;
}
#pragma mark - UIScrollViewDelegate代理方法
- (void)playMp3AtBeginWithSenceid:(NSString *)senceid
{
    //监听播放状态，播放完成后，自动调用playbackFinished方法播放下一首
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    //一开始播放第一张图片所对应的mp3
    //获得第一张图片所对应的mp3数组
    [self getMp3ArrayWithIndex:1 senceid:senceid];
    [self initMp3Player];
}
/**
 *  滚动结束时调用
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //  当前滚动到第几张图片
    int index = scrollView.contentOffset.x/KScreenWidth + 1;
    //滚动之后如果还在当前页，则不播放音乐
    if (self.currentPage==index) {
        return;
    }else
    {
        self.currentPage = index;
    }
    self.unitTabBar.currentPage = index;
    //先得到mp3的URL数组
    [self getMp3ArrayWithIndex:index senceid:self.senceid];
    [self initMp3Player];
}
- (void)getMp3ArrayWithIndex:(int)index senceid:(NSString *)senceid
{
    NSArray *mp3arr = self.mp3Dict[senceid];
    for (NSDictionary *dict in mp3arr) {
        if ([dict.allKeys containsObject:@(index)]) {
            NSArray *mp3Data = dict[@(index)];
            self.mp3Array = mp3Data;
            break;
        }
    }
}
- (void)initMp3Player
{
    NSMutableArray *itemArray = [NSMutableArray array];
    for (NSString *str in self.mp3Array) {
        NSURL *url = [NSURL URLWithString:str];
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
        [itemArray addObject:item];
    }
    _mp3Player = [AVQueuePlayer queuePlayerWithItems:itemArray];
    [_mp3Player play];
}
- (void)playbackFinished
{
    //播放下一首mp3
    [self.mp3Player advanceToNextItem];
}
#pragma mark - 控制器销毁时释放内存
- (void)dealloc
{
    self.mp3Player = nil;
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.totalDataArray removeAllObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
