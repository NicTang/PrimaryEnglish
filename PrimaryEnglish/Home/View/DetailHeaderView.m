//
//  DetailHeaderView.m
//  PrimaryEnglish
//
//  Created by Nic Downey on 16/7/11.
//  Copyright © 2016年 Nic. All rights reserved.
//
#define IconViewX 20*ScaleValueX
#define WebViewY 16*ScaleValueY
#define IconViewY 20*ScaleValueY
#define IconViewW 120*ScaleValueX
#define IconViewH 179*ScaleValueY
#define WebViewH 140*ScaleValueY

#import "DetailHeaderView.h"
#import "NDInfoModel.h"
#import "UIImageView+AFNetworking.h"

@interface DetailHeaderView()<UIWebViewDelegate>

@property (nonatomic,strong) UIImageView *iconView;
@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) UILabel *priceLabel;
@end
@implementation DetailHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _iconView = [[UIImageView alloc]initWithFrame:CGRectMake(IconViewX, IconViewY, IconViewW, IconViewH)];
        _iconView.layer.borderColor = [UIColor whiteColor].CGColor;
        _iconView.layer.borderWidth = 5;
        [self addSubview:_iconView];
        
        CGFloat labelX = CGRectGetMaxX(_iconView.frame)+10;
        _webView = [[UIWebView alloc]initWithFrame:CGRectMake(labelX, WebViewY, KScreenWidth-labelX-5, WebViewH)];
        _webView.opaque = NO;
        _webView.backgroundColor = [UIColor clearColor];
        _webView.delegate = self;
        [self addSubview:_webView];
        
        CGFloat labelY = CGRectGetMaxY(_webView.frame)+10*ScaleValueY;
        _priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(labelX+6, labelY, 60*ScaleValueX, 40*ScaleValueY)];
        _priceLabel.hidden = YES;
        [self addSubview:_priceLabel];
    }
    return self;
}
- (void)setModel:(NDInfoModel *)model
{
    _model = model;
    NSString *imgStr = [NSString stringWithFormat:@"http://app.ekaola.com/%@",model.cover];
    [self.iconView setImageWithURL:[NSURL URLWithString:imgStr]];
    
    [self.webView loadHTMLString:model.intro baseURL:nil];
    
    self.priceLabel.hidden = [model.price doubleValue]==0;
    
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:27*ScaleValueY],NSForegroundColorAttributeName:[UIColor whiteColor]};
    NSAttributedString *attrs = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"¥ %d",[model.price intValue]] attributes:dict];
    [self.priceLabel setAttributedText:attrs];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('p')[0].style.webkitTextSizeAdjust= '93%'"];
    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('p')[0].style.webkitTextFillColor= 'white'"];
}
@end
